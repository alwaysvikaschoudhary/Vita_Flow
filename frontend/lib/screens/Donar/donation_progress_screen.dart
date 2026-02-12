import 'package:flutter/material.dart';
import 'donation_certificate_screen.dart';

class DonationProgressScreen extends StatelessWidget {
  const DonationProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 229, 230, 234),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Donation in Progress",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ],
              ),

              const SizedBox(height: 4),
              const Text(
                "City General Hospital",
                style: TextStyle(color: Colors.black),
              ),

              const SizedBox(height: 16),

              // Progress bar
              LinearProgressIndicator(
                value: 0.4,
                color: Colors.black,
                backgroundColor: const Color.fromARGB(255, 192, 192, 192),
              ),

              const SizedBox(height: 20),

              // Steps row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _step("1", "Request\nAccepted", true),
                  _step("2", "Rider\nAssigned", true),
                  _step("3", "Blood\nCollection", false),
                  _step("4", "Delivered\nSuccessful", false),
                ],
              ),

              const SizedBox(height: 10),

              // Rider card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.blue.shade50,
                      child: const Text("RS"),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Rahul Singh",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Rider ID: VF-R-2341",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: Icon(Icons.phone, color: Colors.green),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 11),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.location_on),
                    SizedBox(width: 8),
                    Text("Arriving in"),
                    Spacer(),
                    Text(
                      "12 mins",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // QR Code Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Verification QR Code",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Image.asset("assets/images/qr_demo.png", height: 300),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: false).push(
                          MaterialPageRoute(
                            builder: (c) => const DonationCertificateScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE0463A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Finish Donation",
                        style: TextStyle(color: Colors.white),
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
}

class _step extends StatelessWidget {
  final String num;
  final String text;
  final bool active;

  const _step(this.num, this.text, this.active);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: active
              ? Colors.red
              : const Color.fromARGB(255, 199, 199, 199),
          child: Text(num, style: const TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 6),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: active ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }
}
