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
              // VERIFICATION STATUS
              // ------------------------------
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

              // ------------------------------
              // HOSPITAL INFO CARD
              // ------------------------------
              _infoSection(
                title: "Hospital Information",
                children: [
                  _infoItem(Icons.local_hospital, "Hospital Name", user['hospitalName'] ?? "--"),
                  _infoItem(Icons.phone, "Contact", user['phoneNumber'] ?? "--"),
                  _infoItem(Icons.email, "Email", user['email'] ?? "--"),
                  _infoItem(Icons.location_on, "Address", user['address'] ?? "--"),
                  _infoItem(Icons.school, "Degree", user['degree'] ?? "--"),
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
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Logout"),
                          content: const Text("Are you sure you want to logout?"),
                          actions: [
                            TextButton(
                              child: const Text("Cancel"),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            TextButton(
                              child: const Text("Logout", style: TextStyle(color: Colors.red)),
                              onPressed: () {
                                Navigator.of(context).pop(); // Close dialog
                                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const Login()),
                                  (route) => false,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  label: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateCompletion() {
    int total = 9;
    int filled = 0;
    
    if (_hasValue('name')) filled++;
    if (_hasValue('phoneNumber')) filled++;
    if (_hasValue('email')) filled++;
    if (_hasValue('hospitalName')) filled++;
    if (_hasValue('specialization')) filled++;
    if (_hasValue('experience')) filled++;
    if (_hasValue('gender')) filled++;
    if (_hasValue('address')) filled++;
    if (_hasValue('degree')) filled++;

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
  Widget _infoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
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
