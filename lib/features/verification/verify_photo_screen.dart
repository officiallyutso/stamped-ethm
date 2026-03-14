import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_exif/native_exif.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import 'package:stamped/core/theme/app_colors.dart';

class VerifyPhotoScreen extends StatefulWidget {
  const VerifyPhotoScreen({super.key});

  @override
  State<VerifyPhotoScreen> createState() => _VerifyPhotoScreenState();
}

class _VerifyPhotoScreenState extends State<VerifyPhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isVerifying = false;
  
  String? _extractedCaptureId;
  Map<String, dynamic>? _extractedLocation;
  
  bool _isVerified = false;
  Map<String, dynamic>? _firestoreData;
  String _statusMessage = 'Select an image to verify its authenticity.';

  Future<void> _pickAndVerifyImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);
        _isVerifying = true;
        _isVerified = false;
        _extractedCaptureId = null;
        _extractedLocation = null;
        _firestoreData = null;
        _statusMessage = 'Extracting metadata...';
      });

      // 1. Extract EXIF
      final exif = await Exif.fromPath(image.path);
      final descriptionStr = await exif.getAttribute('ImageDescription');
      await exif.close();

      if (descriptionStr == null || descriptionStr.isEmpty) {
        setState(() {
          _isVerifying = false;
          _statusMessage = 'Image is not verified by Stamped.';
        });
        return;
      }

      final Map<String, dynamic> metadata = jsonDecode(descriptionStr);
      final captureId = metadata['captureId'];

      if (captureId == null) {
        setState(() {
          _isVerifying = false;
          _statusMessage = 'Metadata exists but no Capture ID was found.';
        });
        return;
      }

      setState(() {
        _extractedCaptureId = captureId;
        _extractedLocation = metadata;
        _statusMessage = 'Capture ID found: $captureId\nVerifying with database...';
      });

      // 2. Query Firestore (using collectionGroup to search across all users' captures)
      final querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('captures')
          .where('captureId', isEqualTo: captureId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _isVerifying = false;
          _statusMessage = 'Image is NOT verified.\nCapture ID was found but no matching record exists in the database.';
        });
        return;
      }

      final docData = querySnapshot.docs.first.data();

      setState(() {
        _isVerifying = false;
        _isVerified = true;
        _firestoreData = docData;
        _statusMessage = 'Image Verified! Authentic capture record found.';
      });

    } catch (e) {
      setState(() {
        _isVerifying = false;
        _statusMessage = 'Error during verification: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Verify Photo Status', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header text
              const Text(
                'Verify Authenticity',
                style: TextStyle(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Upload an image to cryptographically verify its origin and metadata against the Stamped database.',
                style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Main Image Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Image Preview
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade50,
                        image: _selectedImage != null
                            ? DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _selectedImage == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.imagePlus, size: 48, color: Colors.black26),
                                SizedBox(height: 12),
                                Text('No image selected', style: TextStyle(color: Colors.black38, fontWeight: FontWeight.w500)),
                              ],
                            )
                          : null,
                    ),
                    const SizedBox(height: 20),
                    
                    // Action Button
                    ElevatedButton.icon(
                      onPressed: _isVerifying ? null : _pickAndVerifyImage,
                      icon: _isVerifying 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(LucideIcons.scanLine, color: Colors.white, size: 20),
                      label: Text(
                        _isVerifying ? 'Analyzing Metadata...' : 'Select & Verify Photo',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 54),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Status indicator (Animated)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: SizeTransition(sizeFactor: animation, child: child));
                },
                child: _buildStatusWidget(),
              ),

              const SizedBox(height: 24),

              // Data Panel
              if (_isVerified && _firestoreData != null)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildVerificationPanel(),
                ),
                
              const SizedBox(height: 48), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusWidget() {
    if (_selectedImage == null && !_isVerifying) return const SizedBox.shrink();

    Color statusColor;
    IconData statusIcon;
    Color bgColor;
    
    if (_isVerifying) {
      statusColor = Colors.orange.shade700;
      bgColor = Colors.orange.shade50;
      statusIcon = LucideIcons.loader;
    } else if (_isVerified) {
      statusColor = Colors.green.shade700;
      bgColor = Colors.green.shade50;
      statusIcon = LucideIcons.badgeCheck;
    } else {
      statusColor = Colors.red.shade700;
      bgColor = Colors.red.shade50;
      statusIcon = LucideIcons.shieldAlert;
    }

    return Container(
      key: ValueKey<bool>(_isVerified || _isVerifying),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: statusColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _statusMessage,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.03),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.fileCode2, color: AppColors.primaryRed, size: 20),
              const SizedBox(width: 10),
              const Text('Embedded Metadata', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow('Verification ID', _extractedCaptureId ?? 'N/A', LucideIcons.hash),
          const Divider(height: 24, thickness: 0.5),
          _buildDetailRow('Timestamp', _firestoreData!['timestamp']?.toDate()?.toString() ?? 'N/A', LucideIcons.clock),
          const Divider(height: 24, thickness: 0.5),
          _buildDetailRow('Coordinates', '${_firestoreData!['location']?['latitude']?.toStringAsFixed(4) ?? 'N/A'}, ${_firestoreData!['location']?['longitude']?.toStringAsFixed(4) ?? 'N/A'}', LucideIcons.mapPin),
          const Divider(height: 24, thickness: 0.5),
          _buildDetailRow('Capture Lens', _firestoreData!['cameraDirection']?.toString().split('.').last.toUpperCase() ?? 'N/A', LucideIcons.aperture),
          const Divider(height: 24, thickness: 0.5),
          _buildDetailRow('Exposure bias', _firestoreData!['exposure']?.toString() ?? 'N/A', LucideIcons.sunMedium),
          
          const SizedBox(height: 24),
          const Text('Integrity Hash', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              _firestoreData!['imageHash'] ?? 'N/A', 
              style: TextStyle(color: Colors.green.shade700, fontSize: 11, fontFamily: 'monospace', letterSpacing: 1.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.black45, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
