import 'package:flutter/material.dart';

class RiderHistoryScreen extends StatelessWidget {
  const RiderHistoryScreen({super.key});

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

              const Text("Delivery History",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),

              const SizedBox(height: 20),

              _weeklySummary(),

              const SizedBox(height: 20),

              _historyTile(
                bloodType: "O+",
                date: "October 12, 2025",
                hospital: "City Hospital",
                distance: "1.2 km",
                time: "2:45 PM",
                earning: "₹50",
              ),

              const SizedBox(height: 12),

              _historyTile(
                bloodType: "A+",
                date: "October 12, 2025",
                hospital: "St. Hospital",
                distance: "3.5 km",
                time: "11:30 AM",
                earning: "₹80",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _weeklySummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _moneyRow("Base Pay", "₹520"),
          _moneyRow("Tips", "₹120"),
          _moneyRow("Bonuses", "₹50"),
          const Divider(),
          _moneyRow("Total", "₹6080", bold: true),
        ],
      ),
    );
  }

  Widget _moneyRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(color: Colors.black54, fontSize: 15)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyTile({
    required String bloodType,
    required String date,
    required String hospital,
    required String distance,
    required String time,
    required String earning,
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
                Text(date, style: const TextStyle(color: Colors.grey)),
                Text(distance, style: const TextStyle(color: Colors.grey)),
                Text(time, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          Text(earning,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
