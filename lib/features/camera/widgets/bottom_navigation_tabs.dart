import 'package:flutter/material.dart';
import 'package:stamped/bitgo_mpc/mpc_sign_page.dart';

class BottomNavigationTabs extends StatelessWidget {
  final int currentIndex;
  final Function(int) onNavigate;

  const BottomNavigationTabs({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        int newIndex = currentIndex;
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < -150) {
            // Swiped left (next tab)
            newIndex = (currentIndex + 1).clamp(0, 3);
          } else if (details.primaryVelocity! > 150) {
            // Swiped right (previous tab)
            newIndex = (currentIndex - 1).clamp(0, 3);
          }
        }
        if (newIndex != currentIndex) {
          onNavigate(newIndex);
        }
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(bottom: 24, top: 4), // extra bottom padding for iOS home indicator
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavTab(
              text: 'REPORTS',
              isSelected: currentIndex == 0,
              onTap: () => onNavigate(0),
            ),
            _NavTab(
              text: 'VIDEO',
              isSelected: currentIndex == 1,
              onTap: () => onNavigate(1),
            ),
            _NavTab(
              text: 'PHOTO',
              isSelected: currentIndex == 2,
              onTap: () => onNavigate(2),
            ),
            _NavTab(
              text: 'TIME IN&OUT',
              isSelected: currentIndex == 3,
              onTap: () => onNavigate(3),
            ),
            _NavTab(
              text: 'MPC SIGN',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MpcSignPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;

  const _NavTab({
    required this.text,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey.shade500,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 10, // Slightly smaller to fit 5 items
              letterSpacing: 0.5,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(height: 4),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ] else ...[
            const SizedBox(height: 8), // Placeholder for dot spacing
          ]
        ],
      ),
    );
  }
}
