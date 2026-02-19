import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vita_flow/services/location_service.dart';
import 'package:vita_flow/services/directions_service.dart';
import 'package:vita_flow/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vita_flow/screens/Rider/full_screen_map.dart';
enum DeliveryPhase { toDonor, toDoctor }

class PickupVerificationScreen extends StatefulWidget {
  final Map<String, dynamic> requestData;
  final String riderId;

  const PickupVerificationScreen({
    super.key,
    required this.requestData,
    required this.riderId,
  });

  @override
  State<PickupVerificationScreen> createState() => _PickupVerificationScreenState();
}

class _PickupVerificationScreenState extends State<PickupVerificationScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  
  // Markers & Polylines
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  
  // Locations
  LatLng? _riderLocation;
  late LatLng _donorLocation;
  late LatLng _doctorLocation;
  
  // State
  DeliveryPhase _currentPhase = DeliveryPhase.toDonor;
  bool _isLoading = true;
  bool _isPickupStarted = false;
  StreamSubscription<Position>? _positionStream;
  Timer? _backendUpdateTimer;

  // Data
  late String _requestId;
  late String _donorName;
  late String _bloodType;
  late String _address;
  String? _donorPhoneNumber;
  late String _doctorName;
  String? _doctorPhoneNumber;

  @override
  void initState() {
    super.initState();
    _parseRequestData();
    _initializeTracking();
  }

  void _parseRequestData() {
    final data = widget.requestData;
    _requestId = data['requestId'];
    _donorName = data['donorName'] ?? "Donor";
    _bloodType = data['bloodGroup'] ?? "Unknown";
    _address = data['hospitalName'] ?? "Hospital"; // Initial address displayed
    _donorPhoneNumber = data['donorPhoneNumber']; 
    _doctorName = data['doctorName'] ?? "Doctor";
    _doctorPhoneNumber = data['doctorPhoneNumber']; 
    
    // Check if presumably already started
    String status = data['status'] ?? "PENDING";
    if (status == "RIDER_ASSIGNED" || status == "ON_THE_WAY") {
      _isPickupStarted = true;
    } else if (status == "PICKED_UP") {
      _isPickupStarted = true;
      _currentPhase = DeliveryPhase.toDoctor;
      _address = data['hospitalName'] ?? "Hospital";
    }

    // Parse Coordinates
    // Donor Location (pickupOrdinate)
    // If pickupOrdinate is null, handle gracefully (e.g. use default or error)
    final pickupOrd = data['pickupOrdinate'];
    if (pickupOrd != null) {
      _donorLocation = LatLng(
        (pickupOrd['latitude'] as num).toDouble(),
        (pickupOrd['longitude'] as num).toDouble(),
      );
    } else {
      // Fallback or error
      _donorLocation = const LatLng(26.9124, 75.7873); // Default Jaipur
    }

    // Doctor/Hospital Location (ordinate)
    final hospOrd = data['ordinate'];
    if (hospOrd != null) {
      _doctorLocation = LatLng(
        (hospOrd['latitude'] as num).toDouble(),
        (hospOrd['longitude'] as num).toDouble(),
      );
    } else {
      _doctorLocation = const LatLng(26.9124, 75.7873);
    }
  }

  Future<void> _initializeTracking() async {
    // 1. Get Current Location
    Position? position = await LocationService.getCurrentLocation();
    if (position != null) {
      _riderLocation = LatLng(position.latitude, position.longitude);
    }

    // 2. Start Live Updates
    _positionStream = LocationService.getPositionStream().listen((pos) {
      _updateRiderLocation(LatLng(pos.latitude, pos.longitude));
    });

    // 3. Start Periodic Backend Updates
    _backendUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_riderLocation != null) {
        ApiService.updateRiderLocation(
          _requestId,
          _riderLocation!.latitude,
          _riderLocation!.longitude,
        );
      }
    });

    // 4. Draw Initial Route
    await _updateRoute();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _updateRiderLocation(LatLng newLocation) {
    setState(() {
      _riderLocation = newLocation;
      _updateMarkers(); // Update rider marker
    });
    
    // Check Arrival
    _checkArrival();
    
    // Animate Camera
     _controller.future.then((controller) {
      controller.animateCamera(CameraUpdate.newLatLng(newLocation));
    });
  }

  Future<void> _updateRoute() async {
    if (_riderLocation == null) return;

    LatLng destination = _currentPhase == DeliveryPhase.toDonor 
        ? _donorLocation 
        : _doctorLocation;

    List<LatLng> points = await DirectionsService.getPolylineCoordinates(
      _riderLocation!, 
      destination
    );
    
    if (mounted) {
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId("route"),
            points: points,
            color: Colors.blue, // Google Maps Blue-ish
            width: 6,
          ),
        };
        _updateMarkers();
      });
    }
  }

  void _updateMarkers() {
    _markers = {};
    
    // Rider Marker
    if (_riderLocation != null) {
      _markers.add(Marker(
        markerId: const MarkerId("rider"),
        position: _riderLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: "You"),
      ));
    }

    // Destination Marker
    LatLng dest = _currentPhase == DeliveryPhase.toDonor ? _donorLocation : _doctorLocation;
    String title = _currentPhase == DeliveryPhase.toDonor ? "Donor: $_donorName" : "Hospital";
    
    _markers.add(Marker(
      markerId: const MarkerId("destination"),
      position: dest,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: title),
    ));
  }

  void _checkArrival() {
    if (_riderLocation == null) return;
    
    LatLng target = _currentPhase == DeliveryPhase.toDonor ? _donorLocation : _doctorLocation;
    double dist = Geolocator.distanceBetween(
      _riderLocation!.latitude, _riderLocation!.longitude,
      target.latitude, target.longitude
    );

    if (dist <= 50) { // 50 meters
      _showArrivalDialog();
    }
  }

  void _showArrivalDialog() {
    // Prevent multiple dialogs
    // For simplicity, just show snackbar or dialog once
    // In real app, manage state to not show again
  }

  Future<void> _callDonor() async {
    if (_donorPhoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Donor phone number not available")),
      );
      return;
    }
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: _donorPhoneNumber,
    );
    if (!await launchUrl(launchUri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not launch dialer")),
      );
    }
  }

  Future<void> _callDoctor() async {
    if (_doctorPhoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Doctor phone number not available")),
      );
      return;
    }
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: _doctorPhoneNumber,
    );
    if (!await launchUrl(launchUri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not launch dialer")),
      );
    }
  }

  Future<void> _assignRider() async {
    setState(() => _isLoading = true);
    try {
      // You might want to get riderName from somewhere or just send riderId
      // For now using "Rider" as placeholder or if you passed it in widget
      await ApiService.assignRider(_requestId, widget.riderId, "Rider"); 
      
      // Update local status if needed, or just rely on the button state change
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pickup Started! Head to the donor location.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error starting pickup: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  void _showOtpDialog() {
    final TextEditingController otpController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Pickup OTP"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Ask the donor for the OTP to confirm pickup."),
            const SizedBox(height: 10),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "OTP",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _verifyOtp(otpController.text.trim());
            },
            child: const Text("Verify"),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyOtp(String otp) async {
    if (otp.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      await ApiService.verifyPickupOtp(_requestId, otp);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP Verified! Proceed to Hospital.")),
        );
        _completePickup(); // Switch phase
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification Failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Toggle Phase (for testing or OTP flow)
  void _completePickup() {
    setState(() {
      _currentPhase = DeliveryPhase.toDoctor;
      _address = widget.requestData['hospitalName'] ?? "Hospital"; // Update address to Hospital
    });
    _updateRoute();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _backendUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: Column(
          children: [
            _header(context),

            const SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _liveTrackingBox(), // Renamed to CamelCase logic

                    const SizedBox(height: 20),

                    Text(
                      _currentPhase == DeliveryPhase.toDonor ? "Donor Information" : "Hospital Information",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),

                    const SizedBox(height: 12),

                    _donorCard(),

                    const SizedBox(height: 30),

                    _doctorCard(),
                    const SizedBox(height: 30),

                    _pickupButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------- HEADER -----------------------
  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFEFF0F6),
              child: Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentPhase == DeliveryPhase.toDonor ? "Pickup Verification" : "Delivery in Progress",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------- LIVE TRACKING BOX ------------------------
  Widget _liveTrackingBox() {
    return Container(
      height: 300, // Fixed height for map
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: _riderLocation == null 
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
            onTap: () {
               if (_riderLocation != null) {
                 Navigator.push(
                   context,
                   MaterialPageRoute(
                     builder: (_) => FullScreenMapScreen(
                       initialLocation: _riderLocation!,
                       destinationLocation: _currentPhase == DeliveryPhase.toDonor ? _donorLocation : _doctorLocation,
                       markers: _markers,
                       polylines: _polylines,
                     ),
                   ),
                 );
               }
            },
            child: AbsorbPointer( // Disable interaction on mini-map
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _riderLocation!,
                  zoom: 14,
                ),
                markers: _markers,
                polylines: _polylines,
                onMapCreated: (controller) => _controller.complete(controller),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomGesturesEnabled: false,
                scrollGesturesEnabled: false,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: false,
              ),
            ),
          ),
      ),
    );
  }

  // --------------------- INFO CARD ------------------------
  Widget _donorCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.red.shade50,
                child: const Icon(Icons.person, color: Colors.red, size: 30),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _donorName,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  Text("Blood Type: $_bloodType",
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: _callDonor,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.green.shade100,
                  child: const Icon(Icons.call, color: Colors.green),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(Icons.location_on, size: 20, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _address,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _doctorCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.red.shade50,
                child: const Icon(Icons.person, color: Colors.red, size: 30),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _doctorName,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: _callDoctor,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.green.shade100,
                  child: const Icon(Icons.call, color: Colors.green),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(Icons.location_on, size: 20, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _address,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------- BUTTON ------------------------
  Widget _pickupButton(BuildContext context) {
    if (_currentPhase == DeliveryPhase.toDoctor) {
       return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Completed/delivering
            padding: const EdgeInsets.symmetric(vertical: 16),
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () async {
             setState(() => _isLoading = true);
             try {
               await ApiService.completeRequest(_requestId);
               if (context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text("Delivery Completed!")),
                 );
                 Navigator.pop(context); // Go back to Home
               }
             } catch (e) {
               if (context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text("Error completing delivery: $e")),
                 );
               }
               setState(() => _isLoading = false);
             }
          },
          child: const Text("Complete Delivery", style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE0463A),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () {
          if (!_isPickupStarted) {
             _assignRider().then((_) {
                setState(() => _isPickupStarted = true);
             });
          } else {
             _showOtpDialog();
          }
        },
        child: Text(
          !_isPickupStarted ? "Start Pickup" : "Verify Pickup OTP",
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
