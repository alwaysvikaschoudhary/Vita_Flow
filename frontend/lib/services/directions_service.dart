import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:vita_flow/config.dart'; // Ensure you have Config for API keys

class DirectionsService {
  // Key from AndroidManifest.xml
  // Key from Config (Update in lib/config.dart)
  static const String _apiKey = Config.googleApiKey;

  static Future<List<LatLng>> getPolylineCoordinates(LatLng origin, LatLng destination) async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();

    // NOTE: Ideally, use the API key from a secure config
    // For this implementation, make sure to replace with a valid key
    // You can also use the one from AndroidManifest if exposed, but better to keep it secure.
    // The user provided instructions said to "Include instructions for Adding API key". 
    // I will assume for now we might need to hardcode or get from config.
    // Let's rely on the package to help or just raw HTTP request if package fails.
    
    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: _apiKey,
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      } else {
        print("Directions API FAILED. Status: ${result.status}, Error: ${result.errorMessage}");
        print("Using Key: $_apiKey"); // Debugging: Check if key is correct
        throw Exception(result.errorMessage); 
      }
    } catch (e) {
      print("EXCEPTION fetching directions: $e");
      // Fallback: Return a straight line
      polylineCoordinates.add(origin);
      polylineCoordinates.add(destination);
    }
    
    return polylineCoordinates;
  }
}
