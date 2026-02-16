import 'package:flutter/material.dart';
import 'package:vita_flow/services/api_service.dart';
import 'package:vita_flow/screens/Doctor/track_delivery_screen.dart'; // Assume this exists or is placeholder

class DoctorRequestsScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const DoctorRequestsScreen({super.key, required this.currentUser});

  @override
  State<DoctorRequestsScreen> createState() => _DoctorRequestsScreenState();
}

class _DoctorRequestsScreenState extends State<DoctorRequestsScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      // Use the same API as Home Screen to get all requests for this hospital
      // "All Requests" implies history + active usually, or just active?
      // Given the UI had filters for status, let's fetch ALL.
      final requests = await ApiService.getRequestsByHospital(widget.currentUser['userId']);
      if (mounted) {
        setState(() {
          _requests = requests.reversed.toList(); // Newest first
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

  // Helper to filter if needed, or just show all. 
  // ensuring the screen matches the "All Requests" title.

  @override
  Widget build(BuildContext context) {
    // Basic stats
    final activeCount = _requests.where((r) => r['status'] == 'ACCEPTED' || r['status'] == 'ON_THE_WAY' || r['status'] == 'PICKED_UP').length;
    final pendingCount = _requests.where((r) => r['status'] == 'PENDING').length;
    
    // Today count
    final now = DateTime.now();
    final todayCount = _requests.where((r) {
      if (r['date'] == null) return false;
      try {
        final parts = r['date'].toString().split('-');
        final d = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        return d.year == now.year && d.month == now.month && d.day == now.day;
      } catch (e) {
        return false;
      }
    }).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchRequests,
          color: const Color(0xFFE0463A),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "All Requests",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 16),

                // ----------------------------
                // FILTER BUTTON (Visual only for now, can implement logic later if needed)
                // ----------------------------
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.filter_list, color: Colors.black),
                      SizedBox(width: 10),
                      Text(
                        "Filter by status & urgency",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ----------------------------
                // STATS ROW
                // ----------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statBox("$activeCount", "Active", Colors.blue.shade50, Colors.blue),
                    _statBox(
                      "$pendingCount",
                      "Pending",
                      Colors.yellow.shade50,
                      Colors.orange,
                    ),
                    _statBox("$todayCount", "Today", Colors.green.shade50, Colors.green),
                  ],
                ),

                const SizedBox(height: 20),

                // ----------------------------
                // REQUEST LIST
                // ----------------------------
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_requests.isEmpty)
                   const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No requests found.")))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                      if (status == "ACCEPTED" || status == "PICKED_UP") btnText = "Track Delivery";

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
                             if (status == "ACCEPTED" || status == "PICKED_UP") {
                                // Navigate to tracking if supported
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (c) => const DoctorLiveTrackingScreen(),
                                  ),
                                );
                             } else {
                               // Detail view logic
                             }
                          },
                        ),
                      );
                    },
                  ),
              ],
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
