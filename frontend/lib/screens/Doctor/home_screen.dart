import 'package:vita_flow/services/api_service.dart';
import 'package:vita_flow/screens/Doctor/create_request_screen.dart';
import 'package:flutter/material.dart';

class DoctorHomeScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const DoctorHomeScreen({super.key, required this.currentUser});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      final requests = await ApiService.getRequestsByHospital(widget.currentUser['userId']);
      if (mounted) {
        setState(() {
          // Sort reverse to show newest first
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ----------------------------
              // HEADER
              // ----------------------------
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.currentUser['hospitalName'] ?? "Hospital",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "Dr. ${widget.currentUser['name']}",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.red.shade50,
                      child: const Icon(Icons.notifications, color: Colors.red),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ----------------------------
              // STATS ROW
              // ----------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statCard(Icons.monitor_heart, Colors.blue, "${_requests.where((r) => r['status'] == 'ACCEPTED').length}", "Active"),
                  _statCard(Icons.access_time, Colors.orange, "${_requests.where((r) => r['status'] == 'PENDING').length}", "Pending"),
                  _statCard(Icons.check_circle, Colors.green, "${_requests.where((r) => r['status'] == 'COMPLETED').length}", "Today"),
                ],
              ),

              const SizedBox(height: 10),

              // ----------------------------
              // CREATE NEW REQUEST BUTTON
              // ----------------------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0463A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => CreateBloodRequestScreen(currentUser: widget.currentUser),
                              ),
                            );
                    if (result == true) {
                      _fetchRequests();
                    }
                  },
                  child: const Text(
                    "+   Create New Request",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ----------------------------
              // AVAILABLE STOCK
              // ----------------------------
              const Text(
                "Available Stock",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _stockCard("A+", "18 units"),
                    _stockCard("B+", "17 units"),
                    _stockCard("O+", "2 units"),
                    _stockCard("AB+", "17 units"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ----------------------------
              // ACTIVE REQUESTS LIST
              // ----------------------------
              const Text(
                "Active Requests",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),
              
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_requests.isEmpty)
                const Center(child: Text("No active requests found.", style: TextStyle(color: Colors.grey)))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final req = _requests[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _requestCard(req),
                    );
                  },
                ),

              
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------
  // STAT CARD
  // -----------------------------------------
  Widget _statCard(IconData icon, Color color, String value, String label) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // -----------------------------------------
  // REQUEST CARD (Dynamic)
  // -----------------------------------------
  Widget _requestCard(dynamic req) {
    String status = req['status'] ?? "PENDING";
    Color statusColor = Colors.orange;
    if (status == "ACCEPTED") statusColor = Colors.blue;
    if (status == "COMPLETED") statusColor = Colors.green;
    if (status == "CANCELLED") statusColor = Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        "Status : ",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
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
                const SizedBox(height: 6),
                Text("Target: ${req['bloodGroup']}", style: TextStyle(color: Colors.grey[600])),
                Text(
                  "${req['units']} Units • ${req['urgency']}",
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // Time / ETA
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _timeAgo(req['date'], req['time']),
                style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(String? dateStr, String? timeStr) {
    if (dateStr == null || timeStr == null) return "Just now";
    try {
      final now = DateTime.now();
      final dateParts = dateStr.split('-');
      final timeParts = timeStr.split(':');

      if (dateParts.length == 3 && timeParts.length >= 2) {
        final year = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final day = int.parse(dateParts[2]);
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final dt = DateTime(year, month, day, hour, minute);

        final diff = now.difference(dt);

        if (diff.inDays >= 365) {
          return "${(diff.inDays / 365).floor()} years ago";
        } else if (diff.inDays >= 30) {
          return "${(diff.inDays / 30).floor()} months ago";
        } else if (diff.inDays > 0) {
          return "${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'} ago";
        } else if (diff.inHours > 0) {
          final mins = diff.inMinutes % 60;
          if (mins > 0) {
             return "${diff.inHours} h $mins min ago";
          }
          return "${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago";
        } else if (diff.inMinutes > 0) {
          return "${diff.inMinutes} min ago";
        } else {
          return "Just now";
        }
      }
      return "Recently";
    } catch (e) {
      return "Recently";
    }
  }

  // -----------------------------------------
  // STOCK CARD
  // -----------------------------------------
  Widget _stockCard(String type, String units) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            type,
            style: const TextStyle(
                color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(units),
        ],
      ),
    );
  }
  
}
