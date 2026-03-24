import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorLiveTrackingScreen extends StatelessWidget {
  final Map<String, dynamic> requestData;

  const DoctorLiveTrackingScreen({super.key, required this.requestData});

  @override
  Widget build(BuildContext context) {
    String status = requestData['status'] ?? "";
    String deliveryOtp = requestData['deliveryOtp'] ?? "----";
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // -----------------------------------------
              // HEADER
              // -----------------------------------------
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Live Tracking",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "Request #${requestData['requestId']?.substring(0, 8) ?? 'VF-2345'}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // -----------------------------------------
              // DELIVERY OTP (Only show if PICKED_UP)
              // -----------------------------------------
              if (status == "PICKED_UP") ...[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Delivery OTP",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        deliveryOtp,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // -----------------------------------------
              // PROGRESS BAR
              // -----------------------------------------
              Builder(builder: (context) {
                final double progress;
                final bool step1, step2, step3, step4;
                switch (status.toUpperCase()) {
                  case 'ACCEPTED':
                    progress = 0.40; step1 = true; step2 = true; step3 = false; step4 = false;
                    break;
                  case 'RIDER_ASSIGNED':
                  case 'ON_THE_WAY':
                    progress = 0.65; step1 = true; step2 = true; step3 = true; step4 = false;
                    break;
                  case 'PICKED_UP':
                  case 'COLLECTED':
                    progress = 0.80; step1 = true; step2 = true; step3 = true; step4 = false;
                    break;
                  case 'COMPLETED':
                  case 'DELIVERED':
                    progress = 1.0; step1 = true; step2 = true; step3 = true; step4 = true;
                    break;
                  default: // PENDING
                    progress = 0.20; step1 = true; step2 = false; step3 = false; step4 = false;
                }
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        color: Colors.black,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _statusStep(step1, "Request\nCreated", stepNum: "1"),
                        _statusStep(step2, "Donor\nAccepted", stepNum: "2"),
                        _statusStep(step3, "Rider\nRoute", stepNum: "3"),
                        _statusStep(step4, "Delivered\nSuccessfull", stepNum: "4"),
                      ],
                    ),
                  ],
                );
              }),

              const SizedBox(height: 10),

              // -----------------------------------------
              // DONOR INFORMATION CARD
              // -----------------------------------------
              _infoCard(
                title: "Donor Information",
                name: requestData['donorName'] ?? "Donor",
                bloodType: requestData['bloodGroup'],
                id: requestData['donorId'] ?? "N/A",
                icon: Icons.favorite,
                phoneNumber: requestData['donorPhoneNumber'],
              ),

              const SizedBox(height: 10),

              // -----------------------------------------
              // RIDER INFORMATION CARD
              // -----------------------------------------
              _infoCard(
                title: "Rider Information",
                name: requestData['riderName'] ?? "Rider",
                bloodType: null,
                id: requestData['riderId'] ?? "N/A",
                vehicle: requestData['riderBikeNumber'] ?? "N/A",
                icon: Icons.delivery_dining,
                phoneNumber: requestData['riderPhoneNumber'],
              ),

            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------
  // STATUS STEP WIDGET
  // -----------------------------------------
  Widget _statusStep(bool done, String text, {String? stepNum}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor:
              done ? Colors.green : Colors.grey.shade300,
          child: done
              ? const Icon(Icons.check, color: Colors.white)
              : Text(
                  stepNum ?? "",
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // -----------------------------------------
  // DONOR / RIDER INFO CARD
  // -----------------------------------------
  Widget _infoCard({
    required String title,
    required String name,
    required String id,
    required IconData icon,
    String? bloodType,
    String? vehicle,
    String? phoneNumber,
  }) {
    Future<void> makeCall() async {
      if (phoneNumber == null || phoneNumber.isEmpty) return;
      final uri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600)),

          const SizedBox(height: 12),

          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.grey.shade200,
                child: Icon(icon, color: Colors.red, size: 26),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    if (bloodType != null) ...[
                      const SizedBox(height: 4),
                      Text("Blood Type: $bloodType",
                          style: const TextStyle(color: Colors.black)),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      bloodType != null
                          ? "Donor ID: $id"
                          : "Rider ID: $id",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    if (vehicle != null) ...[
                      const SizedBox(height: 4),
                      Text("Vehicle: $vehicle",
                          style: TextStyle(color: Colors.grey.shade700)),
                    ],
                  ],
                ),
              ),

              GestureDetector(
                onTap: makeCall,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: (phoneNumber != null && phoneNumber.isNotEmpty)
                      ? Colors.green.shade100
                      : Colors.grey.shade200,
                  child: Icon(
                    Icons.phone,
                    color: (phoneNumber != null && phoneNumber.isNotEmpty)
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
