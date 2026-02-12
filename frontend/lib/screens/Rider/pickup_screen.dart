import 'package:flutter/material.dart';

class PickupVerificationScreen extends StatelessWidget {
  final String donorName;
  final String bloodType;
  final String address;

  const PickupVerificationScreen({
    super.key,
    this.donorName = "Jitesh Kumar",
    this.bloodType = "O+",
    this.address = "123 Main Street, Apartment 4B",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: Column(
          children: [
            _header(context),

            const SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _qrBox(),

                    const SizedBox(height: 20),

                    const Text(
                      "Donor Information",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),

                    const SizedBox(height: 12),

                    _donorCard(),

                    const SizedBox(height: 30),

                    _pickupButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------- HEADER -----------------------
  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFEFF0F6),
              child: Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Pickup Verification",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              Text(
                "Scan Donor QR Code",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------- QR BOX ------------------------
  Widget _qrBox() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Container(
            height: 240,
            width: 240,
            decoration: BoxDecoration(
              color: const Color(0xFF121521),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade300, width: 3),
            ),
            child: const Center(
              child: Icon(Icons.qr_code_2, size: 120, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Position the QR code within the frame",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // --------------------- DONOR INFO CARD ------------------------
  Widget _donorCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.red.shade50,
                child: const Icon(Icons.person, color: Colors.red, size: 30),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donorName,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  Text("Blood Type: $bloodType",
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const Spacer(),
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.green.shade100,
                child: const Icon(Icons.call, color: Colors.green),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(Icons.location_on, size: 20, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------- BUTTON ------------------------
  Widget _pickupButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE0463A),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () {
          // next screen you want
        },
        child: const Text(
          "Start Pickup",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
