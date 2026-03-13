import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveReport({
    required String fileverseLink,
    required String title,
    required int imageCount,
    List<String>? imageIds,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not authenticated");

    final reportData = {
      'fileverseLink': fileverseLink,
      'createdAt': FieldValue.serverTimestamp(),
      'reportTitle': title,
      'imageCount': imageCount,
      if (imageIds != null) 'imageIds': imageIds,
      'status': 'generated',
    };

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('reports')
        .add(reportData);
  }
}
