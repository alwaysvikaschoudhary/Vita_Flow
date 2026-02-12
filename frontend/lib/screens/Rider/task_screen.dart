import 'package:flutter/material.dart';

class RiderTasksScreen extends StatelessWidget {
  const RiderTasksScreen({super.key});

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

              const Text(
                "Available Tasks",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 16),

              _filterBar(),

              const SizedBox(height: 20),

              _topStats(),

              const SizedBox(height: 20),

              _taskTile(
                bloodType: "AB+",
                urgency: "High",
                urgencyColor: Colors.orange,
                name: "Khushi Singh",
                distance: "0.8 km",
                reward: "₹35",
                destination: "Community Health Center",
                pickupTime: "15 mins",
              ),

              const SizedBox(height: 16),

              _taskTile(
                bloodType: "B-",
                urgency: "Medium",
                urgencyColor: Colors.yellow.shade800,
                name: "Gopal Sharma",
                distance: "2.1 km",
                reward: "₹45",
                destination: "Gitanjali Hospital",
                pickupTime: "30 mins",
              ),
            ],
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
        _statBox(Icons.inventory_2_outlined, Colors.blue, "12", "Available"),
        _statBox(Icons.directions_bike, Colors.green, "2", "Active"),
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

  Widget _taskTile({
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
              onPressed: () {},
              child: const Text("Accept Task"),
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
