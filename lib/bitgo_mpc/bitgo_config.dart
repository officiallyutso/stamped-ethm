// lib/bitgo_mpc/bitgo_config.dart

import 'dart:io';

class BitGoConfig {
  /// The base URL for the backend signing service (which wraps the BitGo SDK).
  static String get backendBaseUrl {
    // Relying on `adb reverse tcp:5555 tcp:5555` to safely proxy the connection over USB.
    return 'http://localhost:4000/api';
  }
  
  /// The authentication token for your backend service, if required.
  static const String backendAuthToken = 'YOUR_BACKEND_AUTH_TOKEN';
}
