import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

import '../../core/models/attendance_model.dart';
import '../../core/services/cloudinary_service.dart';
import '../../core/services/workspace_service.dart';

enum AttendanceState { idle, timedIn, onBreak }

class AttendanceProvider extends ChangeNotifier {
  final WorkspaceService _workspaceService = WorkspaceService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  AttendanceState _state = AttendanceState.idle;
  DateTime? _timeInTimestamp;
  DateTime? _breakStartTimestamp;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  Duration _breakElapsed = Duration.zero;
  bool _isBusy = false;

  AttendanceState get state => _state;
  DateTime? get timeInTimestamp => _timeInTimestamp;
  DateTime? get breakStartTimestamp => _breakStartTimestamp;
  Duration get elapsed => _elapsed;
  Duration get breakElapsed => _breakElapsed;
  bool get isBusy => _isBusy;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_state == AttendanceState.timedIn && _timeInTimestamp != null) {
        _elapsed = DateTime.now().difference(_timeInTimestamp!);
      }
      if (_state == AttendanceState.onBreak && _breakStartTimestamp != null) {
        _breakElapsed = DateTime.now().difference(_breakStartTimestamp!);
      }
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Restore state from Firestore when switching projects
  Future<void> restoreState(String userId, String projectId) async {
    try {
      final latest = await _workspaceService.getLatestAttendance(userId, projectId);
      if (latest == null) {
        _resetToIdle();
        return;
      }

      switch (latest.type) {
        case AttendanceType.timeIn:
          _state = AttendanceState.timedIn;
          _timeInTimestamp = latest.timestamp;
          _elapsed = DateTime.now().difference(latest.timestamp);
          _startTimer();
          break;
        case AttendanceType.breakStart:
          _state = AttendanceState.onBreak;
          _breakStartTimestamp = latest.timestamp;
          _breakElapsed = DateTime.now().difference(latest.timestamp);
          _startTimer();
          break;
        case AttendanceType.timeOut:
        case AttendanceType.breakEnd:
          // breakEnd → back to timedIn state? No — breakEnd means back to working.
          // Actually we need to check: if the latest is breakEnd, user is still timed in.
          if (latest.type == AttendanceType.breakEnd) {
            _state = AttendanceState.timedIn;
            // Find the original timeIn to compute elapsed
            _timeInTimestamp = latest.timestamp; // approximate
            _elapsed = Duration.zero;
            _startTimer();
          } else {
            _resetToIdle();
          }
          break;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error restoring attendance state: $e");
      _resetToIdle();
    }
  }

  void _resetToIdle() {
    _state = AttendanceState.idle;
    _timeInTimestamp = null;
    _breakStartTimestamp = null;
    _elapsed = Duration.zero;
    _breakElapsed = Duration.zero;
    _stopTimer();
    notifyListeners();
  }

  /// Capture the camera frame, upload, and record attendance
  Future<void> performAction({
    required AttendanceType type,
    required GlobalKey boundaryKey,
    required String userId,
    required String workspaceId,
    required String projectId,
    double? latitude,
    double? longitude,
  }) async {
    if (_isBusy) return;
    _isBusy = true;
    notifyListeners();

    try {
      // 1. Capture the current camera frame
      String? photoUrl;
      try {
        RenderRepaintBoundary boundary =
            boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        // Convert to JPEG
        final jpegBytes = await FlutterImageCompress.compressWithList(
          pngBytes,
          format: CompressFormat.jpeg,
          quality: 90,
        );

        // Save to temp file
        final directory = await getApplicationDocumentsDirectory();
        final captureId = _generateId();
        final file = File('${directory.path}/attendance_$captureId.jpg');
        await file.writeAsBytes(jpegBytes);

        // Save to gallery
        await Gal.putImage(file.path);

        // Upload to Cloudinary
        photoUrl = await _cloudinaryService.uploadImage(file);
      } catch (e) {
        debugPrint("Error capturing attendance photo: $e");
      }

      // 2. Write attendance record to Firestore
      await _workspaceService.addAttendanceRecord(
        userId: userId,
        workspaceId: workspaceId,
        projectId: projectId,
        type: type,
        photoUrl: photoUrl,
        latitude: latitude,
        longitude: longitude,
      );

      // 3. Update local state
      switch (type) {
        case AttendanceType.timeIn:
          _state = AttendanceState.timedIn;
          _timeInTimestamp = DateTime.now();
          _elapsed = Duration.zero;
          _breakElapsed = Duration.zero;
          _startTimer();
          break;
        case AttendanceType.timeOut:
          _resetToIdle();
          break;
        case AttendanceType.breakStart:
          _state = AttendanceState.onBreak;
          _breakStartTimestamp = DateTime.now();
          _breakElapsed = Duration.zero;
          _startTimer();
          break;
        case AttendanceType.breakEnd:
          _state = AttendanceState.timedIn;
          _breakStartTimestamp = null;
          _breakElapsed = Duration.zero;
          break;
      }
    } catch (e) {
      debugPrint("Error performing attendance action: $e");
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  String _generateId() {
    final random = Random();
    const hexChars = '0123456789ABCDEF';
    return List.generate(12, (_) => hexChars[random.nextInt(16)]).join();
  }

  String formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
