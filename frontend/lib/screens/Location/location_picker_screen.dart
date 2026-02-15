import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();
  LatLng? _pickedLocation;
  bool _isLoading = true;
  
  // Default to Jaipur if location permission denied or error
  static const CameraPosition _kDefaultLocation = CameraPosition(
    target: LatLng(26.9124, 75.7873),
    zoom: 14.4746,
  );

  CameraPosition _initialPosition = _kDefaultLocation;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
         if (mounted) setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
       if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _initialPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        );
        _pickedLocation = LatLng(position.latitude, position.longitude); // Default to current
        _isLoading = false;
      });
      
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(_initialPosition));
      
    } catch (e) {
      print("Error getting location: $e");
       if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _searchAndNavigate() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final newLatLng = LatLng(loc.latitude, loc.longitude);
        
        setState(() {
          _pickedLocation = newLatLng;
        });

        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: newLatLng, zoom: 16),
        ));
      } else {
        if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location not found")),
          );
        }
      }
    } catch (e) {
        if(mounted){
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error searching location: $e")),
            );
        }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!_controller.isCompleted) {
      _controller.complete(controller);
    }
  }

  void _onTap(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          if (_pickedLocation != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context, {
                  'latitude': _pickedLocation!.latitude,
                  'longitude': _pickedLocation!.longitude,
                });
              },
              child: const Text(
                'Done',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _initialPosition,
                  onMapCreated: _onMapCreated,
                  onTap: _onTap,
                  markers: _pickedLocation != null
                      ? {
                          Marker(
                            markerId: const MarkerId('picked'),
                            position: _pickedLocation!,
                          ),
                        }
                      : {},
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                Positioned(
                  top: 10,
                  left: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: "Search address...",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _searchAndNavigate(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _searchAndNavigate,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_pickedLocation != null)
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE0463A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context, {
                            'latitude': _pickedLocation!.latitude,
                            'longitude': _pickedLocation!.longitude,
                          });
                        },
                        child: const Text(
                          "Confirm Location",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
