import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stamped/core/theme/app_colors.dart';
import 'package:stamped/core/models/photo_model.dart';
import 'package:stamped/features/workspace/workspace_provider.dart';

import 'package:gal/gal.dart';

class NetworkPhotoViewerScreen extends StatefulWidget {
  final PhotoModel photo;

  const NetworkPhotoViewerScreen({super.key, required this.photo});

  @override
  State<NetworkPhotoViewerScreen> createState() => _NetworkPhotoViewerScreenState();
}

class _NetworkPhotoViewerScreenState extends State<NetworkPhotoViewerScreen> {
  String _uploaderName = 'Loading...';
  bool _isSharing = false;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _fetchUploaderName();
  }

  Future<void> _fetchUploaderName() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.photo.uploaderId).get();
      if (doc.exists && mounted) {
        setState(() {
          _uploaderName = doc.data()?['displayName'] ?? 'Unknown User';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _uploaderName = 'Unknown User');
    }
  }

  Future<void> _shareImage(BuildContext context) async {
    setState(() => _isSharing = true);
    try {
      final response = await http.get(Uri.parse(widget.photo.cloudinaryUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/temp_${widget.photo.id}.jpg');
        await file.writeAsBytes(response.bodyBytes);
        
        final xFile = XFile(file.path);
        final text = widget.photo.latitude != null 
            ? 'Check out this verified photo from Stamped! Lat: ${widget.photo.latitude}, Lon: ${widget.photo.longitude}'
            : 'Check out this verified photo from Stamped!';
        await Share.shareXFiles([xFile], text: text);
      }
    } catch (e) {
      debugPrint("Error sharing: $e");
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _downloadImage(BuildContext context) async {
    setState(() => _isDownloading = true);
    try {
      final response = await http.get(Uri.parse(widget.photo.cloudinaryUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/download_${widget.photo.id}.jpg');
        await file.writeAsBytes(response.bodyBytes);
        
        await Gal.putImage(file.path);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Saved to Gallery!'), duration: Duration(seconds: 2))
           );
        }
      }
    } catch (e) {
      debugPrint("Error downloading: $e");
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Failed to save image.'), duration: Duration(seconds: 2))
         );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
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
                child: Hero(
                  tag: 'network_photo_\${widget.photo.id}',
                  child: Image.network(widget.photo.cloudinaryUrl, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          _buildMetadataPanel(context),
        ],
      ),
    );
  }

  Widget _buildMetadataPanel(BuildContext context) {
    // Format timestamp nicely
    final dt = widget.photo.timestamp.toLocal();
    final timeFormatted = "${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}";

    final hasLocation = widget.photo.latitude != null && widget.photo.longitude != null;
    final lat = hasLocation ? widget.photo.latitude!.toStringAsFixed(6) : 'N/A';
    final lon = hasLocation ? widget.photo.longitude!.toStringAsFixed(6) : 'N/A';
    final alt = widget.photo.altitude != null ? '${widget.photo.altitude!.toStringAsFixed(1)} m' : 'N/A';
    final acc = widget.photo.accuracy != null ? '${widget.photo.accuracy!.toStringAsFixed(1)} m' : 'N/A';
    final speed = widget.photo.speed != null ? '${widget.photo.speed!.toStringAsFixed(1)} m/s' : 'N/A';
    
    // extra fields we captured
    final cameraDir = widget.photo.cameraDirection?.replaceAll('CameraLensDirection.', '') ?? 'N/A';
    final zoom = widget.photo.zoomLevel != null ? '${widget.photo.zoomLevel!.toStringAsFixed(1)}x' : 'N/A';
    final exposure = widget.photo.exposure != null ? '${widget.photo.exposure!.toStringAsFixed(1)}' : 'N/A';

    return SafeArea(
      bottom: true,
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Capture Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: [
                  const Icon(LucideIcons.user, color: Colors.white54, size: 14),
                  const SizedBox(width: 4),
                  Text(_uploaderName, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              )
            ],
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
              Expanded(child: _buildInfoItem(LucideIcons.mountain, 'Altitude', alt)),
              Expanded(child: _buildInfoItem(LucideIcons.crosshair, 'Accuracy', acc)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInfoItem(LucideIcons.gauge, 'Speed', speed)),
              Expanded(child: _buildInfoItem(LucideIcons.clock, 'Timestamp', timeFormatted)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInfoItem(LucideIcons.camera, 'Lens', cameraDir)),
              Expanded(child: _buildInfoItem(LucideIcons.zoomIn, 'Zoom', zoom)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInfoItem(LucideIcons.sun, 'Exposure', exposure)),
              Expanded(child: _buildInfoItem(LucideIcons.hash, 'Hash', widget.photo.imageHash != null ? widget.photo.imageHash!.substring(0, 8) + '...' : 'N/A')),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: hasLocation ? () => _openMap(lat, lon) : null,
                  icon: const Icon(LucideIcons.map, size: 16),
                  label: const Text('Map', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isDownloading ? null : () => _downloadImage(context),
                  icon: _isDownloading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(LucideIcons.download, size: 16),
                  label: Text(_isDownloading ? '...' : 'Save', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSharing ? null : () => _shareImage(context),
                  icon: _isSharing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Icon(LucideIcons.share2, size: 16),
                  label: Text(_isSharing ? '...' : 'Share', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
