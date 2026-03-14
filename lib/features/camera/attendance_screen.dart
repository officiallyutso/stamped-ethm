import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:stamped/features/camera/camera_provider.dart';
import 'package:stamped/features/camera/attendance_provider.dart';
import 'package:stamped/features/camera/widgets/time_location_overlay.dart';
import 'package:stamped/features/camera/widgets/workspace_banner.dart';
import 'package:stamped/features/workspace/workspace_provider.dart';
import 'package:stamped/features/auth/auth_provider.dart';
import 'package:stamped/core/models/attendance_model.dart';
import 'package:stamped/core/theme/app_colors.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final GlobalKey _boundaryKey = GlobalKey();
  final GlobalKey<TimeLocationOverlayState> _overlayKey =
      GlobalKey<TimeLocationOverlayState>();
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _restoreState();
  }

  Future<void> _restoreState() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final wp = Provider.of<WorkspaceProvider>(context, listen: false);
    final attendance = Provider.of<AttendanceProvider>(context, listen: false);

    if (auth.user != null && wp.currentProject != null) {
      await attendance.restoreState(auth.user!.uid, wp.currentProject!.id);
    }
  }

  Future<void> _performAction(AttendanceType type) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final wp = Provider.of<WorkspaceProvider>(context, listen: false);
    final attendance = Provider.of<AttendanceProvider>(context, listen: false);

    if (auth.user == null || wp.currentWorkspace == null || wp.currentProject == null) {
      return;
    }

    setState(() => _isCapturing = true);
    await Future.delayed(const Duration(milliseconds: 100));

    final position = Provider.of<CameraProvider>(context, listen: false).currentPosition;

    await attendance.performAction(
      type: type,
      boundaryKey: _boundaryKey,
      userId: auth.user!.uid,
      workspaceId: wp.currentWorkspace!.id,
      projectId: wp.currentProject!.id,
      latitude: position?.latitude,
      longitude: position?.longitude,
    );

    if (mounted) {
      setState(() => _isCapturing = false);
      _showProfessionalSnackBar(type);
    }
  }

  void _showProfessionalSnackBar(AttendanceType type) {
    IconData icon;
    String label;
    Color color;

    switch (type) {
      case AttendanceType.timeIn:
        icon = LucideIcons.clock;
        label = 'Timed In Successfully';
        color = AppColors.primaryRed;
        break;
      case AttendanceType.timeOut:
        icon = LucideIcons.logOut;
        label = 'Timed Out Successfully';
        color = AppColors.textGreen;
        break;
      case AttendanceType.breakStart:
        icon = LucideIcons.coffee;
        label = 'Break Started';
        color = Colors.orange;
        break;
      case AttendanceType.breakEnd:
        icon = LucideIcons.play;
        label = 'Break Ended';
        color = AppColors.primaryRed;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wp = Provider.of<WorkspaceProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final hasProject = wp.currentProject != null && wp.currentWorkspace != null && auth.user != null;

    return Column(
      children: [
        // Top section: either Camera or Guard View
        Expanded(
          child: hasProject 
            ? _buildAttendanceCameraView() 
            : _buildGuardView(),
        ),

        // Workspace Bar (Positioned ABOVE the buttons as requested)
        const WorkspaceBanner(),

        // Attendance Actions (Only if project selected)
        if (hasProject)
          Consumer<AttendanceProvider>(
            builder: (context, ap, _) => _buildControls(ap),
          ),
      ],
    );
  }

  Widget _buildGuardView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.calendarOff, size: 48, color: AppColors.primaryRed),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select a Project First',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the workspace banner to select a project\nbefore using Time In/Out.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCameraView() {
    return Consumer2<CameraProvider, AttendanceProvider>(
      builder: (context, cameraProvider, attendanceProvider, child) {
        if (!cameraProvider.isInitialized || cameraProvider.controller == null) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            // Capturable boundary
            RepaintBoundary(
              key: _boundaryKey,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Camera
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: cameraProvider.controller!.value.previewSize?.height ??
                          MediaQuery.of(context).size.width,
                      height: cameraProvider.controller!.value.previewSize?.width ??
                          MediaQuery.of(context).size.height,
                      child: CameraPreview(cameraProvider.controller!),
                    ),
                  ),
                  // Time/Location Overlay
                  TimeLocationOverlay(
                    key: _overlayKey,
                    isCapturing: _isCapturing,
                    turns: 0,
                  ),
                  // Watermark during capture
                  if (_isCapturing)
                    Positioned(
                      right: 16,
                      bottom: 24,
                      child: Text(
                        'Verified by Stamped',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // State badge overlay
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: _buildStateBadge(attendanceProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStateBadge(AttendanceProvider provider) {
    if (provider.state == AttendanceState.idle) return const SizedBox.shrink();

    final isBreak = provider.state == AttendanceState.onBreak;
    final color = isBreak ? Colors.orange : AppColors.primaryRed;
    final label = isBreak ? 'Break Ongoing' : 'Shift Active';
    final icon = isBreak ? LucideIcons.coffee : LucideIcons.activity;
    final duration = isBreak
        ? provider.formatDuration(provider.breakElapsed)
        : provider.formatDuration(provider.elapsed);

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                duration,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(AttendanceProvider provider) {
    if (provider.isBusy) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: AppColors.primaryRed,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Processing attendance...'.toUpperCase(), 
                style: const TextStyle(
                  color: Colors.grey, 
                  fontSize: 10, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                )
              ),
            ],
          ),
        ),
      );
    }

    switch (provider.state) {
      case AttendanceState.idle:
        return _buildIdleControls();
      case AttendanceState.timedIn:
        return _buildTimedInControls(provider);
      case AttendanceState.onBreak:
        return _buildOnBreakControls(provider);
    }
  }

  Widget _buildIdleControls() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Center(
        child: _AttendanceActionButton(
          label: 'START SHIFT',
          icon: LucideIcons.clock,
          color: AppColors.primaryRed,
          onTap: () => _performAction(AttendanceType.timeIn),
          isLarge: true,
        ),
      ),
    );
  }

  Widget _buildTimedInControls(AttendanceProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _AttendanceActionButton(
              label: 'TIME OUT',
              icon: LucideIcons.logOut,
              color: AppColors.textGreen,
              onTap: () => _performAction(AttendanceType.timeOut),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _AttendanceActionButton(
              label: 'TAKE BREAK',
              icon: LucideIcons.coffee,
              color: Colors.orange,
              onTap: () => _performAction(AttendanceType.breakStart),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnBreakControls(AttendanceProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _AttendanceActionButton(
              label: 'TIME OUT',
              icon: LucideIcons.logOut,
              color: AppColors.textGreen,
              onTap: () => _performAction(AttendanceType.timeOut),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _AttendanceActionButton(
              label: 'RESUME WORK',
              icon: LucideIcons.play,
              color: AppColors.primaryRed,
              onTap: () => _performAction(AttendanceType.breakEnd),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isLarge;

  const _AttendanceActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isLarge ? 32 : 16,
            vertical: isLarge ? 18 : 14,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: isLarge ? MainAxisSize.min : MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: isLarge ? 20 : 18),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: isLarge ? 16 : 13,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
