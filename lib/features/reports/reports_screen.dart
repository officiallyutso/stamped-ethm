import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stamped/features/camera/camera_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'report_markdown_editor.dart';
import 'report_history_screen.dart';
import 'package:stamped/core/theme/app_colors.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ReportsScreenEmbedded extends StatefulWidget {
  const ReportsScreenEmbedded({super.key});

  @override
  State<ReportsScreenEmbedded> createState() => _ReportsScreenEmbeddedState();
}

class _ReportsScreenEmbeddedState extends State<ReportsScreenEmbedded> {
  final Set<int> _selectedIndices = {};

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  bool _isGenerating = false;

  Future<void> _generateReport(CameraProvider provider) async {
    final List<File> selectedFiles = [];
    for (int index in _selectedIndices) {
      if (index < provider.galleryFiles.length) {
        selectedFiles.add(provider.galleryFiles[index]);
      }
    }

    if (selectedFiles.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportMarkdownEditor(selectedImages: selectedFiles),
      ),
    );
    
    // Clear selection after navigating
    setState(() {
      _selectedIndices.clear();
    });
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReportHistoryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, provider, child) {
        final totalImages = provider.galleryFiles.length;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              // History button bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'SELECT IMAGES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: _openHistory,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.history,
                              size: 14,
                              color: AppColors.primaryRed,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'History',
                              style: TextStyle(
                                color: AppColors.primaryRed,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: totalImages == 0
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.image,
                              size: 48,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No images captured yet.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Capture photos to generate reports',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: totalImages,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedIndices.contains(index);

                          return GestureDetector(
                            onTap: () => _toggleSelection(index),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    provider.galleryFiles[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.primaryRed, width: 3),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.check_circle, color: AppColors.primaryRed, size: 32),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              if (_isGenerating)
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Generating Report..."),
                    ],
                  ),
                ),
            ],
          ),
          floatingActionButton: (_selectedIndices.isNotEmpty && !_isGenerating)
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 24.0), // Floating above the bottom nav
                  child: FloatingActionButton.extended(
                    onPressed: () => _generateReport(provider),
                    label: const Text('Generate Report'),
                    icon: const Icon(LucideIcons.fileText),
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                  ),
                )
              : null,
        );
      },
    );
  }
}

class ReportsScreen extends StatelessWidget {
  final Function(int) onNavigate;
  final int currentIndex;

  const ReportsScreen({
    super.key,
    required this.onNavigate,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return const ReportsScreenEmbedded();
  }
}
