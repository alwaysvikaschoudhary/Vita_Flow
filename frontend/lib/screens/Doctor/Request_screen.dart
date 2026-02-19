import 'package:flutter/material.dart';
import 'package:vita_flow/services/api_service.dart';
import 'package:vita_flow/screens/Doctor/track_delivery_screen.dart'; 
import 'package:vita_flow/screens/Location/location_picker_screen.dart';

class DoctorRequestsScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const DoctorRequestsScreen({super.key, required this.currentUser});

  @override
  State<DoctorRequestsScreen> createState() => _DoctorRequestsScreenState();
}

class _DoctorRequestsScreenState extends State<DoctorRequestsScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;
  String _selectedTab = "Available"; // "Available" or "My Requests"

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    try {
      List<dynamic> requests = [];
      if (_selectedTab == "Available") {
        // Fetch nearby pending requests
        requests = await ApiService.getNearbyPendingRequestsForDoctor(widget.currentUser['userId']);
      } else {
        // Fetch history/active requests for this doctor (hospital)
        requests = await ApiService.getRequestsByHospital(widget.currentUser['userId']);
      }

      if (mounted) {
        setState(() {
          _requests = requests.reversed.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching requests: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _acceptRequest(String requestId) async {
    // Show dialog to choose location
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Confirm Acceptance",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text("Select location for pickup by rider:"),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.blue),
                title: const Text("Use My Profile Location"),
                onTap: () async {
                  Navigator.pop(context);
                  _processAcceptance(requestId, null, null);
                },
              ),
              ListTile(
                leading: const Icon(Icons.map, color: Colors.orange),
                title: const Text("Select New Location"),
                onTap: () async {
                  Navigator.pop(context);
                  
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocationPickerScreen(),
                    ),
                  );

                  if (result != null && result is Map<String, double>) {
                    _processAcceptance(requestId, result['latitude'], result['longitude']);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }


  Future<void> _processAcceptance(String requestId, double? lat, double? lng) async {
    setState(() => _isLoading = true);
    try {
      await ApiService.acceptRequestByDoctor({
        "requestId": requestId,
        "doctorId": widget.currentUser['userId'],
        "doctorName": widget.currentUser['name'],
        "doctorPhoneNumber": widget.currentUser['phoneNumber'],
        "latitude": lat,
        "longitude": lng,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request Accepted!")));
        // Switch to "My Requests" to see it
        setState(() {
          _selectedTab = "My Requests";
        });
        _fetchRequests();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Blood Requests",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _fetchRequests,
                  ),
                ],
              ),
            ),

            // Toggle
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  _buildTab("Available"),
                  _buildTab("My Requests"),
                ],
              ),
            ),
            
            const SizedBox(height: 10),

            // List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _requests.isEmpty
                      ? const Center(child: Text("No requests found"))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _requests.length,
                          itemBuilder: (context, index) {
                            final req = _requests[index];
                             // Determine UI properties based on status/urgency
                            String urgency = req['urgency'] ?? "Medium";
                            Color urgencyColor = Colors.orange;
                            if (urgency == "Critical") urgencyColor = Colors.red;
                            if (urgency == "Low") urgencyColor = Colors.green;

                            String status = req['status'] ?? "Pending";
                            Color statusColor = Colors.grey;
                            if (status == "ACCEPTED") statusColor = Colors.blue;
                            if (status == "COMPLETED") statusColor = Colors.green;
                            if (status == "PENDING") statusColor = Colors.orange;
                            if (status == "PICKED_UP") statusColor = Colors.purple;
                            if (status == "CANCELLED") statusColor = Colors.red;

                            String btnText = "View Details";
                            if (_selectedTab == "Available") {
                              btnText = "Accept Request";
                            } else {
                              if (status == "ACCEPTED" || status == "PICKED_UP") btnText = "Track Delivery";
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _requestCard(
                                blood: req['bloodGroup'] ?? "?",
                                units: "${req['units']} Units",
                                timeAgo: _timeAgo(req['date'], req['time']),
                                donorName: req['donorName'] ?? (status == "PENDING" ? "Waiting for match" : "Unknown"),
                                urgency: urgency,
                                urgencyColor: urgencyColor,
                                status: status,
                                statusColor: statusColor,
                                buttonText: btnText,
                                onPressed: () {
                                   if (_selectedTab == "Available") {
                                      _acceptRequest(req['requestId'] ?? req['id']);
                                   } else {
                                      if (status == "ACCEPTED" || status == "PICKED_UP") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (c) => const DoctorLiveTrackingScreen(),
                                          ),
                                        );
                                      }
                                   }
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title) {
    bool isSelected = _selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = title;
          });
          _fetchRequests();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE0463A) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _timeAgo(String? dateStr, String? timeStr) {
     if (dateStr == null || timeStr == null) return "Just now";
      try {
        final now = DateTime.now();
        final dateParts = dateStr.split('-');
        final timeParts = timeStr.split(':'); // HH:mm or HH:mm:ss

        if (dateParts.length == 3 && timeParts.length >= 2) {
          final dt = DateTime(
            int.parse(dateParts[0]), 
            int.parse(dateParts[1]), 
            int.parse(dateParts[2]),
            int.parse(timeParts[0]),
            int.parse(timeParts[1])
          );
          final diff = now.difference(dt);

          if (diff.inDays > 0) return "${diff.inDays}d ago";
          if (diff.inHours > 0) return "${diff.inHours}h ago";
          if (diff.inMinutes > 0) return "${diff.inMinutes}m ago";
          return "Just now";
        }
        return "Recent";
      } catch (e) {
        return "Recent";
      }
  }

  // -----------------------------------------
  // STATS BOX WIDGET
  // -----------------------------------------
  Widget _statBox(String value, String label, Color bg, Color textColor) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  // -----------------------------------------
  // REQUEST CARD WIDGET
  // -----------------------------------------
  Widget _requestCard({
    required String blood,
    required String units,
    required String timeAgo,
    required String donorName,
    required String urgency,
    required Color urgencyColor,
    required String status,
    required Color statusColor,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Blood Type Circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  blood,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Main Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    units,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(timeAgo, style: const TextStyle(color: Colors.black54)),
                ],
              ),

              const Spacer(),

              // Urgency Tag
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: urgencyColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  urgency,
                  style: TextStyle(color: urgencyColor, fontSize: 12),
                ),
              ),

              const SizedBox(width: 8),

              // Status Tag
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Donor Row
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text(
                  "Donor",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  donorName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0463A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onPressed,
              child: Text(buttonText, style: const TextStyle(color: Colors.white),),
            ),
          ),
        ],
      ),
    );
  }
}
