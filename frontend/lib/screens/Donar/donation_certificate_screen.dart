import 'package:flutter/material.dart';

class DonationCertificateScreen extends StatelessWidget {
  const DonationCertificateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 229, 230, 234),
      
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              CircleAvatar(
                radius: 60,
                backgroundColor: const Color.fromARGB(255, 33, 235, 40),
                child: const Icon(
                  Icons.favorite,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "🎉 You Saved a Life!",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),
              const Text(
                "Your generous donation has made a real difference. Thank you for being a hero!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),

              const SizedBox(height: 20),

              // Certificate Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.workspace_premium,
                      color: Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Donation Certificate",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "October 12, 2025",
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 20),

                    _infoRow("Donor", "Jitesh Kumar"),
                    _infoRow(
                      "Blood Type",
                      "O+ Positive",
                      valueColor: Colors.red,
                    ),
                    _infoRow("Hemoglobin", "14.2 g/dL"),
                    _infoRow("Blood Pressure", "120/80 mmHg"),
                    _infoRow("Total Donations", "13", valueColor: Colors.red),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.emoji_events, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "New Badge Unlocked!\nLife Saver – 10+ Donations",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    Color valueColor = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: TextStyle(color: valueColor)),
        ],
      ),
    );
  }
}
