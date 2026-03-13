import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as http;

import '../../bitgo_mpc/bitgo_config.dart';

class BackendApiService {
  // Use config-defined base URL
  final String _baseUrl = BitGoConfig.backendBaseUrl; 

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
}
