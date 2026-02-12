import 'package:flutter/material.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Requests",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Mark all as read",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),

            // FILTER BAR
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: const [
                  Icon(Icons.filter_list, color: Colors.black54),
                  SizedBox(width: 8),
                  Text("Filter notifications"),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _alertCard(
                      urgent: true,
                      title: "Urgent: O+ Blood Needed",
                      hospital: "City General Hospital",
                      time: "2 min ago",
                      distance: "1.2 km away",
                      showButton: true,
                    ),
                    _alertCard(
                      urgent: false,
                      title: "New Match Found",
                      hospital: "St. Mary Medical Center",
                      time: "15 min ago",
                      distance: "2.5 km away",
                    ),
                    _alertCard(
                      urgent: false,
                      title: "Donation Reminder",
                      hospital: "You're eligible to donate again",
                      time: "1 hour ago",
                      distance: "",
                    ),
                    _alertCard(
                      urgent: false,
                      title: "Request Nearby",
                      hospital: "Community Health Center",
                      time: "3 hours ago",
                      distance: "4.2 km away",
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

  Widget _alertCard({
    required bool urgent,
    required String title,
    required String hospital,
    required String time,
    required String distance,
    bool showButton = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color:  Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: urgent ? Border.all(color: Color(0xFFE0463A), width: 1.3) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE + URGENT TAG
          Row(
            children: [
              Icon(
                urgent ? Icons.notifications_active : Icons.notifications_none,
                color: urgent ? Color(0xFFE0463A) : Colors.grey,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: urgent ? Colors.red : Colors.black,
                  ),
                ),
              ),
              if (urgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Urgent",
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),
          Text(hospital, style: const TextStyle(fontSize: 15, color: Colors.black87)),
          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: const TextStyle(color: Colors.grey)),
              if (distance.isNotEmpty)
                Text(distance, style: const TextStyle(color: Colors.grey)),
            ],
          ),

          if (showButton) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE0463A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: const Text("View Details", style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
