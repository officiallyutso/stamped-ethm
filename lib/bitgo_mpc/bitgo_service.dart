// lib/bitgo_mpc/bitgo_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'bitgo_config.dart';

class BitGoService {
  /// Sends the cryptographic commitment to the backend signing service.
  /// 
  /// The backend service runs BitGo SDK/Express to handle the full 
  /// threshold signature protocol and returns the signed commitment.
  Future<Map<String, dynamic>> sendCommitmentForSigning({
    required String commitmentHash,
    required String deviceId,
    required String timestamp,
  }) async {
    final url = Uri.parse('${BitGoConfig.backendBaseUrl}/sign-commitment');

    print('[DEBUG] Sending request to: $url');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${BitGoConfig.backendAuthToken}',
      },
      body: jsonEncode({
        'commitmentHash': commitmentHash,
        'deviceWalletAddress': deviceId,
        'timestamp': DateTime.parse(timestamp).millisecondsSinceEpoch,
      }),
    ).timeout(const Duration(seconds: 30));

    print('[DEBUG] Received response with status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to sign commitment. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }
}
