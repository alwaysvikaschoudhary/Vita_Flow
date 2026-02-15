import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vita_flow/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class FullScreenMapScreen extends StatefulWidget {
  final LatLng initialLocation;
  final LatLng destinationLocation;
  final Set<Marker> markers;
  final Set<Polyline> polylines;

  const FullScreenMapScreen({
    super.key,
    required this.initialLocation,
    required this.destinationLocation,
    required this.markers,
    required this.polylines,
  });

  @override
  State<FullScreenMapScreen> createState() => _FullScreenMapScreenState();
}

class _FullScreenMapScreenState extends State<FullScreenMapScreen> {
  late GoogleMapController _mapController;
  StreamSubscription<Position>? _positionStream;
  bool _isNavigating = false;
  LatLng? _currentLocation;

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _toggleNavigation() async {
    if (_isNavigating) {
      // Stop Navigation
      _positionStream?.cancel();
      setState(() {
        _isNavigating = false;
      });
      
      // Reset Camera to Overview
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: widget.initialLocation,
            zoom: 14,
            tilt: 0,
            bearing: 0,
          ),
        ),
      );
    } else {
      // Start Navigation
      bool hasPermission = await LocationService.handleLocationPermission();
      if (!hasPermission) {
        if(mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("Location permission required for navigation")),
           );
        }
        return;
      }

      setState(() {
        _isNavigating = true;
      });

      _positionStream = LocationService.getPositionStream().listen((Position position) {
        if (!mounted) return;
        
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });

        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18,     // Zoom in for street view
              tilt: 60,     // 3D perspective
              bearing: position.heading, // Rotate map in direction of travel
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialLocation,
              zoom: 14,
            ),
            markers: widget.markers,
            polylines: widget.polylines,
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // Hide default button to avoid conflict
            zoomControlsEnabled: false,    // Clean UI
            compassEnabled: true,
            mapToolbarEnabled: false,
          ),
          
          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () {
                if (_isNavigating) {
                  _toggleNavigation(); // Confirm exit? For now just stop.
                } else {
                  Navigator.pop(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,2))
                  ]
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ),

          // Navigation Overlay Info (Optional - Distance/Time)
          
          // Toggle Navigation Button
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isNavigating ? Colors.redAccent : Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 5,
              ),
              onPressed: _toggleNavigation,
              icon: Icon(_isNavigating ? Icons.stop_circle : Icons.navigation, color: Colors.white),
              label: Text(
                _isNavigating ? "Stop Navigation" : "Start Navigation", 
                style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)
              ),
            ),
          ),
        ],
      ),
    );
  }
}
