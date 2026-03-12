import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:vita_flow/config.dart';

class LocationService {
  static Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }

  static Future<Position?> getCurrentLocation() async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return null;
    return await Geolocator.getCurrentPosition();
  }

  static double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  /// Fallback HTTP geocoding to bypass `geocoding` web limitations
  static Future<LatLng?> geocodeAddress(String address) async {
    try {
      final apiKey = Config.googleApiKey;
      final query = Uri.encodeComponent(address);
      final url = 'https://maps.googleapis.com/maps/api/geocode/json?address=$query&key=$apiKey';

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return LatLng(location['lat'], location['lng']);
        } else {
          print('Geocoding API explicitly returned: ${data['status']} - ${data['error_message']}');
        }
      }
    } catch (e) {
      print('HTTP Geocoding Error: $e');
    }
    return null;
  }

  static Future<String?> reverseGeocode(double lat, double lng, {String? poiName}) async {
    try {
      // 1. Try Google API First (Most Accurate)
      print('Trying Google API...');
      final apiKey = Config.googleApiKey;
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && (data['results'] as List).isNotEmpty) {
          // Parse address components to remove state, country, and postal code
          final components = data['results'][0]['address_components'] as List;
          List<String> validParts = [];
          
          for (var comp in components) {
            final types = comp['types'] as List;
            if (!types.contains('administrative_area_level_1') && 
                !types.contains('country') && 
                !types.contains('postal_code')) {
              validParts.add(comp['long_name']);
            }
          }
          
          if (validParts.isNotEmpty) {
            String addr = validParts.join(', ');
            if (poiName != null && poiName.isNotEmpty) {
              addr = '$poiName, $addr';
            }
            return addr;
          }
          return data['results'][0]['formatted_address'] as String;
        } else {
          print('Google API Failed: ${data['status']} - ${data['error_message']}');
        }
      } else {
        print('Google API HTTP Error: ${response.statusCode}');
      }

      // 2. Fallback to OpenStreetMap Nominatim (Free, no API key required)
      print('Trying Nominatim Fallback...');
      final nomUrl = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1';
      final nomResponse = await http.get(
        Uri.parse(nomUrl),
        headers: {'User-Agent': 'VitaFlowApp/1.0'},
      ).timeout(const Duration(seconds: 6));
      
      if (nomResponse.statusCode == 200) {
        final data = json.decode(nomResponse.body);
        if (data['address'] != null) {
          final addressMap = data['address'] as Map<String, dynamic>;
          addressMap.remove('state');
          addressMap.remove('state_district');
          addressMap.remove('country');
          addressMap.remove('country_code');
          addressMap.remove('postcode');
          
          final addressValues = addressMap.values.whereType<String>().toList();
          if (addressValues.isNotEmpty) {
            String addr = addressValues.join(', ');
            if (poiName != null && poiName.isNotEmpty) {
              addr = '$poiName, $addr';
            }
            return addr;
          }
        }
        if (data['display_name'] != null) {
          return data['display_name'] as String;
        }
      } else {
        print('Nominatim HTTP Error: ${nomResponse.statusCode}');
      }

      // 3. Try native geocoding last (Free, uses platform capabilities)
      try {
        List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          geo.Placemark place = placemarks[0];
          List<String> addressParts = [];
          if (place.name != null && place.name!.isNotEmpty) addressParts.add(place.name!);
          if (place.subLocality != null && place.subLocality!.isNotEmpty) addressParts.add(place.subLocality!);
          if (place.locality != null && place.locality!.isNotEmpty) addressParts.add(place.locality!);
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
            // We're deliberately excluding state/administrativeArea here to match requirements
            // But if we wanted to keep it, we would add it here.
          }
          if (addressParts.isNotEmpty) {
            String addr = addressParts.join(', ');
            if (poiName != null && poiName.isNotEmpty) {
              addr = '$poiName, $addr';
            }
            return addr;
          }
        }
      } catch (e) {
        print('Native reverse geocoding failed: $e');
      }

    } catch (e) {
      print('Reverse geocoding error: $e');
    }
    return null;
  }

  static Future<String?> getPlaceName(double lat, double lng) async {
    final apiKey = Config.googleApiKey;

    // 1. Try Geocoding API first (Better CORS support on Web/Chrome)
    try {
      final geoUrl = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&result_type=point_of_interest&key=$apiKey';
      final geoResponse = await http.get(Uri.parse(geoUrl)).timeout(const Duration(seconds: 5));
      
      if (geoResponse.statusCode == 200) {
        final data = json.decode(geoResponse.body);
        if (data['status'] == 'OK' && (data['results'] as List).isNotEmpty) {
          // Geocoding point_of_interest results are usually highly relevant
          return data['results'][0]['address_components'][0]['long_name'] as String?;
        }
      }
    } catch (e) {
      print('Geocoding POI Fallback Error: $e');
    }

    // 2. Try Places Nearby API (More detailed, but often blocked by CORS on Web)
    try {
      final url =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=200&key=$apiKey';

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && (data['results'] as List).isNotEmpty) {
          final results = data['results'] as List;

          double bestDistance = double.infinity;
          String? bestName;

          for (var place in results) {
            final loc = place['geometry']['location'];
            final pLat = loc['lat'];
            final pLng = loc['lng'];

            final dist = Geolocator.distanceBetween(lat, lng, pLat, pLng);

            if (dist < bestDistance) {
              bestDistance = dist;
              bestName = place['name'] as String?;
            }
          }

          return bestName;
        }
      }
    } catch (e) {
      print('Error fetching place name via Places API: $e');
    }
    return null;
  }
}

