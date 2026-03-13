// lib/bitgo_mpc/mpc_signing_service.dart

import 'bitgo_service.dart';
import 'commitment_service.dart';
import 'secure_key_storage.dart';

class SignedCommitment {
  final String commitmentHash;
  final String deviceWalletAddress;
  final String signature;
  final String timestamp;

  SignedCommitment({
    required this.commitmentHash,
    required this.deviceWalletAddress,
    required this.signature,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'SignedCommitment(hash: $commitmentHash, address: $deviceWalletAddress, signature: $signature, timestamp: $timestamp)';
  }
}

class MpcSigningService {
  final SecureKeyStorage _keyStorage = SecureKeyStorage();
  final CommitmentService _commitmentService = CommitmentService();
  final BitGoService _bitgoService = BitGoService();

  /// Orchestrates the MPC signing process.
  /// 
  /// 1. Generates the cryptographic commitment.
  /// 2. Retrieves the stored device ID.
  /// 3. Sends the commitment to the backend signing service via BitGoService.
  /// 4. Returns the SignedCommitment.
  Future<SignedCommitment> signCommitment(String data) async {
    // Step 1: Retrieve Device ID (creating a mock one if missing for prototype)
    String? deviceId = await _keyStorage.getDeviceId();
    if (deviceId == null) {
      deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await _keyStorage.saveDeviceId(deviceId);
    }

    // Step 2: Generate Commitment
    final commitmentResult = _commitmentService.generateCommitment(data, deviceId);
    final String commitmentHash = commitmentResult['commitmentHash']!;
    final String timestamp = commitmentResult['timestamp']!;

    // Step 3: Send to Backend for MPC Signing
    // The backend uses BitGo SDK to coordinate device share + BitGo share
    final response = await _bitgoService.sendCommitmentForSigning(
      commitmentHash: commitmentHash,
      deviceId: deviceId,
      timestamp: timestamp,
    );

    // Step 4: Parse final signed output from backend
    return SignedCommitment(
      commitmentHash: response['commitmentHash']?.toString() ?? commitmentHash,
      deviceWalletAddress: response['deviceWalletAddress']?.toString() ?? 'address_not_provided',
      signature: response['signature']?.toString() ?? 'signature_not_provided',
      timestamp: response['timestamp']?.toString() ?? timestamp,
    );
  }
}
