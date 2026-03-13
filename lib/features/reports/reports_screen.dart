import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stamped/features/camera/camera_provider.dart';
import 'package:stamped/features/camera/widgets/bottom_navigation_tabs.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stamped/core/services/pinata_service.dart';
import 'package:stamped/core/services/fileverse_service.dart';
import 'package:stamped/features/auth/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      final pinata = PinataService();
      final fileverse = FileverseService();
      
      List<String> imageHashLinks = [];
      String markdownContent = "# Field Report\n\nGenerated on \${DateTime.now().toIso8601String()}\n\n## Attached Evidences\n\n";

      // 1. Upload images to IPFS
      int count = 1;
      for (int index in _selectedIndices) {
        if (index < provider.galleryFiles.length) {
          final file = provider.galleryFiles[index];
          String? ipfsHash = await pinata.uploadImage(file);
          if (ipfsHash != null) {
            imageHashLinks.add(ipfsHash);
            markdownContent += "### Evidence \$count\n";
            markdownContent += "![Evidence \$count](https://gateway.pinata.cloud/ipfs/\$ipfsHash)\n\n";
            count++;
          }
        }
      }

      // 2. Create Fileverse Event
      final fileverseApiKey = dotenv.env['FILEVERSE_API_KEY'];
      if (fileverseApiKey == null) throw Exception("Missing FILEVERSE_API_KEY in .env");

      final docResult = await fileverse.createDocument(
        title: "Report - \${DateTime.now().toLocal()}",
        content: markdownContent,
        apiKey: fileverseApiKey,
      );

      // docResult now contains the response from the fileverse api
      
      // 3. Save reference to Firestore
      final userId = authProvider.user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).collection('reports').add({
        'createdAt': FieldValue.serverTimestamp(),
        'fileverseDocId': docResult['id'] ?? docResult['documentId'] ?? "unknown",
        'fileverseResponse': docResult,
        'imageHashes': imageHashLinks,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report Successfully Generated & Saved!')),
        );
      }
    } catch (e) {
      debugPrint("Report Generation Error: \$e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: \${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _selectedIndices.clear();
        });
      }
    }
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
                      Text("Uploading to IPFS & Fileverse..."),
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
