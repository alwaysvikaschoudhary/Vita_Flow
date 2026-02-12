import 'package:flutter/material.dart';

class DoctorLiveTrackingScreen extends StatelessWidget {
  const DoctorLiveTrackingScreen({super.key});

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
                    children: const [
                      Text(
                        "Live Tracking",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "Request #VF-2345",
                        style: TextStyle(
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
              // PROGRESS BAR
              // -----------------------------------------
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.55,
                  minHeight: 6,
                  color: Colors.black,
                  backgroundColor: Colors.grey.shade300,
                ),
              ),

              const SizedBox(height: 10),

              // -----------------------------------------
              // STATUS STEPS
              // -----------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statusStep(true, "Request\nCreated"),
                  _statusStep(true, "Donor\nAccepted"),
                  _statusStep(false, "Rider\nRoute", stepNum: "3"),
                  _statusStep(false, "Delivered\nSuccessfull", stepNum: "4"),
                ],
              ),

              const SizedBox(height: 10),

              // -----------------------------------------
              // MAP IMAGE
              // -----------------------------------------
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  "assets/images/map_demo.png",
                  height: 230,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 10),

              // -----------------------------------------
              // DONOR INFORMATION CARD
              // -----------------------------------------
              _infoCard(
                title: "Donor Information",
                name: "Jitesh Kumar",
                bloodType: "O+",
                id: "VF-D-1234",
                icon: Icons.person,
              ),

              const SizedBox(height: 10),

              // -----------------------------------------
              // RIDER INFORMATION CARD
              // -----------------------------------------
              _infoCard(
                title: "Rider Information",
                name: "Rahul Singh",
                bloodType: null,
                id: "VF-R-2341",
                vehicle: "MH-12-AB-1234",
                icon: Icons.pedal_bike,
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

              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.green.shade100,
                child: const Icon(Icons.phone, color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
