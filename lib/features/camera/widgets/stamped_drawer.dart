import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stamped/features/verification/verify_photo_screen.dart';
import 'package:stamped/features/camera/widgets/premium_paywall_dialog.dart';
import 'package:stamped/core/theme/app_colors.dart';

class StampedDrawer extends StatelessWidget {
  const StampedDrawer({super.key});

  void _launchWhatsApp(BuildContext context) async {
    const phoneNumber = '+919332992332';
    const message = 'Hi, I want to know more about Stamped Plus in order to unlock premium camera features.';
    final Uri url = Uri.parse('whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}');
    
    // Fallback if WhatsApp is not installed
    final Uri webUrl = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open WhatsApp.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Premium Banner
              GestureDetector(
                onTap: () => showPaywallDialog(context, 'Stamped Plus Verification'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryRed, AppColors.primaryRed], // Purple gradient
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.crown, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Stamped Plans',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Icon(LucideIcons.chevronRight, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Remove Ads
              GestureDetector(
                onTap: () => showPaywallDialog(context, 'Ad-Free Experience'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.ban, color: Colors.black87),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Remove ads',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                      ),
                      Icon(LucideIcons.chevronRight, color: Colors.grey.shade400, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2x2 Grid (Ratio, Timer, Filter, Settings)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildGridItem(context, LucideIcons.scaling, 'Ratio'),
                  _buildGridItem(context, LucideIcons.timer, 'Timer'),
                  _buildGridItem(context, LucideIcons.component, 'Filter'),
                  _buildGridItem(context, LucideIcons.settings, 'Settings'),
                ],
              ),
              const SizedBox(height: 24),

              // Functionality List
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildListTile(
                      icon: LucideIcons.shieldCheck,
                      iconColor: Colors.green.shade600,
                      title: 'Verify Photos',
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const VerifyPhotoScreen()));
                      },
                    ),
                    const Divider(height: 1, thickness: 1),
                    _buildSwitchTile(
                      icon: LucideIcons.fileCode,
                      title: 'Developer Watermark',
                      value: true,
                      onChanged: (val) {
                         // Paywall switch
                         showPaywallDialog(context, 'Removable Watermarks');
                      },
                    ),
                    const Divider(height: 1, thickness: 1),
                    _buildSwitchTile(
                      icon: LucideIcons.download,
                      title: 'Keep original photo',
                      value: false,
                      onChanged: (val) {
                         // Paywall switch
                         showPaywallDialog(context, 'Keep Original Assets');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Footer Configs
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildListTile(
                      icon: LucideIcons.headphones,
                      title: 'Contact us',
                      onTap: () => _launchWhatsApp(context),
                    ),
                    const Divider(height: 1, thickness: 1),
                    _buildListTile(
                      icon: LucideIcons.share,
                      title: 'Share Stamped',
                      onTap: () {
                        Navigator.pop(context);
                        Share.share('Check out Stamped - The Immutable Timestamp Camera! Verify your reality.');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, IconData icon, String title) {
    return GestureDetector(
      onTap: () => showPaywallDialog(context, title),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.black87),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: Icon(LucideIcons.chevronRight, color: Colors.grey.shade400, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green,
      ),
    );
  }
}
