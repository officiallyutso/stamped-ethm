import 'package:cloud_firestore/cloud_firestore.dart';

class WorkspaceModel {
  final String id;
  final String name;
  final String ownerId;
  final List<String> memberIds;
  final String? joinCode;
  final DateTime createdAt;

  WorkspaceModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.memberIds,
    this.joinCode,
    required this.createdAt,
  });

  factory WorkspaceModel.fromMap(Map<String, dynamic> data, String documentId) {
    return WorkspaceModel(
      id: documentId,
      name: data['name'] ?? '',
      ownerId: data['ownerId'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      joinCode: data['joinCode'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'joinCode': joinCode,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
