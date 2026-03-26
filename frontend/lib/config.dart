import 'secrets.dart';

class Config {
  static const String baseUrl = "http://localhost:8081"; // simulator/emulator
  // static const String baseUrl = "http://10.22.8.87:8081"; // real device (same WiFi)
  static const String googleApiKey = Secrets.googleApiKey;
}
