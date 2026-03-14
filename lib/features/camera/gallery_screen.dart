import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stamped/features/camera/camera_provider.dart';

import 'dart:io';
import 'package:native_exif/native_exif.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/services/backend_api_service.dart';
import 'package:stamped/features/workspace/workspace_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stamped/core/theme/app_colors.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final Set<int> _selectedIndices = {};
  bool _isGenerating = false;

  bool get _isSelectionMode => _selectedIndices.isNotEmpty;

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _selectAll(int totalCount) {
    setState(() {
      if (_selectedIndices.length == totalCount) {
        _selectedIndices.clear();
      } else {
        for (int i = 0; i < totalCount; i++) {
          _selectedIndices.add(i);
        }
      }
    });
  }

  Future<void> _generateZkProofs(CameraProvider provider) async {
    final workspaceProvider = Provider.of<WorkspaceProvider>(context, listen: false);
    final workspace = workspaceProvider.currentWorkspace;
    final user = FirebaseAuth.instance.currentUser;

    if (workspace == null || user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workspace or User not found.')),
      );
      return;
    }

    setState(() => _isGenerating = true);
    final apiService = BackendApiService();
    
    int successCount = 0;
    int failCount = 0;
    String? _lastTxId;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final List<FileSystemEntity> files = directory.listSync();
      List<File> imageFiles = files
          .whereType<File>()
          .where((file) => file.path.endsWith('.jpg'))
          .toList()
        ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      List<String> validHashes = [];

      // Collect all hashes first
      for (int index in _selectedIndices) {
        if (index >= imageFiles.length) continue;
        
        File selectedFile = imageFiles[index];
        final exif = await Exif.fromPath(selectedFile.path);
        final imageHash = await exif.getAttribute('UserComment');
        await exif.close();

        if (imageHash == null || imageHash.isEmpty) {
          debugPrint("No hash found in EXIF for image $index");
          failCount++;
          continue;
        }

        validHashes.add(imageHash);
      }

      if (validHashes.isNotEmpty) {
        // Fetch user's BitGo wallet address for this workspace
        final userWalletData = await apiService.getUserWallet(
          workspaceId: workspace.id,
          userId: user.uid,
        );

        if (userWalletData == null || userWalletData['walletAddress'] == null) {
          throw Exception("User wallet not found. Please try again later.");
        }

        final userAddress = userWalletData['walletAddress'];

        // Send hashes on chain
        final result = await apiService.generateOnChainProof(
          hashes: validHashes,
          workspaceId: workspace.id,
          userAddress: userAddress,
        );

        final txId = result['txId'] ?? 'Unknown TX';
        _lastTxId = txId;
        debugPrint("Proof generated on-chain: $txId");

        // Update Firestore for both personal captures and global photos
        for (String hash in validHashes) {
          // 1. Update personal captures
          final capturesQuery = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('captures')
              .where('imageHash', isEqualTo: hash)
              .get();
              
          for (var doc in capturesQuery.docs) {
            await doc.reference.update({'txId': txId});
          }

          // 2. Update global photos
          final photosQuery = await FirebaseFirestore.instance
              .collection('photos')
              .where('imageHash', isEqualTo: hash)
              .get();
              
          for (var doc in photosQuery.docs) {
            await doc.reference.update({'txId': txId});
          }
        }
        
        successCount = validHashes.length;
      }
    } catch (e) {
      debugPrint("Error generating proofs: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate proofs: $e')),
        );
      }
    } finally {
      setState(() {
        _isGenerating = false;
        _selectedIndices.clear(); // Exit selection mode
      });
      
      if (mounted && successCount > 0) {
        // Find the last known txId to display
        final displayTxId = '$_lastTxId'.length > 15 ? '${'$_lastTxId'.substring(0, 15)}...' : '$_lastTxId';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Proof generated! Transaction ID: $displayTxId'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, provider, child) {
        final totalImages = provider.galleryFiles.length;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _isSelectionMode ? '${_selectedIndices.length} Selected' : 'Recent Captures',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            leading: _isSelectionMode
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _selectedIndices.clear()),
                  )
                : null,
            actions: [
              if (totalImages > 0)
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: () => _selectAll(totalImages),
                  tooltip: 'Select All',
                ),
            ],
          ),
          backgroundColor: Colors.grey.shade100,
          body: totalImages == 0
              ? const Center(
                  child: Text(
                    'No images captured yet.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                )
              : Stack(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseAuth.instance.currentUser == null
                          ? null
                          : FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('captures')
                              .snapshots(),
                      builder: (context, snapshot) {
                        final Set<String> verifiedCaptureIds = {};
                        if (snapshot.hasData) {
                          for (var doc in snapshot.data!.docs) {
                            final data = doc.data() as Map<String, dynamic>?;
                            if (data != null && data.containsKey('txId') && data['txId'] != null) {
                              verifiedCaptureIds.add(doc.id);
                            }
                          }
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: totalImages,
                          itemBuilder: (context, index) {
                            final file = provider.galleryFiles[index];
                            final captureId = file.path.split(Platform.pathSeparator).last.split('.').first;
                            final isVerified = verifiedCaptureIds.contains(captureId);
                            final isSelected = _selectedIndices.contains(index);
                            
                            return GestureDetector(
                              onLongPress: () {
                                if (!_isSelectionMode) {
                                  _toggleSelection(index);
                                }
                              },
                              onTap: () {
                                if (_isSelectionMode) {
                                  _toggleSelection(index);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullScreenImageViewer(imageFile: file),
                                    ),
                                  );
                                }
                              },
                              child: Hero(
                                tag: 'gallery_image_$index',
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        file,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    if (isVerified && !isSelected)
                                      Positioned(
                                        top: 4,
                                        left: 4,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryRed,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 1.5),
                                          ),
                                          child: const Icon(LucideIcons.check, size: 12, color: Colors.white),
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
                              ),
                            );
                          },
                        );
                      }
                    ),
                    if (_isGenerating)
                      Container(
                        color: Colors.black.withOpacity(0.6),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 16),
                              Text("Generating Proof...", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      )
                  ],
                ),
          floatingActionButton: _isSelectionMode && !_isGenerating
              ? FloatingActionButton.extended(
                  onPressed: () => _generateZkProofs(provider),
                  label: const Text('Generate Proof'),
                  icon: const Icon(LucideIcons.fingerprint),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                )
              : null,
        );
      },
    );
  }
}


class FullScreenImageViewer extends StatefulWidget {
  final File imageFile;

  const FullScreenImageViewer({super.key, required this.imageFile});

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  Map<String, dynamic>? _locationData;
  bool _isLoadingExif = true;
  String? _txId;
  String? _imageHash;

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    try {
      final exif = await Exif.fromPath(widget.imageFile.path);
      final desc = await exif.getAttribute('ImageDescription');
      final hash = await exif.getAttribute('UserComment');
      await exif.close();

      _imageHash = hash;

      if (desc != null && desc.isNotEmpty) {
        // Try parsing JSON
        final Map<String, dynamic> data = jsonDecode(desc);
        if (mounted) {
          setState(() {
            _locationData = data;
          });
        }
      }

      // Check Firestore for proof status if hash exists
      if (_imageHash != null && _imageHash!.isNotEmpty) {
        _checkProofStatus();
      }
    } catch (e) {
      debugPrint("Error reading EXIF location: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingExif = false;
        });
      }
    }
  }

  Future<void> _checkProofStatus() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('photos')
          .where('imageHash', isEqualTo: _imageHash)
          .limit(1)
          .get();
          
      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        if (data.containsKey('txId') && data['txId'] != null) {
          if (mounted) {
            setState(() {
              _txId = data['txId'];
            });
          }
        }
      } else {
        // Also check personal captures if not in global photos
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final capturesQuery = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('captures')
              .where('imageHash', isEqualTo: _imageHash)
              .limit(1)
              .get();
              
          if (capturesQuery.docs.isNotEmpty) {
            final data = capturesQuery.docs.first.data();
            if (data.containsKey('txId') && data['txId'] != null) {
              if (mounted) {
                setState(() {
                  _txId = data['txId'];
                });
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking proof status: $e");
    }
  }

  void _shareImage(BuildContext context) async {
    try {
      final xFile = XFile(widget.imageFile.path);
      final text = _locationData != null 
          ? 'Check out this verified photo from Stamped! Lat: ${_locationData!['latitude']}, Lon: ${_locationData!['longitude']}'
          : 'Check out this verified photo from Stamped!';
      await Share.shareXFiles([xFile], text: text);
    } catch (e) {
      debugPrint("Error sharing: $e");
    }
  }

  void _openMap(String lat, String lon) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Center(
                child: Image.file(widget.imageFile, fit: BoxFit.contain),
              ),
            ),
          ),
          if (!_isLoadingExif && _locationData != null)
            _buildMetadataPanel(context)
          else if (!_isLoadingExif && _locationData == null)
             Container(
              padding: const EdgeInsets.all(24),
              child: const Center(
                 child: Text('No location data found in EXIF.', style: TextStyle(color: Colors.white54))
              ),
             ),
        ],
      ),
    );
  }

  Widget _buildMetadataPanel(BuildContext context) {
    final lat = (_locationData!['latitude'] as num).toStringAsFixed(6);
    final lon = (_locationData!['longitude'] as num).toStringAsFixed(6);
    final alt = (_locationData!['altitude'] as num).toStringAsFixed(1);
    final acc = (_locationData!['accuracy'] as num).toStringAsFixed(1);
    final speed = (_locationData!['speed'] as num).toStringAsFixed(1);
    
    // Format timestamp nicely
    final timestampStr = _locationData!['timestamp'] as String;
    final dt = DateTime.tryParse(timestampStr)?.toLocal() ?? DateTime.now();
    final timeFormatted = "${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}";

    return SafeArea(
      bottom: true,
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24), // rely on SafeArea for bottom offset
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_txId != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryRed.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.checkCircle, color: AppColors.primaryRed, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Photo proven by Stamped',
                          style: TextStyle(
                            color: AppColors.primaryRed,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (_txId != null)
                          Text(
                            'TX: ${_txId!.substring(0, 6)}...${_txId!.substring(_txId!.length - 4)}',
                            style: TextStyle(
                              color: AppColors.primaryRed.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.externalLink, color: AppColors.primaryRed, size: 20),
                    onPressed: () {
                      final url = Uri.parse('https://holesky.etherscan.io/tx/$_txId');
                      launchUrl(url, mode: LaunchMode.externalApplication);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          const Text(
            'Location & Telemetry Data',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInfoItem(LucideIcons.mapPin, 'Latitude', lat)),
              Expanded(child: _buildInfoItem(LucideIcons.map, 'Longitude', lon)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInfoItem(LucideIcons.mountain, 'Altitude', '$alt m')),
              Expanded(child: _buildInfoItem(LucideIcons.crosshair, 'Accuracy', '$acc m')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInfoItem(LucideIcons.gauge, 'Speed', '$speed m/s')),
              Expanded(child: _buildInfoItem(LucideIcons.clock, 'Timestamp', timeFormatted)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openMap(lat, lon),
                  icon: const Icon(LucideIcons.map, size: 18),
                  label: const Text('View on Map', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareImage(context),
                  icon: const Icon(LucideIcons.share2, size: 18),
                  label: const Text('Share Image', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
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

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryRed, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

