import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:gal/gal.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:stamped/features/camera/camera_provider.dart';
import 'package:stamped/features/camera/widgets/top_action_row.dart';
import 'package:stamped/features/camera/widgets/time_location_overlay.dart';
import 'package:stamped/features/camera/widgets/workspace_banner.dart';
import 'package:stamped/features/camera/widgets/camera_bottom_controls.dart';
import 'package:stamped/features/camera/widgets/bottom_navigation_tabs.dart';
import 'package:stamped/features/reports/reports_screen.dart';
import 'package:stamped/features/auth/auth_screen.dart';
import 'package:stamped/features/auth/auth_provider.dart';
import 'package:stamped/features/workspace/workspace_provider.dart';
import 'package:stamped/core/services/cloudinary_service.dart';

class CameraScreen extends StatefulWidget {
  final Function(int)? onNavigate;
  final int currentIndex;

  const CameraScreen({
    super.key,
    this.onNavigate,
    this.currentIndex = 0,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  final GlobalKey _boundaryKey = GlobalKey();
  final GlobalKey<TimeLocationOverlayState> _overlayKey = GlobalKey<TimeLocationOverlayState>();
  final PageController _pageController = PageController(initialPage: 2); // Default to Photo
  int _currentIndex = 2;
  bool _isCapturing = false;
  String? _currentCaptureId;

  String _generateCaptureId() {
    final random = Random();
    final hexChars = '0123456789ABCDEF';
    return List.generate(12, (_) => hexChars[random.nextInt(16)]).join();
  }

  void _onPageChanged(int index) {
      if (index == 0) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (!authProvider.isAuthenticated) {
          _pageController.jumpToPage(2);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AuthScreen()),
          ).then((isLoggedIn) {
            if (isLoggedIn == true && mounted) {
              _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            }
          });
          return;
        }
      }
      setState(() {
        _currentIndex = index;
      });
  }

  void _navigateToPage(int index) {
    _pageController.animateToPage(
      index, 
      duration: const Duration(milliseconds: 300), 
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CameraProvider>(context, listen: false).initCamera();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final provider = Provider.of<CameraProvider>(context, listen: false);
      if (provider.isInitialized && provider.controller != null) {
        // Safe attempt to resume or re-initialize if the camera died
        provider.initCamera(); 
      }
    } else if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
         // Pause the stream if going to background
         Provider.of<CameraProvider>(context, listen: false).pauseCamera();
    }
  }

  Future<void> _captureImage() async {
    if (_isCapturing) return;

    final captureId = _generateCaptureId();
    setState(() {
      _isCapturing = true;
      _currentCaptureId = captureId;
    });

    // Wait for the UI to rebuild without the icons before capturing
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      RenderRepaintBoundary boundary = _boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0); // High res capture
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      await Gal.putImageBytes(pngBytes);
      
      if (mounted) {
        final provider = Provider.of<CameraProvider>(context, listen: false);
        final file = await provider.addCapturedImage(pngBytes, captureId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved to Gallery!'), duration: Duration(seconds: 2)),
        );

        // Auto upload to workspace if project is selected
        if (mounted) {
          final wp = Provider.of<WorkspaceProvider>(context, listen: false);
          final auth = Provider.of<AuthProvider>(context, listen: false);
          
          if (wp.currentWorkspace != null && wp.currentProject != null && auth.user != null && file != null) {
            final cloudinaryService = CloudinaryService();
            final capturedHash = provider.lastImageHash;
            final capturedLocation = provider.lastLocationData;
            final capturedDirection = provider.lastCameraDirection;
            final capturedZoom = provider.currentZoom;
            final capturedExposure = provider.currentExposure;
            
            cloudinaryService.uploadImage(file).then((url) {
              if (url != null) {
                wp.workspaceService.addPhotoRecord(
                  url,
                  auth.user!.uid,
                  wp.currentWorkspace!.id,
                  projectId: wp.currentProject!.id,
                  latitude: capturedLocation?['latitude'] as double?,
                  longitude: capturedLocation?['longitude'] as double?,
                  altitude: capturedLocation?['altitude'] as double?,
                  accuracy: capturedLocation?['accuracy'] as double?,
                  speed: capturedLocation?['speed'] as double?,
                  cameraDirection: capturedDirection,
                  zoomLevel: capturedZoom,
                  exposure: capturedExposure,
                  imageHash: capturedHash,
                ).then((_) {
                  debugPrint("Auto-uploaded photo to Workspace.");
                });
              }
            }).catchError((e) {
              debugPrint("Auto-upload error: $e");
            });
          }
        }
      }
    } catch (e) {
       debugPrint("Capture error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
          _currentCaptureId = null;
        });
      }
    }
  }

  double _getRotationSafeTurns(NativeDeviceOrientation orientation) {
    switch (orientation) {
      case NativeDeviceOrientation.landscapeLeft:
        return 0.25; // 90° clockwise
      case NativeDeviceOrientation.landscapeRight:
        return -0.25; // -90° clockwise
      case NativeDeviceOrientation.portraitDown:
        return 0.5; // 180°
      default:
        return 0.0; // portraitUp
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: NativeDeviceOrientationReader(
          builder: (context) {
            final orientation = NativeDeviceOrientationReader.orientation(context);
            final double turns = _getRotationSafeTurns(orientation);

            return Consumer<CameraProvider>(
              builder: (context, cameraProvider, child) {
                if (!cameraProvider.isInitialized || cameraProvider.controller == null || !cameraProvider.controller!.value.isInitialized) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }

                return Column(
                  children: [
                    // To keep everything clean we only rotate the text/icons using AnimatedRotation inside the widgets, but for brevity we rotate the whole overlay
                    const TopActionRow(),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        physics: const NeverScrollableScrollPhysics(), // Disables main view swiping
                        children: [
                          // 0. Reports View
                          const ReportsScreenEmbedded(),
                          
                          // 1. Video View (Mock)
                          const Center(
                            child: Text(
                              'Video Coming Soon', 
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),

                          // 2. Camera View (Photo)
                          _KeepAlivePage(
                            child: Stack(
                              fit: StackFit.expand,
                            children: [
                              // 1. Watermarkable Render Boundary
                              RepaintBoundary(
                                key: _boundaryKey,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Camera Viewport with Gestures
                                    GestureDetector(
                                      onTapDown: (details) {
                                        final renderBox = context.findRenderObject() as RenderBox;
                                        final offset = renderBox.globalToLocal(details.globalPosition);
                                        final x = offset.dx / renderBox.size.width;
                                        final y = offset.dy / renderBox.size.height;
                                        cameraProvider.setFocusPoint(Offset(x, y));
                                      },
                                      onVerticalDragUpdate: (details) {
                                        cameraProvider.setExposureOffset(details.delta.dy * -0.05);
                                      },
                                      child: ClipRRect(
                                        child: _buildCameraPreview(cameraProvider.controller!),
                                      ),
                                    ),
                                    // Rotated Time/Location Overlay
                                    TimeLocationOverlay(
                                      key: _overlayKey,
                                      isCapturing: _isCapturing,
                                      turns: turns,
                                    ),
                                    // Watermark (Only shown briefly during capture)
                                    if (_isCapturing) ...[
                                      Positioned(
                                        right: 16,
                                        bottom: 24,
                                        child: AnimatedRotation(
                                          turns: turns,
                                          duration: const Duration(milliseconds: 300),
                                          child: const Text(
                                            'Verified by Stamped',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (_currentCaptureId != null)
                                        Positioned(
                                          right: 8,
                                          top: 0,
                                          bottom: 0,
                                          child: Center(
                                            child: RotatedBox(
                                              quarterTurns: 3,
                                              child: Text(
                                                'ID: $_currentCaptureId',
                                                style: const TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 12,
                                                  letterSpacing: 2.0,
                                                  fontWeight: FontWeight.bold,
                                                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                              
                              // 2. Transcendent UI over the camera (Not watermarked)
                              Positioned(
                                right: 16,
                                bottom: 16,
                                child: AnimatedRotation(
                                  turns: turns,
                                  duration: const Duration(milliseconds: 300),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Zoom Controllers
                                      if (cameraProvider.controller!.description.lensDirection != CameraLensDirection.front) ...[
                                        _buildZoomButton(cameraProvider, 2.0, '2x'),
                                        _buildZoomButton(cameraProvider, 1.0, '1x'),
                                        _buildZoomButton(cameraProvider, 0.5, '0.5x'),
                                        const SizedBox(height: 24), // Spacer
                                      ],
                                      
                                      // Persistent Action Icons (Not watermarked)
                                      GestureDetector(
                                        onTap: () {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Edit tapped")));
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 16, right: 4),
                                          decoration: const BoxDecoration(
                                            color: Colors.black45,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          child: const Icon(LucideIcons.edit, color: Colors.white, size: 24),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          _overlayKey.currentState?.fetchLocation();
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(right: 4),
                                          decoration: const BoxDecoration(
                                            color: Colors.black45,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          child: const Icon(LucideIcons.mapPin, color: Colors.white, size: 24),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          ),
                          
                          // 3. Time In & Out (Mock)
                          const Center(
                            child: Text(
                              'Time In & Out Coming Soon', 
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ]
                      ),
                    ),
                    const WorkspaceBanner(),
                    if (_currentIndex == 2) CameraBottomControls(onCapture: _captureImage),
                    BottomNavigationTabs(
                      currentIndex: _currentIndex,
                      onNavigate: _navigateToPage,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildZoomButton(CameraProvider provider, double zoomVal, String label) {
    bool isSelected = provider.currentZoomLabel == label;
    double size = isSelected ? 36.0 : 26.0;

    return GestureDetector(
      onTap: () => provider.setSpecificLens(zoomVal, label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4), // horizontal padding to right-align logically
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.black45,
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? Colors.white : Colors.white54, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label.replaceAll('x', ''), 
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: isSelected ? 12 : 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPreview(CameraController controller) {
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
         width: controller.value.previewSize?.height ?? MediaQuery.of(context).size.width,
         height: controller.value.previewSize?.width ?? MediaQuery.of(context).size.height,
         child: CameraPreview(controller),
      ),
    );
  }
}

class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}


