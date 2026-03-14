import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../bitgo_mpc/bitgo_config.dart';

class BackendApiService {
  // Use config-defined base URL (points to http://localhost:4000/api)
  final String _baseUrl = BitGoConfig.backendBaseUrl; 

  // ============================================================
  // Fileverse (existing)
  // ============================================================

  Future<Map<String, dynamic>> createFileverseDoc({
    required String title,
    required String content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/fileverse/createFileverseDoc'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'content': content,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Backend Error: ${response.body}');
      }
    } catch (e) {
      print('Backend API Error: $e');
      rethrow;
    }
  }

  // ============================================================
  // Workspace Wallet
  // ============================================================

  /// Create a BitGo wallet for a workspace
  Future<Map<String, dynamic>> createWorkspaceWallet({
    required String workspaceId,
    required String workspaceName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/workspace/create-wallet'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'workspaceId': workspaceId,
          'workspaceName': workspaceName,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Create wallet error: ${response.body}');
      }
    } catch (e) {
      print('Create wallet error: $e');
      rethrow;
    }
  }

  /// Fetch live wallet balance from BitGo via backend
  Future<Map<String, dynamic>> getWalletBalance({
    required String workspaceId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/workspace/wallet-balance?workspaceId=$workspaceId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Get balance error: ${response.body}');
      }
    } catch (e) {
      print('Get balance error: $e');
      rethrow;
    }
  }

  /// Send payout from workspace wallet to user address
  Future<Map<String, dynamic>> sendPayout({
    required String workspaceId,
    required String userId,
    required String toAddress,
    required String amountWei,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/workspace/send-payout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'workspaceId': workspaceId,
          'userId': userId,
          'toAddress': toAddress,
          'amountWei': amountWei,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Send payout error: ${response.body}');
      }
    } catch (e) {
      print('Send payout error: $e');
      rethrow;
    }
  }

  // ============================================================
  // Earnings
  // ============================================================

  /// Get earnings summary for all users in a workspace
  Future<List<dynamic>> getWorkspaceEarnings({
    required String workspaceId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/workspace/earnings?workspaceId=$workspaceId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Get earnings error: ${response.body}');
      }
    } catch (e) {
      print('Get earnings error: $e');
      rethrow;
    }
  }

  /// Calculate earnings for a specific user over a date range
  Future<List<dynamic>> calculateEarnings({
    required String workspaceId,
    required String userId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/workspace/calculate-earnings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'workspaceId': workspaceId,
          'userId': userId,
          'startDate': startDate,
          'endDate': endDate,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Calculate earnings error: ${response.body}');
      }
    } catch (e) {
      print('Calculate earnings error: $e');
      rethrow;
    }
  }

  /// Get payout history for a workspace
  Future<List<dynamic>> getPayoutHistory({
    required String workspaceId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/workspace/payout-history?workspaceId=$workspaceId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Payout history error: ${response.body}');
      }
    } catch (e) {
      print('Payout history error: $e');
      rethrow;
    }
  }

  // ============================================================
  // User Wallet (auto-generated)
  // ============================================================

  /// Create a BitGo wallet for a user in a workspace
  Future<Map<String, dynamic>> createUserWallet({
    required String workspaceId,
    required String userId,
    required String displayName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/workspace/create-user-wallet'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'workspaceId': workspaceId,
          'userId': userId,
          'displayName': displayName,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Create user wallet error: ${response.body}');
      }
    } catch (e) {
      print('Create user wallet error: $e');
      rethrow;
    }
  }

  /// Get user's auto-generated wallet info in a workspace
  Future<Map<String, dynamic>?> getUserWallet({
    required String workspaceId,
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/workspace/user-wallet?workspaceId=$workspaceId&userId=$userId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Get user wallet error: ${response.body}');
      }
    } catch (e) {
      print('Get user wallet error: $e');
      rethrow;
    }
  }
}
