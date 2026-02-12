import 'package:vita_flow/screens/Doctor/track_delivery_screen.dart';
import 'package:flutter/material.dart';

class DoctorRequestsScreen extends StatelessWidget {
  const DoctorRequestsScreen({super.key});

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
                "All Requests",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 16),

              // ----------------------------
              // FILTER BUTTON
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
                  _statBox("5", "Active", Colors.blue.shade50, Colors.blue),
                  _statBox(
                    "3",
                    "Pending",
                    Colors.yellow.shade50,
                    Colors.orange,
                  ),
                  _statBox("28", "Today", Colors.green.shade50, Colors.green),
                ],
              ),

              const SizedBox(height: 20),

              // ----------------------------
              // REQUEST CARD 1
              // ----------------------------
              _requestCard(
                blood: "O+",
                units: "2 units",
                timeAgo: "15 mins ago",
                donorName: "Jitesh Kumar",
                urgency: "Critical",
                urgencyColor: Colors.red,
                status: "Active",
                statusColor: Colors.blue,
                buttonText: "Track Delivery",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => const DoctorLiveTrackingScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ----------------------------
              // REQUEST CARD 2
              // ----------------------------
              _requestCard(
                blood: "A+",
                units: "1 unit",
                timeAgo: "1 hour ago",
                donorName: "Waiting for match",
                urgency: "Medium",
                urgencyColor: Colors.orange,
                status: "Pending",
                statusColor: Colors.yellow.shade700,
                buttonText: "View Details",
                onPressed: () {},
              ),

              const SizedBox(height: 16),

              // ----------------------------
              // REQUEST CARD 3
              // ----------------------------
              _requestCard(
                blood: "B+",
                units: "3 units",
                timeAgo: "2 hours ago",
                donorName: "Sneha Verma",
                urgency: "High",
                urgencyColor: Colors.deepOrange,
                status: "Active",
                statusColor: Colors.blue,
                buttonText: "Track Delivery",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => const DoctorLiveTrackingScreen(),
                    ),
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
              child: Text(buttonText, style: TextStyle(color: Colors.white),),
            ),
          ),
        ],
      ),
    );
  }
}
