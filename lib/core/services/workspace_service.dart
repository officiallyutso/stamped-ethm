import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../models/workspace_model.dart';
import '../models/project_model.dart';
import '../models/photo_model.dart';
import '../models/attendance_model.dart';

class WorkspaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // USER OPERATIONS
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  // WORKSPACE OPERATIONS
  
  Future<WorkspaceModel> createWorkspace(String name, String ownerId) async {
    final String joinCode = _generateJoinCode();
    
    final docRef = _firestore.collection('workspaces').doc();
    final workspace = WorkspaceModel(
      id: docRef.id,
      name: name,
      ownerId: ownerId,
      memberIds: [ownerId],
      joinCode: joinCode,
      createdAt: DateTime.now(),
    );
    
    await docRef.set(workspace.toMap());
    return workspace;
  }

  Future<WorkspaceModel?> joinWorkspace(String joinCode, String userId) async {
    final querySnapshot = await _firestore
        .collection('workspaces')
        .where('joinCode', isEqualTo: joinCode)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;

    final doc = querySnapshot.docs.first;
    final workspace = WorkspaceModel.fromMap(doc.data(), doc.id);

    if (!workspace.memberIds.contains(userId)) {
      await doc.reference.update({
        'memberIds': FieldValue.arrayUnion([userId])
      });
      // Optionally re-fetch to get updated state, but we can just add it locally
      workspace.memberIds.add(userId); 
    }
    
    return workspace;
  }

  Future<void> removeMember(String workspaceId, String memberId) async {
    await _firestore.collection('workspaces').doc(workspaceId).update({
      'memberIds': FieldValue.arrayRemove([memberId])
    });
  }

  Stream<List<WorkspaceModel>> getUserWorkspaces(String userId) {
    return _firestore
        .collection('workspaces')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkspaceModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // PROJECT OPERATIONS

  Future<ProjectModel> createProject(String workspaceId, String name, {double? latitude, double? longitude}) async {
    final docRef = _firestore.collection('projects').doc();
    final project = ProjectModel(
      id: docRef.id,
      workspaceId: workspaceId,
      name: name,
      latitude: latitude,
      longitude: longitude,
      createdAt: DateTime.now(),
    );
    
    await docRef.set(project.toMap());
    return project;
  }

  Stream<List<ProjectModel>> getWorkspaceProjects(String workspaceId) {
    return _firestore
        .collection('projects')
        .where('workspaceId', isEqualTo: workspaceId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // PHOTO OPERATIONS

  Future<PhotoModel> addPhotoRecord(String cloudinaryUrl, String uploaderId, String workspaceId, {
    String? projectId,
    double? latitude,
    double? longitude,
    double? altitude,
    double? accuracy,
    double? speed,
    String? cameraDirection,
    double? zoomLevel,
    double? exposure,
    String? imageHash,
    String? captureId,
  }) async {
    final docRef = _firestore.collection('photos').doc();
    final photo = PhotoModel(
      id: docRef.id,
      cloudinaryUrl: cloudinaryUrl,
      uploaderId: uploaderId,
      workspaceId: workspaceId,
      projectId: projectId,
      timestamp: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      accuracy: accuracy,
      speed: speed,
      cameraDirection: cameraDirection,
      zoomLevel: zoomLevel,
      exposure: exposure,
      imageHash: imageHash,
      captureId: captureId,
    );
    
    await docRef.set(photo.toMap());
    return photo;
  }

  Stream<List<PhotoModel>> getWorkspacePhotos(String workspaceId) {
    return _firestore
        .collection('photos')
        .where('workspaceId', isEqualTo: workspaceId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PhotoModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> deletePhoto(String photoId) async {
    await _firestore.collection('photos').doc(photoId).delete();
  }

  Future<void> movePhoto(String photoId, String newProjectId) async {
    await _firestore.collection('photos').doc(photoId).update({
      'projectId': newProjectId,
    });
  }

  // ATTENDANCE OPERATIONS

  Future<AttendanceModel> addAttendanceRecord({
    required String userId,
    required String workspaceId,
    required String projectId,
    required AttendanceType type,
    String? photoUrl,
    double? latitude,
    double? longitude,
  }) async {
    final docRef = _firestore.collection('attendance').doc();
    final record = AttendanceModel(
      id: docRef.id,
      userId: userId,
      workspaceId: workspaceId,
      projectId: projectId,
      type: type,
      photoUrl: photoUrl,
      timestamp: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
    );
    await docRef.set(record.toMap());
    return record;
  }

  Stream<List<AttendanceModel>> getProjectAttendance(String projectId) {
    return _firestore
        .collection('attendance')
        .where('projectId', isEqualTo: projectId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromFirestore(doc))
            .toList());
  }

  Future<AttendanceModel?> getLatestAttendance(String userId, String projectId) async {
    final snapshot = await _firestore
        .collection('attendance')
        .where('userId', isEqualTo: userId)
        .where('projectId', isEqualTo: projectId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return AttendanceModel.fromFirestore(snapshot.docs.first);
  }

  Future<bool> hasProjectAttendance(String projectId) async {
    final snapshot = await _firestore
        .collection('attendance')
        .where('projectId', isEqualTo: projectId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  // Helper
  String _generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  // NOTE: updateUserPayoutAddress / getUserPayoutAddress removed.
  // User wallets are now auto-generated via BackendApiService.createUserWallet()
}
