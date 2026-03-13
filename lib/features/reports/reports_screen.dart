import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stamped/features/camera/camera_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'report_markdown_editor.dart';
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
  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, provider, child) {
        final totalImages = provider.galleryFiles.length;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Expanded(
                child: totalImages == 0
                    ? const Center(
                        child: Text(
                          'No images captured yet.',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
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
                                      border: Border.all(color: Colors.blue, width: 3),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.check_circle, color: Colors.blue, size: 32),
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
                    backgroundColor: Colors.blue,
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
