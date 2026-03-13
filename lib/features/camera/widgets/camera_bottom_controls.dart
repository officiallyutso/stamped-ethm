import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:stamped/features/camera/camera_provider.dart';
import 'package:stamped/features/camera/gallery_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
}

class CameraBottomControls extends StatelessWidget {
  final VoidCallback onCapture;

  const CameraBottomControls({super.key, required this.onCapture});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Preview placeholder
              GestureDetector(
                onTap: () async {
                  final provider = Provider.of<CameraProvider>(context, listen: false);
                  await provider.pauseCamera();
                  await Navigator.push(context, FadePageRoute(page: const GalleryScreen()));
                  await provider.resumeCamera();
                  // Re-initialize camera on return just in case the Android buffer disconnected
                  provider.initCamera(); 
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Consumer<CameraProvider>(
                      builder: (context, provider, child) {
                        return Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: provider.lastCapturedFile != null
                                ? Image.file(provider.lastCapturedFile!, fit: BoxFit.cover)
                                : Container(color: Colors.green.shade900),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    const Text('Preview', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                ),
              ),

              // Templates icon
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: const Icon(LucideIcons.layoutTemplate, size: 28, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  const Text('Templates', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                ],
              ),
            ],
          ),

          // Shutter Button (Centered)
          GestureDetector(
            onTap: onCapture,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 4),
              ),
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

