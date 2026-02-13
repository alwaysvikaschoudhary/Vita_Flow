import 'package:vita_flow/screens/role_select.dart';
import 'package:vita_flow/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:vita_flow/screens/Doctor/edit_profile_screen.dart';

class DoctorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const DoctorProfileScreen({super.key, required this.currentUser});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  bool notifyDonorMatches = true;
  bool notifyDeliveryUpdates = false;
  bool notifyEmergencyAlerts = true;
  
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------
              // PAGE HEADER
              // ------------------------------
              const Text(
                "Hospital Profile",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              // ------------------------------
              // HOSPITAL TITLE CARD
              // ------------------------------
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.local_hospital,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Hospital name + dept
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['name'] ?? "Unknown Name",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user['specialization'] ?? "General",
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Edit button
                        GestureDetector(
                          onTap: () async {
                              final updated = await Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (_) => EditDoctorProfileScreen(currentUser: user)),
                              );
                              if (updated != null) {
                                setState(() {
                                  user = updated;
                                });
                              }
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.edit, color: Colors.black),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statsBox(user['experience'] ?? "--", "Experience"),
                        _statsBox(user['gender'] ?? "--", "Gender"),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ------------------------------
              // HOSPITAL INFO CARD
              // ------------------------------
              _infoSection(
                title: "Hospital Information",
                children: [
                  _infoItem("Hospital Name", user['hospitalName'] ?? "--"),
                  _infoItem("Contact", user['phoneNumber'] ?? "--"),
                  _infoItem("Email", user['email'] ?? "--"),
                  _infoItem("Address", user['address'] ?? "--"),
                  _infoItem("Degree", user['degree'] ?? "--"),
                  if (user['about'] != null) ...[
                     const SizedBox(height: 10),
                     const Text("About", style: TextStyle(color: Colors.black54)),
                     Text(user['about'], style: const TextStyle(fontWeight: FontWeight.w500)),
                  ]
                ],
              ),

              const SizedBox(height: 10),

              // ------------------------------
              // NOTIFICATION SETTINGS
              // ------------------------------
//               _infoSection(
//                 title: "Notification Preferences",
//                 children: [
//                   _toggleItem(
//                     "Donor Matches",
//                     notifyDonorMatches,
//                     (v) => setState(() => notifyDonorMatches = v),
//                   ),
//                   // ... other toggles
//                 ],
//               ),

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
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const Login(),
                      ),
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
      ),
    );
  }

  // ------------------------------------------
  // SMALL STAT BOX
  // ------------------------------------------
  Widget _statsBox(String value, String label) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        // color: Colors.white.withOpacity(.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  // ------------------------------------------
  // SECTION WRAPPER
  // ------------------------------------------
  Widget _infoSection({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          ...children,
        ],
      ),
    );
  }

  // ------------------------------------------
  // INFO ROW
  // ------------------------------------------
  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------
  // SWITCH TOGGLE ROW
  // ------------------------------------------
  Widget _toggleItem(String text, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.notifications_none, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
          Switch(value: value, onChanged: onChanged, activeColor: Colors.red),
        ],
      ),
    );
  }
}
