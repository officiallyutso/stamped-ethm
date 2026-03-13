// lib/bitgo_mpc/commitment_service.dart

import 'dart:convert';
import 'package:crypto/crypto.dart';

class CommitmentService {
  /// Generates a SHA-256 cryptographic commitment.
  /// 
  /// The commitment is created by hashing the provided [data],
  /// the current [timestamp], and the [deviceId].
  Map<String, String> generateCommitment(String data, String deviceId) {
    final timestamp = DateTime.now().toIso8601String();
    
    // Concatenate data exactly as required: data + timestamp + deviceID
    final rawString = '$data$timestamp$deviceId';
    
    // Generate SHA-256 hash
    final bytes = utf8.encode(rawString);
    final digest = sha256.convert(bytes);
    final commitmentHash = digest.toString();

    return {
      'commitmentHash': commitmentHash,
      'timestamp': timestamp,
    };
  }
}
