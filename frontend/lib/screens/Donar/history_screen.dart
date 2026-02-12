import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Donation History",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
            ),

            // METRICS BOX
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _metricBox(Icons.favorite_border, Colors.red, "13", "Donations",
                    Colors.red.shade100),
                _metricBox(Icons.emoji_events_outlined, Colors.green, "39",
                    "Lives Saved", Colors.green.shade100),
                _metricBox(Icons.location_on_outlined, Colors.blue, "52",
                    "km Traveled", Colors.blue.shade100),
              ],
            ),

            const SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _historyCard(
                      hospital: "Gitanjali Hostel (Bhankrota)",
                      date: "October 12, 2025",
                      bloodType: "O+",
                      units: "1",
                      distance: "1.2 km",
                    ),
                    _historyCard(
                      hospital: "Balaji Soni Hospital",
                      date: "August 5, 2025",
                      bloodType: "A-",
                      units: "1",
                      distance: "3.5 km",
                    ),
                    _historyCard(
                      hospital: "HCG Cancer Hospital",
                      date: "June 20, 2025",
                      bloodType: "O-",
                      units: "2",
                      distance: "2.1 km",
                    ),
                    _historyCard(
                      hospital: "Manipal Hospital",
                      date: "April 15, 2025",
                      bloodType: "AB+",
                      units: "1",
                      distance: "2.7 km",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricBox(
      IconData icon, Color iconColor, String value, String label, Color bg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  Widget _historyCard({
    required String hospital,
    required String date,
    required String bloodType,
    required String units,
    required String distance,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(hospital,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text("Completed",
                    style: TextStyle(color: Colors.green)),
              )
            ],
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(date, style: const TextStyle(color: Colors.grey)),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _historyField("Blood Type", bloodType,
                  valueColor: Colors.red), // ← RED BLOOD TYPE
              _historyField("Units", units),
              _historyField("Distance", distance),
            ],
          ),
        ],
      ),
    );
  }

  Widget _historyField(String label, String value,
      {Color valueColor = Colors.black}) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor, // dynamic color
          ),
        ),
      ],
    );
  }
}
