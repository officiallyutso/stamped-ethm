import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class ZkProverService {
  static const MethodChannel _channel = MethodChannel('com.stamped/mopro');

  /// Hashes raw image bytes using SHA-256 and returns a short string
  /// representing the hash. This is used as the `imageHash` input.
  /// Note: Real poseidon hashing would be needed for absolute circuit compatibility, 
  /// but SHA-256 output trimmed or mapped to a field element is often used as a placeholder
  /// or if the circuit implements SHA256. 
  Future<String> hashImage(List<int> imageBytes) async {
    final digest = sha256.convert(imageBytes);
    // Return a hex string or decimal string depending on what Circom wants.
    // Assuming decimal representation of the first 31 bytes (fit in finite field)
    final hexString = digest.toString();
    final bigInt = BigInt.parse(hexString, radix: 16);
    // Ensure it fits in the bn128 scalar field (approx 2^254)
    final fieldElement = bigInt % BigInt.parse('21888242871839275222246405745257275088548364400416034343698204186575808495617');
    return fieldElement.toString();
  }

  /// Generates the Zero-Knowledge Proof natively via Mopro
  Future<Map<String, dynamic>> generateProof({
    required String imageHash,
    required String outputHash,
    required String pipelineHash,
    required String nullifier,
    required String embedKey,
    required String payload64,
    required String metadataHash,
  }) async {
    try {
      // Build the JSON string expected by Mopro's Circom JNI
      final Map<String, dynamic> inputs = {
        "outputHash": outputHash,
        "pipelineHash": pipelineHash,
        "nullifier": nullifier,
        "imageHash": imageHash,
        "embedKey": embedKey,
        "payload64": payload64,
        "metadataHash": metadataHash,
      };

      final String circuitInputsJson = jsonEncode(inputs);

      final result = await _channel.invokeMethod('generateProof', {
        'zkeyPath': 'assets/circuit.zkey',
        'circuitInputs': circuitInputsJson,
      });

      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      print("Failed to generate proof: \${e.message}");
      rethrow;
    }
  }
}
