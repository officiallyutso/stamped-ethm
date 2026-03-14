import 'package:cloud_firestore/cloud_firestore.dart';

enum AttendanceType {
  timeIn,
  timeOut,
  breakStart,
  breakEnd,
}

class AttendanceModel {
  final String id;
  final String userId;
  final String workspaceId;
  final String projectId;
  final AttendanceType type;
  final String? photoUrl;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.workspaceId,
    required this.projectId,
    required this.type,
    this.photoUrl,
    required this.timestamp,
    this.latitude,
    this.longitude,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> data, String documentId) {
    return AttendanceModel(
      id: documentId,
      userId: data['userId'] ?? '',
      workspaceId: data['workspaceId'] ?? '',
      projectId: data['projectId'] ?? '',
      type: AttendanceType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => AttendanceType.timeIn,
      ),
      photoUrl: data['photoUrl'] as String?,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }

  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'workspaceId': workspaceId,
      'projectId': projectId,
      'type': type.name,
      'photoUrl': photoUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  String get typeLabel {
    switch (type) {
      case AttendanceType.timeIn:
        return 'Time In';
      case AttendanceType.timeOut:
        return 'Time Out';
      case AttendanceType.breakStart:
        return 'Break Start';
      case AttendanceType.breakEnd:
        return 'Break End';
    }
  }
}
