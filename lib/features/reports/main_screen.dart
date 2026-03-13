import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stamped/features/camera/camera_screen.dart';
import 'package:stamped/features/reports/reports_screen.dart';
import 'package:stamped/features/auth/auth_provider.dart';
import 'package:stamped/features/auth/auth_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController(initialPage: 0); // Default Camera
  int _currentIndex = 0;

  void _onPageChanged(int index) {
    // If trying to go to Reports (index 1) and not authenticated, intercept
    if (index == 1) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        // Intercept and show login
        // Revert page controller back
        _pageController.jumpToPage(0);
        
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        ).then((isLoggedIn) {
          if (isLoggedIn == true && mounted) {
            // Login successful, go to Reports
            _pageController.animateToPage(
              1, 
              duration: const Duration(milliseconds: 300), 
              curve: Curves.easeInOut,
            );
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      children: [
        CameraScreen(onNavigate: _navigateToPage, currentIndex: _currentIndex),
        ReportsScreen(onNavigate: _navigateToPage, currentIndex: _currentIndex),
      ],
    );
  }
}
