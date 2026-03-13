import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String workspaceId;
  final String name;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  ProjectModel({
    required this.id,
    required this.workspaceId,
    required this.name,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ProjectModel(
      id: documentId,
      workspaceId: data['workspaceId'] ?? '',
      name: data['name'] ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workspaceId': workspaceId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
