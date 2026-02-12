import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS Simulator
  // static const String baseUrl = "http://10.0.2.2:8080"; 
  static const String baseUrl = "http://localhost:8080"; 

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/user/login");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Login failed: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  static Future<bool> sendOtp(String phoneNumber) async {
    final url = Uri.parse("$baseUrl/user/send-otp");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"phoneNumber": phoneNumber}),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Error sending OTP: $e");
    }
  }

  static Future<Map<String, dynamic>?> verifyOtp(String phoneNumber, String otp) async {
    final url = Uri.parse("$baseUrl/user/verify-otp");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"phoneNumber": phoneNumber, "otp": otp}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Invalid OTP");
      }
    } catch (e) {
      throw Exception("Error verifying OTP: $e");
    }
  }

  static Future<Map<String, dynamic>> completeProfile(
      String name, String email, String role, String phone, String about,
      {String? bloodGroup, String? dob, String? hospitalName, String? specialization, String? bikeNumber}) async {
    final url = Uri.parse("$baseUrl/user/complete-profile");
    try {
      final body = {
        "name": name,
        "email": email, // Optional
        "role": role,
        "phoneNumber": phone,
        "about": about,
        "about": about,
        // Role Specific
        "bloodGroup": bloodGroup,
        "dob": dob,
        "hospitalName": hospitalName,
        "specialization": specialization,
        "bikeNumber": bikeNumber,
      };
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Profile completion failed: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }
}

