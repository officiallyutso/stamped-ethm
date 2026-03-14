import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stamped/core/services/backend_api_service.dart';
import 'models/capture_metadata.dart';
import 'models/report_block.dart';
import 'markdown_generator.dart';
import 'widgets/hold_to_confirm_button.dart';
import 'report_result_screen.dart';
import 'package:stamped/core/services/firestore_report_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:stamped/core/theme/app_colors.dart';


class ReportMarkdownEditor extends StatefulWidget {
  final List<File> selectedImages;

  const ReportMarkdownEditor({super.key, required this.selectedImages});

  @override
  State<ReportMarkdownEditor> createState() => _ReportMarkdownEditorState();
}

class _ReportMarkdownEditorState extends State<ReportMarkdownEditor> {
  bool _isLoading = true;
  bool _isSaving = false;
  List<ReportBlock> _blocks = [];
  String _previewMarkdown = "";
  final List<String> _generationLogs = [];
  final _firestoreReportService = FirestoreReportService();

  @override
  void initState() {
    super.initState();
    _loadMetadataAndInitBlocks();
  }

  Future<void> _loadMetadataAndInitBlocks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('captures')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      final metadataList = snapshot.docs
          .map((doc) => CaptureMetadata.fromFirestore(doc.data()))
          .toList();

      List<ReportBlock> initialBlocks = [];
      initialBlocks.add(TextBlock(id: 'header', initialText: ''));

      for (int i = 0; i < widget.selectedImages.length; i++) {
        final file = widget.selectedImages[i];
        for (int i = 0; i < widget.selectedImages.length; i++) {
          final file = widget.selectedImages[i];

          // Compress image before Base64 encoding
          final compressedBytes = await FlutterImageCompress.compressWithFile(
            file.absolute.path,
            minWidth: 1280,
            minHeight: 1280,
            quality: 60,
            format: CompressFormat.jpeg,
          );

          final bytes = compressedBytes ?? await file.readAsBytes();

          // Find matching metadata
          CaptureMetadata? metadata;
          if (i < metadataList.length) {
            metadata = metadataList[i];
          }

          initialBlocks.add(
            ImageBlock(
              id: 'image_$i',
              file: file,
              metadata: metadata,
              base64Data: base64Encode(bytes),
            ),
          );

          initialBlocks.add(
            TextBlock(
              id: 'text_$i',
              initialText: '> Enter notes here for Evidence ${i + 1}\n',
            ),
          );
        }
      }

      setState(() {
        _blocks = initialBlocks;
        _isLoading = false;
        _updatePreview();
      });
    } catch (e) {
      debugPrint("Error initializing blocks: $e");
      setState(() {
        _isLoading = false;
        _blocks = [
          TextBlock(id: 'error', initialText: '# Error loading metadata\n\n$e'),
        ];
      });
    }
  }

  void _updatePreview() {
    setState(() {
      _previewMarkdown = MarkdownGenerator.generatePreviewMarkdown(_blocks);
    });
  }

  void _addLog(String message) {
    setState(() {
      _generationLogs.add(
        "[${DateFormat('HH:mm:ss').format(DateTime.now())}] $message",
      );
    });
    debugPrint(message);
  }

  Future<void> _saveToFileverse() async {
    setState(() {
      _isSaving = true;
      _generationLogs.clear();
    });
    try {
      _addLog("Generating markdown (images excluded for Fileverse)...");
      final fileverseMarkdown = await MarkdownGenerator.generateForFileverse(_blocks);

      _addLog("Sending to Fileverse...");
      final backend = BackendApiService();
      final result = await backend.createFileverseDoc(
        title: "Report - ${DateTime.now().toLocal()}",
        content: fileverseMarkdown,
      );

      final shareableLink = result['shareableLink'] ?? "unknown";
      _addLog("Success! Link: $shareableLink");

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Report Saved"),
            content: Text(
              "Your report has been successfully synced to Fileverse.\n\nLink: $shareableLink",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        ).then((_) => Navigator.pop(context));
      }
    } catch (e) {
      _addLog("ERROR: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to save: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _generateAndSubmitReport() async {
    setState(() {
      _isSaving = true;
      _generationLogs.clear();
    });
    try {
      _addLog("Step 1: Generating lightweight markdown for Fileverse (images excluded)...");
      // 1. Generate Fileverse-safe markdown WITHOUT Base64 images
      final fileverseMarkdown = await MarkdownGenerator.generateForFileverse(_blocks);

      _addLog("Step 2: Sending request to backend Fileverse service...");
      // 2. Call backend API for Fileverse
      final backend = BackendApiService();
      final result = await backend.createFileverseDoc(
        title:
            "Field Inspection Report - ${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
        content: fileverseMarkdown,
      );

      final shareableLink = result['shareableLink'];
      if (shareableLink == null)
        throw Exception("Failed to get shareable link from Fileverse");
      _addLog("Step 2 verified: Shareable link received.");

      _addLog("Step 3: Storing report metadata in Firestore...");
      // 3. Store in Firestore under users/{uid}/reports
      await _firestoreReportService.saveReport(
        fileverseLink: shareableLink,
        title: "Field Inspection Report",
        imageCount: _blocks.whereType<ImageBlock>().length,
        imageIds: _blocks
            .whereType<ImageBlock>()
            .map((b) => b.metadata?.captureId ?? 'unknown')
            .toList(),
      );
      _addLog("Step 3 complete: Firestore updated.");

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportResultScreen(
              isSuccess: true,
              fileverseLink: shareableLink,
            ),
          ),
        );
      }
    } catch (e) {
      _addLog("FATAL ERROR: $e");
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportResultScreen(
              isSuccess: false,
              errorMessage: e.toString(),
              onRetry: _generateAndSubmitReport,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Edit Report"),
          bottom: TabBar(
            onTap: (index) {
              if (index == 1) _updatePreview();
            },
            tabs: const [
              Tab(text: "Edit", icon: Icon(LucideIcons.edit)),
              Tab(text: "Preview", icon: Icon(LucideIcons.eye)),
            ],
          ),
          actions: [
            if (!_isLoading)
              TextButton.icon(
                onPressed: _isSaving ? null : _saveToFileverse,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(LucideIcons.save, color: Colors.white),
                label: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SafeArea(bottom: true, child: _buildEditorTab()),
                  Stack(
                    children: [
                      _buildPreviewTab(),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0),
                                  Colors.white.withOpacity(0.9),
                                  Colors.white,
                                ],
                              ),
                            ),
                            child: HoldToConfirmButton(
                              text: "GENERATE REPORT",
                              onConfirmed: _generateAndSubmitReport,
                              color: AppColors.textRed,
                            ),
                          ),
                        ),
                      ),
                      if (_isSaving)
                        Container(
                          color: Colors.black87,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    "REPORT GENERATION PROGRESS",
                                    style: TextStyle(
                                      color: AppColors.textRed,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    height: 200,
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey[800]!,
                                      ),
                                    ),
                                    child: ListView.builder(
                                      itemCount: _generationLogs.length,
                                      reverse: true,
                                      itemBuilder: (context, index) {
                                        final log =
                                            _generationLogs[_generationLogs
                                                    .length -
                                                1 -
                                                index];
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          child: Text(
                                            log,
                                            style: const TextStyle(
                                              color: Colors.greenAccent,
                                              fontSize: 11,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEditorTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _blocks.length,
      itemBuilder: (context, index) {
        final block = _blocks[index];
        if (block is TextBlock) {
          return TextField(
            controller: block.controller,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: "Type here...",
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 16),
            onChanged: (_) => _updatePreview(),
          );
        } else if (block is ImageBlock) {
          return _buildImagePlaceholder(block);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildImagePlaceholder(ImageBlock block) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(
              block.file,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Image Evidence",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  "ID: ${block.metadata?.captureId ?? 'Pending'}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const Text(
                  "Base64 data stored internally",
                  style: TextStyle(
                    color: AppColors.textRed,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewTab() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 100.0,
      ), // Padding for the sticky button
      child: Markdown(
        data: _previewMarkdown,
        imageBuilder: (uri, title, alt) {
          if (uri.scheme == 'block-image') {
            final blockId = uri.host;
            final block = _blocks.firstWhere(
              (b) => b.id == blockId,
              orElse: () => _blocks.first, // Fallback
            );
            if (block is ImageBlock) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(block.file, fit: BoxFit.contain),
                ),
              );
            }
          }
          return const Icon(Icons.broken_image);
        },
      ),
    );
  }
}
