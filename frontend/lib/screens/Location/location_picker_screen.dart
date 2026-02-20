import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../services/location_service.dart';


class LocationPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const LocationPickerScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();

  LatLng? _pickedLocation;
  bool _isLoading = true;

  static const CameraPosition _defaultLocation = CameraPosition(
    target: LatLng(26.9124, 75.7873), // Jaipur fallback
    zoom: 14,
  );

  CameraPosition _initialPosition = _defaultLocation;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    // If initial coordinates passed
    if (widget.initialLat != null && widget.initialLng != null) {
      final latLng = LatLng(widget.initialLat!, widget.initialLng!);

      setState(() {
        _pickedLocation = latLng;
        _initialPosition = CameraPosition(target: latLng, zoom: 15);
        _isLoading = false;
      });

      return;
    }

    await _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _finishLoading();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _finishLoading();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _pickedLocation = latLng;
        _initialPosition = CameraPosition(target: latLng, zoom: 15);
        _isLoading = false;
      });

      final controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(_initialPosition),
      );
    } catch (e) {
      _finishLoading();
    }
  }

  void _finishLoading() {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    try {
      LatLng? latLng;

      try {
        // Try native geocoding first (Works on iOS/Android for free without API key)
        final locations = await locationFromAddress(query);
        if (locations.isNotEmpty) {
          latLng = LatLng(locations.first.latitude, locations.first.longitude);
        }
      } catch (e) {
        print('Native geocoding failed: $e');
      }

      // If native geocoding failed (e.g., on Web) or returned nothing, try HTTP fallback
      if (latLng == null) {
        latLng = await LocationService.geocodeAddress(query);
      }

      if (latLng == null) {
        _showSnackBar("Location not found");
        return;
      }

      setState(() => _pickedLocation = latLng!);

      final controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 16),
        ),
      );
    } catch (e) {
      print('Geocoding error: $e');
      _showSnackBar("Error searching location");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!_controller.isCompleted) {
      _controller.complete(controller);
    }
  }

  void _onTap(LatLng position) {
    setState(() => _pickedLocation = position);
  }

  void _confirmLocation() {
    if (_pickedLocation == null) return;

    Navigator.pop(context, {
      "latitude": _pickedLocation!.latitude,
      "longitude": _pickedLocation!.longitude,
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: "Search location...",
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _searchLocation(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _searchLocation,
          ),
          if (_pickedLocation != null)
            TextButton(
              onPressed: _confirmLocation,
              child: const Text("Done", style: TextStyle(color: Colors.white)),
            ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _initialPosition,
                  onMapCreated: _onMapCreated,
                  onTap: _onTap,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _pickedLocation == null
                      ? {}
                      : {
                          Marker(
                            markerId: const MarkerId("picked"),
                            position: _pickedLocation!,
                          ),
                        },
                ),
                if (_pickedLocation != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: SizedBox(
                        height: 40,
                        width: 170,
                        child: ElevatedButton(
                          onPressed: _confirmLocation,
                          child: const Text("Confirm Location"),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
