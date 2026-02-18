import 'package:flutter/material.dart';
import 'package:vita_flow/services/api_service.dart';
import 'donation_certificate_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class DonationProgressScreen extends StatefulWidget {
  final Map<String, dynamic> requestData;

  const DonationProgressScreen({super.key, required this.requestData});

  @override
  State<DonationProgressScreen> createState() => _DonationProgressScreenState();
}

class _DonationProgressScreenState extends State<DonationProgressScreen> {
  late Map<String, dynamic> _currentRequest;
  bool _isRefreshing = false;
  Map<String, dynamic>? _riderDetails;
  String _arrivalTime = "-- mins";

  @override
  void initState() {
    super.initState();
    _currentRequest = widget.requestData;
    _fetchRiderDetails();
  }

  Future<void> _fetchRiderDetails() async {
    final riderId = _currentRequest['riderId'];
    if (riderId != null) {
      try {
        final rider = await ApiService.getRiderById(riderId);
        if (mounted) {
          setState(() {
            _riderDetails = rider;
          });
          _calculateArrivalTime();
        }
      } catch (e) {
        print("Error fetching rider: $e");
      }
    }
  }

  void _calculateArrivalTime() {
    if (_riderDetails == null) return;
    
    // Donor Location (Pickup)
    final pickup = _currentRequest['pickupOrdinate']; // Checks if pickupOrdinate exists
    double? dLat, dLng;
    
    if (pickup != null) {
      dLat = pickup['latitude'];
      dLng = pickup['longitude'];
    }

    // Rider Location
    final rOrdinate = _riderDetails!['ordinate'];
    double? rLat, rLng;
    if (rOrdinate != null) {
       rLat = rOrdinate['latitude'];
       rLng = rOrdinate['longitude'];
    }

    if (dLat != null && dLng != null && rLat != null && rLng != null) {
      double distanceInMeters = Geolocator.distanceBetween(dLat, dLng, rLat, rLng);
      // Assume average speed 30km/h => 0.5 km/min => 500m/min
      // Time = Distance / Speed
      int timeInMinutes = (distanceInMeters / 400).ceil(); // Conservatively 400m/min
      setState(() {
        _arrivalTime = "$timeInMinutes mins";
      });
    }
  }

  Future<void> _refreshRequest() async {
    setState(() => _isRefreshing = true);
    try {
      final updatedData = await ApiService.getRequestById(_currentRequest['requestId']);
      if (mounted) {
        setState(() {
          _currentRequest = updatedData;
          _isRefreshing = false;
        });
        _fetchRiderDetails(); // Refresh rider location too
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRefreshing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error refreshing status: $e")),
        );
      }
    }
  }

  Future<void> _callNumber(String? number) async {
    if (number == null || number.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Parse Status to determine active step
    final status = _currentRequest['status'] ?? "ACCEPTED";
    final otp = _currentRequest['otp'] ?? "----";
    final riderId = _currentRequest['riderId'];
    
    // Rider Info
    final riderName = _currentRequest['riderName'] ?? (_riderDetails?['name'] ?? "Rider");
    final riderBike = _currentRequest['riderBikeNumber'] ?? (_riderDetails?['bikeNumber'] ?? "Unknown Bike");
    final riderPhone = _currentRequest['riderPhoneNumber'] ?? (_riderDetails?['phoneNumber']);
    
    int currentStep = 1;
    if (status == "ACCEPTED" || status == "PENDING") currentStep = 1;
    else if (status == "RIDER_ASSIGNED" || status == "ON_THE_WAY") currentStep = 2; // Added ON_THE_WAY
    else if (status == "PICKED_UP" || status == "COLLECTED") currentStep = 3;
    else if (status == "DELIVERED" || status == "COMPLETED") currentStep = 4;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 229, 230, 234),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshRequest,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Donation in Progress",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),

                const SizedBox(height: 4),
                // Hospital Name
                Text(
                  _currentRequest['hospitalName'] ?? "Hospital",
                  style: const TextStyle(color: Colors.black),
                ),
                
                // Doctor Phone Call Action (from request)
                if (_currentRequest['doctorPhoneNumber'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: InkWell(
                    onTap: () => _callNumber(_currentRequest['doctorPhoneNumber']),
                    child: Row(
                      children: const [
                        Icon(Icons.call, size: 16, color: Colors.blue),
                        SizedBox(width: 5),
                        Text("Call Doctor/Hospital", style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Progress bar logic
                LinearProgressIndicator(
                  value: currentStep / 4,
                  color: Colors.black,
                  backgroundColor: const Color.fromARGB(255, 192, 192, 192),
                ),

                const SizedBox(height: 20),

                // Steps row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _step("1", "Request\nAccepted", currentStep >= 1),
                    _step("2", "Rider\nAssigned", currentStep >= 2),
                    _step("3", "Blood\nCollection", currentStep >= 3),
                    _step("4", "Delivered\nSuccessful", currentStep >= 4),
                  ],
                ),

                const SizedBox(height: 20),

                // OTP DISPLAY
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade100, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Your OTP for Verification",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        otp,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                          color: Color(0xFFE0463A),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Share this with the Rider upon arrival",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // RIDER CARD (Conditional)
                if (riderId != null) ...[
                  // Rider card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.blue.shade50,
                          child: Text(
                            riderName.toString().substring(0, 1).toUpperCase(),
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)
                          ), 
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text(
                                riderName, 
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Bike: $riderBike",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        if (riderPhone != null)
                        InkWell(
                          onTap: () => _callNumber(riderPhone),
                          child: CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: Icon(Icons.phone, color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 11),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue),
                        SizedBox(width: 8),
                        Text("Arriving in", style: TextStyle(color: Colors.blue.shade900)),
                        Spacer(),
                        Text(
                          _arrivalTime,
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 16
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                   // Waiting for Rider State
                   Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                         SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                         SizedBox(width: 20),
                         Expanded(child: Text("Waiting for Rider Assignment... (Pull to refresh)")),
                      ],
                    ),
                   ),
                ],
                
                const SizedBox(height: 20),
                
                 if (currentStep >= 3)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: false).push(
                        MaterialPageRoute(
                          builder: (c) => const DonationCertificateScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0463A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "Finish Donation (Demo)",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _step extends StatelessWidget {
  final String num;
  final String text;
  final bool active;

  const _step(this.num, this.text, this.active);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: active
              ? Colors.red
              : const Color.fromARGB(255, 199, 199, 199),
          child: Text(num, style: const TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 6),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: active ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }
}
