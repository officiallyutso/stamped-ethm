import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../models/workspace_model.dart';
import '../models/project_model.dart';
import '../models/photo_model.dart';

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

  // Helper
  String _generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }
}
