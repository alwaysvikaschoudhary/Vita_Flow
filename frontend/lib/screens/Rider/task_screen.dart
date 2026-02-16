import 'package:flutter/material.dart';

import 'package:vita_flow/services/api_service.dart';
import 'package:vita_flow/screens/Rider/pickup_screen.dart';

class RiderTasksScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const RiderTasksScreen({super.key, required this.currentUser});

  @override
  State<RiderTasksScreen> createState() => _RiderTasksScreenState();
}

class _RiderTasksScreenState extends State<RiderTasksScreen> {
  List<dynamic> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final tasks = await ApiService.getRiderNearbyRequests(widget.currentUser['userId'] ?? widget.currentUser['id']);
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching tasks: $e");
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
        child: RefreshIndicator(
          onRefresh: _fetchTasks,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Available Tasks",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 16),

                _filterBar(),

                const SizedBox(height: 20),

                _topStats(),

                const SizedBox(height: 20),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_tasks.isEmpty)
                  const Center(child: Text("No available tasks found"))
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _tasks.length,
                    separatorBuilder: (ctx, index) => const SizedBox(height: 16),
                    itemBuilder: (ctx, index) {
                      final task = _tasks[index];
                      return _taskTile(
                        context,
                        request: task,
                        bloodType: task['bloodGroup'] ?? "?",
                        urgency: "High", // Placeholder logic
                        urgencyColor: Colors.orange,
                        name: task['donorName'] ?? "Unknown",
                        distance: "Nearby", // Geo logic to be added
                        reward: "₹--",
                        destination: task['hospitalName'] ?? "Unknown Hospital",
                        pickupTime: "ASAP",
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

  Widget _filterBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.filter_alt_outlined, color: Colors.black54),
          SizedBox(width: 10),
          Text("Filter by distance & payment",
              style: TextStyle(fontSize: 15, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _topStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statBox(Icons.inventory_2_outlined, Colors.blue, "${_tasks.length}", "Available"),
        _statBox(Icons.directions_bike, Colors.green, "0", "Active"), // Placeholder
        _statBox(Icons.location_on, Colors.purple, "5km", "Max Range"),
      ],
    );
  }

  Widget _statBox(IconData icon, Color color, String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _taskTile(
    BuildContext context, {
    required Map<String, dynamic> request,
    required String bloodType,
    required String urgency,
    required Color urgencyColor,
    required String name,
    required String distance,
    required String reward,
    required String destination,
    required String pickupTime,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                  const SizedBox(width: 12),
                  Text(name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              Text(reward,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),

          const SizedBox(height: 6),
          Text(distance, style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 12),

          _field("Destination", destination),
          _field("Pickup by", pickupTime),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: urgencyColor.withOpacity(.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  urgency,
                  style: TextStyle(color: urgencyColor, fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0463A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PickupVerificationScreen(
                      requestData: request, 
                      riderId: widget.currentUser['userId'] ?? widget.currentUser['id'],
                    ),
                  ),
                );
              },
              child: const Text("Accept Task", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(color: Colors.black54, fontSize: 14)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
