import 'dart:convert';
import 'package:http/http.dart' as http;

class FileverseService {
  // Using the Cloudflare worker API defined by the user
  static const String _baseUrl = 'https://fileverse-cloudflare-worker.utsosarkar1.workers.dev/api/ddocs';

  /// Creates a new dDoc on Fileverse returning the document ID / URL
  Future<Map<String, dynamic>> createDocument({
    required String title,
    required String content,
    required String apiKey,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('\$_baseUrl?apiKey=\$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'content': content,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data; // Typically contains the CID or document ID and URL
      } else {
        throw Exception('Failed to create Fileverse doc: \${response.body}');
      }
    } catch (e) {
      print('Fileverse API Error: \$e');
      rethrow;
    }
  }
}
