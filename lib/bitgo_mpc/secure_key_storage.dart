// lib/bitgo_mpc/secure_key_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureKeyStorage {
  final _storage = const FlutterSecureStorage();
  
  static const String _deviceIdKey = 'stamped_device_id';

  /// Securely store the device identifier (or minimal key material) required by the backend.
  Future<void> saveDeviceId(String deviceId) async {
    await _storage.write(key: _deviceIdKey, value: deviceId);
  }

  /// Retrieve the stored device identifier.
  Future<String?> getDeviceId() async {
    return await _storage.read(key: _deviceIdKey);
  }

  /// Delete the stored device identifier.
  Future<void> deleteDeviceId() async {
    await _storage.delete(key: _deviceIdKey);
  }
}
