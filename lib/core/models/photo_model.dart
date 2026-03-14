import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoModel {
  final String id;
  final String cloudinaryUrl;
  final String uploaderId;
  final String workspaceId;
  final String? projectId;
  final DateTime timestamp;

  final double? latitude;
  final double? longitude;
  final double? altitude;
  final double? accuracy;
  final double? speed;
  final String? cameraDirection;
  final double? zoomLevel;
  final double? exposure;
  final String? imageHash;
  final String? captureId;

  PhotoModel({
    required this.id,
    required this.cloudinaryUrl,
    required this.uploaderId,
    required this.workspaceId,
    this.projectId,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.altitude,
    this.accuracy,
    this.speed,
    this.cameraDirection,
    this.zoomLevel,
    this.exposure,
    this.imageHash,
    this.captureId,
  });

  factory PhotoModel.fromMap(Map<String, dynamic> data, String documentId) {
    return PhotoModel(
      id: documentId,
      cloudinaryUrl: data['cloudinaryUrl'] ?? '',
      uploaderId: data['uploaderId'] ?? '',
      workspaceId: data['workspaceId'] ?? '',
      projectId: data['projectId'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      altitude: (data['altitude'] as num?)?.toDouble(),
      accuracy: (data['accuracy'] as num?)?.toDouble(),
      speed: (data['speed'] as num?)?.toDouble(),
      cameraDirection: data['cameraDirection'] as String?,
      zoomLevel: (data['zoomLevel'] as num?)?.toDouble(),
      exposure: (data['exposure'] as num?)?.toDouble(),
      imageHash: data['imageHash'] as String?,
      captureId: data['captureId'] as String?,
    );
  }

  factory PhotoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PhotoModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'cloudinaryUrl': cloudinaryUrl,
      'uploaderId': uploaderId,
      'workspaceId': workspaceId,
      'projectId': projectId,
      'timestamp': Timestamp.fromDate(timestamp),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (speed != null) 'speed': speed,
      if (cameraDirection != null) 'cameraDirection': cameraDirection,
      if (zoomLevel != null) 'zoomLevel': zoomLevel,
      if (exposure != null) 'exposure': exposure,
      if (imageHash != null) 'imageHash': imageHash,
      if (captureId != null) 'captureId': captureId,
    };
  }
}
