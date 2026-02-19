import 'package:flutter/material.dart';
import 'package:vita_flow/services/api_service.dart';

class RiderHistoryScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const RiderHistoryScreen({super.key, required this.currentUser});

  @override
  State<RiderHistoryScreen> createState() => _RiderHistoryScreenState();
}

class _RiderHistoryScreenState extends State<RiderHistoryScreen> {
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }
  
  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    try {
      final history = await ApiService.getRiderHistory(widget.currentUser['userId']);
      if (mounted) {
        setState(() {
          _history = history.reversed.toList(); // Show newest first
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchHistory,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: const Text("Delivery History",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
               ),

              Expanded(
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : _history.isEmpty
                    ? const Center(child: Text("No delivery history found"))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final req = _history[index];
                          final hospitalName = req['hospitalName'] ?? "Unknown Hospital";
                          final bloodGroup = req['bloodGroup'] ?? "?";
                          final date = req['date'] ?? "";
                          final time = req['time'] ?? "";
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _historyTile(
                              bloodType: bloodGroup,
                              date: date,
                              hospital: hospitalName,
                              // distance: "2.5 km", // We don't have distance in history easily without calculation
                              time: time,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _historyTile({
    required String bloodType,
    required String date,
    required String hospital,
    String? distance,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.red.shade50,
            child: Text(
              bloodType,
              style: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hospital,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                     Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                     SizedBox(width: 4),
                     Text(date, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                     SizedBox(width: 10),
                     Icon(Icons.access_time, size: 12, color: Colors.grey),
                     SizedBox(width: 4),
                     Text(time, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                if (distance != null)
                Text(distance, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          
          Column(
             children: [
               Text("Completed", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
               Icon(Icons.check_circle, color: Colors.green),
             ]
          )
        ],
      ),
    );
  }
}
