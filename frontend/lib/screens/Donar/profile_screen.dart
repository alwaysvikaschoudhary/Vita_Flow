import 'package:vita_flow/screens/Donar/personal_info_screen.dart';
import 'package:vita_flow/screens/Donar/verification_complete_screen.dart';
import 'package:vita_flow/screens/role_select.dart';
import 'package:vita_flow/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:vita_flow/screens/Donar/edit_donor_profile_screen.dart';

import 'profile_verification_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const ProfileScreen({super.key, required this.currentUser});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, dynamic> user;

  @override
  void initState() {
    super.initState();
    user = widget.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 245, 223, 223),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.red,
                        child: Text(
                          (user['name'] != null && user['name'].length > 0) ? user['name'][0].toUpperCase() : "U",
                          style: const TextStyle(fontSize: 22, color: Colors.white),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name'] ?? "Unknown",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "Blood Type: ${user['bloodGroup'] ?? 'Unknown'}",
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),

                      // Edit button
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,

                        child: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            size: 24,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                              final updated = await Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (_) => EditDonorProfileScreen(currentUser: user)),
                              );
                              if (updated != null) {
                                setState(() {
                                  user = updated;
                                });
                              }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      StatBox(user['numberOfDonation'] ?? "0", "Donations"),
                      // StatBox("4.9", "Rating"), // Rating not in Donor entity currently
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Verification Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Builder(
                builder: (context) {
                  double percentage = _calculateCompletion();
                  int percentInt = (percentage * 100).toInt();
                  bool isComplete = percentage == 1.0;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Verification Status",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text("$percentInt%", style: TextStyle(color: _getColor(percentage))),
                          const Spacer(),
                          Text(
                            isComplete ? "Complete" : "Incomplete", 
                            style: TextStyle(color: isComplete ? Colors.green : Colors.red),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: percentage,
                        color: _getColor(percentage),
                        backgroundColor: Colors.grey.shade300,
                      ),
                      if (!isComplete) ...[
                        const SizedBox(height: 10),
                         const Text(
                          "⚠ Complete your profile to get faster verification",
                          style: TextStyle(color: Color.fromARGB(255, 65, 63, 63)),
                        ),
                      ]
                    ],
                  );
                }
              ),
            ),

            const SizedBox(height: 10),

            // Personal Info Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Personal Information",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  InfoRow("Phone", user['phoneNumber'] ?? "--"),
                  InfoRow("Email", user['email'] ?? "--"),
                  InfoRow("Age", user['age'] ?? "--"),
                  InfoRow("Weight(kg)", user['weight'] ?? "--"),
                  InfoRow("Height(cm)", user['height'] ?? "--"),
                  InfoRow("Address", user['address'] ?? "--"),
                  if (user['gender'] != null) InfoRow("Gender", user['gender']),
                  if (user['medicalHistory'] != null) ...[
                      const SizedBox(height: 6),
                      Text("Medical History: ${user['medicalHistory']}", style: const TextStyle(color: Colors.black54)),
                  ]
                ],
              ),
            ),

          

            const SizedBox(height: 10),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 120),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const Login()),
                    (route) => false,
                  );

                },

                child: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateCompletion() {
    int total = 10;
    int filled = 0;
    
    if (_hasValue('name')) filled++;
    if (_hasValue('phoneNumber')) filled++;
    if (_hasValue('email')) filled++;
    if (_hasValue('bloodGroup')) filled++;
    if (_hasValue('age')) filled++;
    if (_hasValue('weight')) filled++;
    if (_hasValue('height')) filled++;
    if (_hasValue('address')) filled++;
    if (_hasValue('gender')) filled++;
    if (_hasValue('medicalHistory')) filled++;

    return filled / total;
  }

  bool _hasValue(String key) {
    var val = user[key];
    return val != null && val.toString().trim().isNotEmpty;
  }

  Color _getColor(double percentage) {
    if (percentage < 0.3) return Colors.red;
    if (percentage < 0.7) return Colors.orange;
    return Colors.green;
  }
}

class StatBox extends StatelessWidget {
  final String value;
  final String label;

  const StatBox(this.value, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label, value;
  const InfoRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}
