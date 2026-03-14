import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stamped/features/camera/widgets/premium_paywall_dialog.dart';

class TemplatesSheet extends StatelessWidget {
  const TemplatesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Overlay Templates',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildTemplateCard(
                  title: 'Default \nClassic',
                  icon: LucideIcons.layoutTemplate,
                  isSelected: true,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildTemplateCard(
                  title: 'Minimalist \nData',
                  icon: LucideIcons.alignLeft,
                  isSelected: false,
                  onTap: () => showPaywallDialog(context, 'Minimalist Data Template'), // Paywall
                ),
                _buildTemplateCard(
                  title: 'Inspection \nVertical',
                  icon: LucideIcons.appWindow,
                  isSelected: false,
                  onTap: () => showPaywallDialog(context, 'Inspection Vertical Template'), // Paywall
                ),
                _buildTemplateCard(
                  title: 'Real Estate \nBanner',
                  icon: LucideIcons.columns,
                  isSelected: false,
                  onTap: () => showPaywallDialog(context, 'Real Estate Banner Template'), // Paywall
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Add Your Template Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => showPaywallDialog(context, 'Custom Brand Templates'),
                icon: const Icon(LucideIcons.plusCircle, color: Colors.white),
                label: const Text('Add your template', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFB4128), // New Theme Color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          ),),
      ),
    );
  }

  Widget _buildTemplateCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFB4128).withOpacity(0.1) : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? const Color(0xFFFB4128) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFFFB4128) : Colors.black54, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFB4128) : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
