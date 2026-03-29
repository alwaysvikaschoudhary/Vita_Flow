import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  /// Automatically picks the correct backend URL:

  static String get baseUrl {
    final envUrl = dotenv.env['BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) return envUrl;
    
    final ipAddress = dotenv.env['MOBILE_IP'] ?? "10.22.20.170:8080";
    return kIsWeb ? "http://localhost:8080" : "http://$ipAddress";
  }
  
  static String get googleApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "";
}
