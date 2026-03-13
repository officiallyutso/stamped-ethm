import 'package:cloud_firestore/cloud_firestore.dart';

class CaptureMetadata {
  final String captureId;
  final DateTime timestamp;
  final String? cameraDirection;
  final double? zoomLevel;
  final double? exposure;
  final String imageHash;
  final Map<String, dynamic>? location;

  CaptureMetadata({
    required this.captureId,
    required this.timestamp,
    this.cameraDirection,
    this.zoomLevel,
    this.exposure,
    required this.imageHash,
    this.location,
  });

  factory CaptureMetadata.fromFirestore(Map<String, dynamic> data) {
    return CaptureMetadata(
      captureId: data['captureId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cameraDirection: data['cameraDirection'],
      zoomLevel: (data['zoomLevel'] as num?)?.toDouble(),
      exposure: (data['exposure'] as num?)?.toDouble(),
      imageHash: data['imageHash'] ?? '',
      location: data['location'] as Map<String, dynamic>?,
    );
  }
}
