import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stamped/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:stamped/features/auth/auth_provider.dart';
import 'package:stamped/features/auth/auth_screen.dart';
class WorkspaceBanner extends StatelessWidget {
  const WorkspaceBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isLoggedIn = authProvider.isAuthenticated;
        
        return InkWell(
          onTap: () {
            if (!isLoggedIn) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            } else {
               showDialog(
                 context: context,
                 builder: (ctx) => AlertDialog(
                   title: const Text('Workspace Options'),
                   content: const Text('Do you want to sign out?'),
                   actions: [
                     TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                     TextButton(
                       onPressed: () {
                         authProvider.signOut();
                         Navigator.pop(ctx);
                       }, 
                       child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                     ),
                   ],
                 ),
               );
            }
          },
          child: Container(
            width: double.infinity,
            color: AppColors.primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLoggedIn ? "Your Workspace" : 'Setup Team Workspace',
                  style: const TextStyle(
                    color: AppColors.textBlue,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  LucideIcons.arrowRight,
                  color: AppColors.textBlue,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
