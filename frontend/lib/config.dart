import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  /// Automatically picks the correct backend URL:
  /// - Chrome/Web → http://localhost:8081
  /// - Android/iOS real device (same WiFi) → http://10.22.8.87:8081
  static String get baseUrl {
    final envUrl = dotenv.env['BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) return envUrl;
    return kIsWeb ? "http://localhost:8081" : "http://10.22.20.170:8081";
  }
  
  static String get googleApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "";
}
