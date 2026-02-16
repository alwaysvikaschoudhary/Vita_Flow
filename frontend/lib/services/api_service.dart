import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:vita_flow/config.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS Simulator
  // static const String baseUrl = "http://10.0.2.2:8080"; 
  // static const String baseUrl = Config.baseUrl; 
  // static const String baseUrl = Config.baseUrl; 
  static const String baseUrl = Config.baseUrl; 

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

  static Future<Map<String, dynamic>> completeProfile(Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/user/complete-profile");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Profile update failed: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  static Future<bool> updateLocation(String phoneNumber, double lat, double lng) async {
    final url = Uri.parse("$baseUrl/user/location");
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "phoneNumber": phoneNumber,
          "latitude": lat,
          "longitude": lng,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Error updating location: $e");
    }
  }
  static Future<List<dynamic>> getRequestsByHospital(String hospitalId) async {
    final url = Uri.parse("$baseUrl/request/hospital/$hospitalId");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load requests: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }
  static Future<List<dynamic>> getNearbyRequests(String donorId) async {
    final url = Uri.parse("$baseUrl/request/nearby/$donorId");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load nearby requests: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  static Future<Map<String, dynamic>> acceptRequest(String requestId, Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/request/accept/$requestId");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to accept request: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  static Future<Map<String, dynamic>> getRequestById(String requestId) async {
    final url = Uri.parse("$baseUrl/request/$requestId");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load request: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  static Future<List<dynamic>> getRiderNearbyRequests(String riderId) async {
    final url = Uri.parse("$baseUrl/request/rider/nearby/$riderId");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load rider tasks: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  static Future<List<dynamic>> getActiveDonorRequests(String donorId) async {
    final url = Uri.parse("$baseUrl/request/active/donor/$donorId");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load active requests: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }
  static Future<bool> updateRiderLocation(String requestId, double lat, double lng) async {
    final url = Uri.parse("$baseUrl/request/rider/location");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "requestId": requestId,
          "latitude": lat,
          "longitude": lng,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Error updating rider location: $e");
    }
  }

  static Future<Map<String, dynamic>> assignRider(String requestId, String riderId, String riderName) async {
    final url = Uri.parse("$baseUrl/request/assign/rider");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "requestId": requestId,
          "riderId": riderId,
          "riderName": riderName,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to assign rider: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  static Future<Map<String, dynamic>> verifyPickupOtp(String requestId, String otp) async {
    final url = Uri.parse("$baseUrl/request/pickup/verify");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "requestId": requestId,
          "otp": otp,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("OTP Verification Failed: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  static Future<Map<String, dynamic>> completeRequest(String requestId) async {
    final url = Uri.parse("$baseUrl/request/complete");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"requestId": requestId}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to complete request: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  static Future<Map<String, dynamic>?> getActiveRiderRequest(String riderId) async {
    final url = Uri.parse("$baseUrl/request/rider/active/$riderId");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 204) {
        return null; // No active request
      } else {
        throw Exception("Failed to fetch active request");
      }
    } catch (e) {
      return null;
    }
  }

  static Future<List<dynamic>> getDonorHistory(String donorId) async {
    final url = Uri.parse("$baseUrl/request/history/donor/$donorId");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load history: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }
  static Future<Map<String, dynamic>> getDoctorById(String userId) async {
    final url = Uri.parse("$baseUrl/user/doctor/$userId");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load doctor profile: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  static Future<Map<String, dynamic>> getDonorById(String userId) async {
    final url = Uri.parse("$baseUrl/user/donor/$userId");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load donor profile: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  static Future<Map<String, dynamic>> getRiderById(String userId) async {
    final url = Uri.parse("$baseUrl/user/rider/$userId");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load rider profile: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }
}

