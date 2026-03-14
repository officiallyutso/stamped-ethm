// lib/bitgo_mpc/bitgo_config.dart

import 'dart:io';

class BitGoConfig {
  /// The base URL for the backend service (BitGo + Fileverse, all on port 4000).
  static String get backendBaseUrl {
    // Relying on `adb reverse tcp:4000 tcp:4000` to proxy the connection over USB.
    return 'http://localhost:4000/api';
  }
   
  /// The authentication token for your backend service, if required.
  static const String backendAuthToken = 'YOUR_BACKEND_AUTH_TOKEN';
}
