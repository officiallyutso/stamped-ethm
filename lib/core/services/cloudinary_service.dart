import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  Future<String?> uploadImage(File imageFile) async {
    try {
      final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
      final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

      if (cloudName == null || uploadPreset == null) {
        throw Exception("Cloudinary credentials not found in .env");
      }

      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url']; // This is the public URL of the uploaded image
      } else {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        print('Cloudinary upload Error: ${response.statusCode} - $responseString');
        return null;
      }
    } catch (e) {
      print('Exception during Cloudinary upload: $e');
      return null;
    }
  }
}
