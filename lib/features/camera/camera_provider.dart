import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:native_exif/native_exif.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gal/gal.dart';
import 'package:crypto/crypto.dart';

class CameraProvider extends ChangeNotifier {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  int _currentCameraIndex = 0; // Front vs Back toggling index typically
  FlashMode _flashMode = FlashMode.off;
  
  double _currentZoom = 1.0;
  String _currentZoomLabel = '1x'; // Tracks '0.5x', '1x', '2x'
  double _minZoom = 1.0;
  double _maxZoom = 1.0;

  double _currentExposure = 0.0;
  double _minExposure = 0.0;
  double _maxExposure = 0.0;

  File? _lastCapturedFile;
  List<File> _galleryFiles = [];

  String? _lastImageHash;
  Map<String, dynamic>? _lastLocationData;
  String? _lastCameraDirection;

  StreamSubscription<Position>? _positionStream;
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  // Custom Notes State
  String _overlayNotes = '';
  Color _notesColor = Colors.white;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  FlashMode get flashMode => _flashMode;
  double get currentZoom => _currentZoom;
  String get currentZoomLabel => _currentZoomLabel;
  double get currentExposure => _currentExposure;
  File? get lastCapturedFile => _lastCapturedFile;
  List<File> get galleryFiles => _galleryFiles;

  String? get lastImageHash => _lastImageHash;
  Map<String, dynamic>? get lastLocationData => _lastLocationData;
  String? get lastCameraDirection => _lastCameraDirection;

  // New Getters
  String get overlayNotes => _overlayNotes;
  Color get notesColor => _notesColor;
  bool get isFrontCamera => _controller?.description.lensDirection == CameraLensDirection.front;

  Future<void> initCamera() async {
    try {
      await loadSavedImages(); // Load previous captures
      _startLocationStream(); // Start listening to location

      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        // Find standard back camera first
        int initialIdx = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
        if (initialIdx == -1) initialIdx = 0;
        _currentCameraIndex = initialIdx;
        await _setCamera(_cameras[_currentCameraIndex]);
      }
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  Future<void> _startLocationStream() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }
    }

    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3,
      ),
    ).listen((Position position) {
      _currentPosition = position;
      notifyListeners();
    }, onError: (e) {
      debugPrint("Location stream error: $e");
    });
  }

  Future<void> loadSavedImages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final List<FileSystemEntity> files = directory.listSync();
      
      // Filter for jpegs and sort by modified date descending
      List<File> imageFiles = files
          .whereType<File>()
          .where((file) => file.path.endsWith('.jpg'))
          .toList()
        ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      _galleryFiles.clear();
      for (var file in imageFiles) {
        _galleryFiles.add(file);
      }
      
      if (_galleryFiles.isNotEmpty) {
        _lastCapturedFile = _galleryFiles.first;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading saved images: $e");
    }
  }

  Future<void> _setCamera(CameraDescription cameraDescription) async {
    _isInitialized = false;
    notifyListeners();

    final previousController = _controller;
    await previousController?.dispose();

    final CameraController cameraController = CameraController(
      cameraDescription,
      Platform.isAndroid ? ResolutionPreset.medium : ResolutionPreset.high, // 'max' or 'veryHigh' can cause buffer exhaustion on mid-range Android devices
      enableAudio: true,
    );

    try {
      await cameraController.initialize();
      
      _minZoom = await cameraController.getMinZoomLevel();
      _maxZoom = await cameraController.getMaxZoomLevel();
      _minExposure = await cameraController.getMinExposureOffset();
      _maxExposure = await cameraController.getMaxExposureOffset();
      
      // If we just toggled to front/back, reset zoom label correctly
      _currentExposure = 0.0;
      
      _controller = cameraController;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Error setting camera: $e");
    }
  }

  // Set zoom with physical lens matching
  Future<void> setSpecificLens(double digitalZoom, String label) async {
    if (_controller == null || !_isInitialized) return;
    try {
      _currentZoomLabel = label;
      
      // Attempt to physically switch lenses based on name index, 
      // but devices expose lenses differently. We will map index to strings for wide/ultrawide
      List<CameraDescription> backCameras = _cameras.where((c) => c.lensDirection == CameraLensDirection.back).toList();
      
      // Heuristic fallback matching (if phone exposes 3 back lenses)
      if (backCameras.length >= 3) {
        if (label == '0.5x') await _setCamera(backCameras[2]); // commonly ultrawide
        else if (label == '1x') await _setCamera(backCameras[0]); // commonly wide
        else if (label == '2x') await _setCamera(backCameras[1]); // commonly telephoto
      } else if (backCameras.length == 2) {
        if (label == '0.5x') await _setCamera(backCameras[1]);
        else if (label == '1x' || label == '2x') {
            await _setCamera(backCameras[0]);
            double z = label == '2x' ? 2.0 : 1.0;
            await _controller!.setZoomLevel(z.clamp(_minZoom, _maxZoom));
        }
      } else {
        // Standard digital zoom on single lens
        double targetZoom = digitalZoom.clamp(_minZoom, _maxZoom);
        await _controller!.setZoomLevel(targetZoom);
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error setting lens/zoom: $e");
    }
  }

  void setFocusPoint(Offset point) async {
    if (_controller == null || !_isInitialized) return;
    try {
      await _controller!.setFocusPoint(point);
    } catch (e) {
      debugPrint("Error setting focus: $e");
    }
  }

  void setExposureOffset(double delta) async {
    if (_controller == null || !_isInitialized) return;
    try {
      _currentExposure = (_currentExposure + delta).clamp(_minExposure, _maxExposure);
      await _controller!.setExposureOffset(_currentExposure);
    } catch (e) {
      debugPrint("Error setting exposure: $e");
    }
  }

  Future<File?> addCapturedImage(Uint8List imageBytes, String captureId) async {
    try {
      // 1. Convert PNG to JPEG
      final jpegBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        format: CompressFormat.jpeg,
        quality: 95,
      );

      // 2. Save locally to app documents directory
      final directory = await getApplicationDocumentsDirectory();
      // Match firebase name format
      final file = File('${directory.path}/$captureId.jpg');
      await file.writeAsBytes(jpegBytes);

      // 3. Hash and Inject EXIF
      final imageHash = sha256.convert(jpegBytes).toString();
      
      final exif = await Exif.fromPath(file.path);
      await exif.writeAttribute('UserComment', imageHash);
      
      Map<String, dynamic> locationDataMap = {
        'captureId': captureId,
      };

      if (_currentPosition != null) {
        locationDataMap.addAll({
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
          'accuracy': _currentPosition!.accuracy,
          'altitude': _currentPosition!.altitude,
          'speed': _currentPosition!.speed,
          'timestamp': _currentPosition!.timestamp.toIso8601String(),
        });
      }
      await exif.writeAttribute('ImageDescription', jsonEncode(locationDataMap));

      await exif.close();

      // 4. Save fully baked file to Android/iOS Gallery
      await Gal.putImage(file.path);

      // 3. Upload metadata to Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final captureData = {
          'captureId': captureId,
          'timestamp': FieldValue.serverTimestamp(),
          'cameraDirection': _controller?.description.lensDirection.toString(),
          'zoomLevel': _currentZoom,
          'exposure': _currentExposure,
          'imageHash': imageHash,
          'location': locationDataMap,
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('captures')
            .doc(captureId)
            .set(captureData)
            .catchError((e) {
               debugPrint("Error saving to Firestore: $e");
            });
      }

      // 4. Update memory state
      _lastCapturedFile = file;
      _lastImageHash = imageHash;
      _lastLocationData = locationDataMap;
      _lastCameraDirection = _controller?.description.lensDirection.toString();
      _galleryFiles.insert(0, file); // Add to beginning of sequence
      notifyListeners();
      return file;
    } catch (e) {
      debugPrint("Error saving image locally: $e");
      return null;
    }
  }

  void setOverlayNotes(String notes) {
    if (_overlayNotes != notes) {
      _overlayNotes = notes;
      notifyListeners();
    }
  }

  void setNotesColor(Color color) {
    if (_notesColor != color) {
      _notesColor = color;
      notifyListeners();
    }
  }

  Future<void> toggleCamera() async {
    if (_cameras.isEmpty) return;

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    await _setCamera(_cameras[_currentCameraIndex]);
  }

  Future<void> toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      if (_flashMode == FlashMode.off) {
        await _controller!.setFlashMode(FlashMode.always);
        _flashMode = FlashMode.always;
      } else if (_flashMode == FlashMode.always) {
        await _controller!.setFlashMode(FlashMode.auto);
        _flashMode = FlashMode.auto;
      } else {
        await _controller!.setFlashMode(FlashMode.off);
        _flashMode = FlashMode.off;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error toggling flash: $e");
    }
  }

  /// Pauses the camera preview stream — call when navigating away from camera screen
  Future<void> pauseCamera() async {
    if (_controller == null || !_isInitialized) return;
    try {
      await _controller!.pausePreview();
    } catch (e) {
      debugPrint("Error pausing camera: $e");
    }
  }

  /// Resumes the camera preview stream — call when returning to camera screen
  Future<void> resumeCamera() async {
    if (_controller == null || !_isInitialized) return;
    try {
      await _controller!.resumePreview();
      
      // VITAL Android Workaround: send a benign configuration update to unfreeze HAL.
      try {
        await Future.delayed(const Duration(milliseconds: 100)); // slight delay so surface is ready
        await _controller!.setZoomLevel(_currentZoom);
      } catch (e) {
        debugPrint("Zoom ping failed: $e");
      }

      notifyListeners(); // Force the CameraPreview widget to rebuild its texture
    } catch (e) {
      debugPrint("Error resuming camera: $e");
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _controller?.dispose();
    super.dispose();
  }
}
