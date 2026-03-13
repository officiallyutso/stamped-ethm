import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:stamped/features/camera/camera_provider.dart';
import 'package:camera/camera.dart';

class TopActionRow extends StatelessWidget {
  const TopActionRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(LucideIcons.menu, size: 28),
            Consumer<CameraProvider>(
              builder: (context, cameraProvider, child) {
                return IconButton(
                  icon: Icon(
                    cameraProvider.flashMode == FlashMode.off
                        ? LucideIcons.zapOff
                        : (cameraProvider.flashMode == FlashMode.always
                            ? LucideIcons.zap
                            : LucideIcons.zap), // Or auto icon if available
                    size: 24,
                  ),
                  onPressed: () => cameraProvider.toggleFlash(),
                );
              },
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.shieldCheck, size: 16, color: Colors.black87),
                  SizedBox(width: 6),
                  Text(
                    'Verify Photos',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.headphones, size: 24),
            Consumer<CameraProvider>(
              builder: (context, cameraProvider, child) {
                return IconButton(
                  icon: const Icon(LucideIcons.switchCamera, size: 24),
                  onPressed: () => cameraProvider.toggleCamera(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
