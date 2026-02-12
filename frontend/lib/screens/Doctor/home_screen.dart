import 'package:vita_flow/screens/Doctor/create_request_screen.dart';
import 'package:flutter/material.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

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
                        children: const [
                          Text(
                            "City General Hospital",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "Emergency Requests",
                            style: TextStyle(
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
                  _statCard(Icons.monitor_heart, Colors.blue, "5", "Active"),
                  _statCard(Icons.access_time, Colors.orange, "3", "Pending"),
                  _statCard(Icons.check_circle, Colors.green, "28", "Today"),
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
                  onPressed: () {
                    Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => const CreateBloodRequestScreen(),
                              ),
                            );
                  },
                  child: const Text(
                    "+   Create New Request",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ----------------------------
              // ACTIVE DELIVERIES
              // ----------------------------
              const Text(
                "Active Deliveries",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),
              _deliveryCard(
                name: "Jitesh Kumar",
                bloodType: "O+",
                units: "2 units",
                eta: "12 mins",
                tag: "In Transit",
                tagColor: Colors.blue,
              ),

              const SizedBox(height: 12),
              _deliveryCard(
                name: "Sarah Johnson",
                bloodType: "A+",
                units: "1 unit",
                eta: "25 mins",
                tag: "Collection",
                tagColor: Colors.orange,
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
  // DELIVERY CARD
  // -----------------------------------------
  Widget _deliveryCard({
    required String name,
    required String bloodType,
    required String units,
    required String eta,
    required String tag,
    required Color tagColor,
  }) {
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
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: tagColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(color: tagColor, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text("Blood Type:", style: TextStyle(color: Colors.grey[600])),
                Text(
                  bloodType,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600),
                ),
                Text(units),
              ],
            ),
          ),

          // ETA
          Text(
            "ETA: $eta",
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
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

