import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:stamped/features/camera/camera_provider.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:stamped/features/camera/camera_provider.dart';
import 'package:camera/camera.dart';
import 'package:stamped/features/verification/verify_photo_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class TopActionRow extends StatelessWidget {
  const TopActionRow({super.key});

  void _launchWhatsApp(BuildContext context) async {
    const phoneNumber = '+919332992332';
    const message = 'Hi, I need assistance with the Stamped Plus app.';
    final Uri url = Uri.parse('whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}');
    final Uri webUrl = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp.')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp.')));
      }
    }
  }

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
            IconButton(
              icon: const Icon(LucideIcons.menu, size: 28),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            Consumer<CameraProvider>(
              builder: (context, cameraProvider, child) {
                final isFront = cameraProvider.isFrontCamera;
                return IconButton(
                  icon: Icon(
                    isFront ? LucideIcons.zapOff : (cameraProvider.flashMode == FlashMode.off
                        ? LucideIcons.zapOff
                        : LucideIcons.zap),
                    size: 24,
                    color: isFront ? Colors.grey : Colors.black87,
                  ),
                  onPressed: isFront ? null : () => cameraProvider.toggleFlash(),
                );
              },
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const VerifyPhotoScreen()));
              },
              child: Container(
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
            ),
            IconButton(
              icon: const Icon(LucideIcons.headphones, size: 24),
              onPressed: () => _launchWhatsApp(context),
            ),
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
