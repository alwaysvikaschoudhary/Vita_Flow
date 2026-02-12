import 'package:vita_flow/screens/Rider/pickup_screen.dart';
import 'package:flutter/material.dart'; // ← ADD THIS IMPORT

class RiderHomeScreen extends StatelessWidget {
  final Map<String, dynamic> currentUser;
  const RiderHomeScreen({super.key, required this.currentUser});

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
              _header(),

              const SizedBox(height: 16),

              _statsRow(),

              const SizedBox(height: 16),

              _onlineCard(),

              const SizedBox(height: 16),

              const Text(
                "Active Tasks",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 12),

              _taskCard(
                context,
                name: "Jitesh Kumar",
                bloodType: "O+",
                hospital: "Balaji Soni Hospital",
                distance: "1.2 km",
                tag: "Pickup Pending",
                tagColor: Colors.orange,
              ),

              const SizedBox(height: 12),

              _taskCard(
                context,
                name: "Sarah Johnson",
                bloodType: "A+",
                hospital: "HCG Cancer Hospital",
                distance: "5.5 km",
                tag: "In Transit",
                tagColor: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hi, ${currentUser['name']} 👋",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                Text("Vehicle: ${currentUser['bikeNumber'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 15, color: Colors.grey)),
              ],
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.red.shade50,
            child: const Icon(Icons.notifications, color: Colors.red),
          ),
        ],
      ),
    );
  }

  // ---------------- STATS ROW ----------------
  Widget _statsRow() {
    return Row(
      children: [
        _statBox(Icons.local_shipping, Colors.blue, "2", "Active"),
        _statBox(Icons.currency_rupee, Colors.red, "₹490", "Today"),
        _statBox(Icons.trending_up, Colors.purple, "52", "Total"),
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
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // ---------------- ONLINE CARD ----------------
  Widget _onlineCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.shade400,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("You're Online",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              Switch(value: true, onChanged: (_) {}, activeColor: Colors.white),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: const [
              Expanded(child: MiniStat("Rating", "4.8")),
              SizedBox(width: 10),
              Expanded(child: MiniStat("Acceptance", "96%")),
            ],
          )
        ],
      ),
    );
  }
}

// ---------------- MINI STAT ----------------
class MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const MiniStat(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

// ---------------- TASK CARD ----------------
Widget _taskCard(
  BuildContext context, {
  required String name,
  required String bloodType,
  required String hospital,
  required String distance,
  required String tag,
  required Color tagColor,
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
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: tagColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(tag, style: TextStyle(color: tagColor, fontSize: 12)),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Text("Blood Type: $bloodType",
            style: const TextStyle(color: Colors.red)),

        Text(hospital, style: const TextStyle(color: Colors.black87)),
        Text(distance, style: const TextStyle(color: Colors.grey)),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE0463A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            // ---------------- NAVIGATION FIX ----------------
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PickupVerificationScreen(),
                ),
              );
            },
            child: const Text("Start Pickup"),
          ),
        ),
      ],
    ),
  );
}
