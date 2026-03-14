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
  int _currentStep = 0; // 0=not started, 1=generating, 2=uploading, 3=saving
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
      _currentStep = 1;
      _generationLogs.clear();
    });
    try {
      _addLog("Generating markdown with images for Fileverse...");
      final fileverseMarkdown = await MarkdownGenerator.generateForFileverse(_blocks);

      setState(() => _currentStep = 2);
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
      if (mounted) setState(() { _isSaving = false; _currentStep = 0; });
    }
  }

  Future<void> _generateAndSubmitReport() async {
    setState(() {
      _isSaving = true;
      _currentStep = 1;
      _generationLogs.clear();
    });
    try {
      _addLog("Step 1: Generating lightweight markdown for Fileverse...");
      // 1. Generate Fileverse markdown with Base64 images
      final fileverseMarkdown = await MarkdownGenerator.generateForFileverse(_blocks);

      setState(() => _currentStep = 2);
      _addLog("Uploading to Fileverse (may take up to 60s)...");
      
      // 2. Call backend API for Fileverse
      final backend = BackendApiService();
      final result = await backend.createFileverseDoc(
        title:
            "Field Inspection Report - ${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
        content: fileverseMarkdown,
      );

      final shareableLink = result['shareableLink'];
      final ddocId = result['documentId'] ?? result['ddocId'] ?? result['id'];
      if (shareableLink == null || shareableLink.isEmpty) {
        throw Exception("Failed to get official shareable link from Fileverse backend");
      }
      
      _addLog("Link ready: $shareableLink");

      setState(() => _currentStep = 3);
      _addLog("Saving report to Firestore...");
      // 3. Store in Firestore under users/{uid}/reports
      final markdownContent = fileverseMarkdown;
      await _firestoreReportService.saveReport(
        fileverseLink: shareableLink,
        ddocId: ddocId?.toString(),
        title: "Field Inspection Report",
        imageCount: _blocks.whereType<ImageBlock>().length,
        markdownContent: markdownContent,
        imageIds: _blocks
            .whereType<ImageBlock>()
            .map((b) => b.metadata?.captureId ?? 'unknown')
            .toList(),
      );
      _addLog("Firestore updated.");

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
      if (mounted) setState(() { _isSaving = false; _currentStep = 0; });
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
                        _buildSavingOverlay(),
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

  Widget _buildSavingOverlay() {
    return AnimatedOpacity(
      opacity: _isSaving ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        color: const Color(0xF0111111),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pulsing icon
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryRed,
                              AppColors.primaryRed.withOpacity(0.6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryRed.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.fileText,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                const Text(
                  "GENERATING REPORT",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Please wait while we prepare your report",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 36),

                // Stepper
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[800]!),
                  ),
                  child: Column(
                    children: [
                      _buildStepRow(
                        step: 1,
                        label: "Generating Markdown",
                        description: "Building report with images",
                        icon: LucideIcons.fileCode,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Container(
                          width: 2,
                          height: 20,
                          color: _currentStep > 1 ? AppColors.primaryRed : Colors.grey[800],
                        ),
                      ),
                      _buildStepRow(
                        step: 2,
                        label: "Uploading to Fileverse",
                        description: "Syncing to blockchain",
                        icon: LucideIcons.upload,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Container(
                          width: 2,
                          height: 20,
                          color: _currentStep > 2 ? AppColors.primaryRed : Colors.grey[800],
                        ),
                      ),
                      _buildStepRow(
                        step: 3,
                        label: "Saving to History",
                        description: "Storing in your account",
                        icon: LucideIcons.database,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Live log
                if (_generationLogs.isNotEmpty)
                  Container(
                    height: 60,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[900]!),
                    ),
                    child: Text(
                      _generationLogs.last,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow({
    required int step,
    required String label,
    required String description,
    required IconData icon,
  }) {
    final isActive = _currentStep == step;
    final isDone = _currentStep > step;
    final isPending = _currentStep < step;

    return Row(
      children: [
        // Step indicator circle
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? AppColors.primaryRed
                : isActive
                    ? AppColors.primaryRed.withOpacity(0.2)
                    : Colors.grey[900],
            border: Border.all(
              color: isDone || isActive ? AppColors.primaryRed : Colors.grey[700]!,
              width: 2,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(LucideIcons.check, color: Colors.white, size: 16)
                : isActive
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryRed,
                        ),
                      )
                    : Icon(icon, color: Colors.grey[600], size: 14),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isPending ? Colors.grey[600] : Colors.white,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        if (isDone)
          const Text(
            "Done",
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (isActive)
          Text(
            "In Progress",
            style: TextStyle(
              color: AppColors.primaryRed,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
