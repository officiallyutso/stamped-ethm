import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Save a new report under users/{uid}/reports
  Future<String> saveReport({
    required String fileverseLink,
    required String title,
    required int imageCount,
    String? ddocId,
    String? markdownContent,
    List<String>? imageIds,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not authenticated");

    final reportData = {
      'fileverseLink': fileverseLink,
      'ddocId': ddocId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'reportTitle': title,
      'imageCount': imageCount,
      'userId': user.uid,
      'userName': user.displayName ?? user.email ?? 'Unknown',
      if (markdownContent != null) 'markdownContent': markdownContent,
      if (imageIds != null) 'imageIds': imageIds,
      'status': 'generated',
    };

    final docRef = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('reports')
        .add(reportData);
    
    return docRef.id;
  }

  /// Get all reports for the current user, ordered by creation date
  Future<List<Map<String, dynamic>>> getReports() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not authenticated");

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Update an existing report (e.g., after re-upload)
  Future<void> updateReport({
    required String reportId,
    String? fileverseLink,
    String? ddocId,
    String? title,
    String? markdownContent,
    int? imageCount,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not authenticated");

    final updateData = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (fileverseLink != null) updateData['fileverseLink'] = fileverseLink;
    if (ddocId != null) updateData['ddocId'] = ddocId;
    if (title != null) updateData['reportTitle'] = title;
    if (markdownContent != null) updateData['markdownContent'] = markdownContent;
    if (imageCount != null) updateData['imageCount'] = imageCount;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('reports')
        .doc(reportId)
        .update(updateData);
  }

  /// Upload a report link to a workspace project
  Future<void> uploadReportToProject({
    required String reportId,
    required String projectId,
    required String workspaceId,
    required String fileverseLink,
    required String reportTitle,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not authenticated");

    await _firestore.collection('project_reports').add({
      'reportId': reportId,
      'projectId': projectId,
      'workspaceId': workspaceId,
      'fileverseLink': fileverseLink,
      'reportTitle': reportTitle,
      'uploadedBy': user.uid,
      'uploaderName': user.displayName ?? user.email ?? 'Unknown',
      'uploadedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get reports uploaded to a specific project
  Stream<List<Map<String, dynamic>>> getProjectReports(String projectId) {
    return _firestore
        .collection('project_reports')
        .where('projectId', isEqualTo: projectId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }
}
