import 'package:vita_flow/screens/role_select.dart';
import 'package:vita_flow/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:vita_flow/screens/Donar/edit_donor_profile_screen.dart';
import 'package:vita_flow/services/api_service.dart';

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

  Future<void> _fetchProfile() async {
    try {
      final updatedUser = await ApiService.getDonorById(widget.currentUser['userId']);
      if (mounted) {
        setState(() {
          user = updatedUser;
        });
      }
    } catch (e) {
      print("Error fetching profile: $e");
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to refresh profile")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchProfile,
          color: const Color(0xFFE0463A),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                    InfoRow(Icons.phone, "Phone", user['phoneNumber'] ?? "--"),
                    InfoRow(Icons.email, "Email", user['email'] ?? "--"),
                    InfoRow(Icons.calendar_today, "Age", user['age'] ?? "--"),
                    InfoRow(Icons.monitor_weight, "Weight(kg)", user['weight'] ?? "--"),
                    InfoRow(Icons.height, "Height(cm)", user['height'] ?? "--"),
                    InfoRow(Icons.location_on, "Address", user['address'] ?? "--"),
                    Builder(
                      builder: (context) {
                        String lat = "0.0";
                        String lng = "0.0";
                        if (user['ordinate'] != null) {
                          lat = (user['ordinate']['latitude'] ?? 0.0).toString();
                          lng = (user['ordinate']['longitude'] ?? 0.0).toString();
                        }
                        return Column(
                          children: [
                            InfoRow(Icons.map, "Latitude", lat),
                            InfoRow(Icons.map, "Longitude", lng),
                          ],
                        );
                      }
                    ),
                    if (user['gender'] != null) InfoRow(Icons.person, "Gender", user['gender']),
                    if (user['medicalHistory'] != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             const Icon(Icons.history, size: 20, color: Colors.blue),
                             const SizedBox(width: 12),
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   const Text("Medical History", style: TextStyle(color: Colors.black54)),
                                   Text("${user['medicalHistory']}", style: const TextStyle(fontWeight: FontWeight.w600)),
                                 ],
                               ),
                             ),
                          ],
                        )
                    ]
                  ],
                ),
              ),

            

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
  final IconData icon;
  final String label, value;
  const InfoRow(this.icon, this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.black54))),
          Text(value, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
