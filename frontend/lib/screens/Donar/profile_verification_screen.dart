import 'package:vita_flow/screens/Donar/blood_verification_screen.dart';
import 'package:vita_flow/screens/Donar/health_declaration_screen.dart';
import 'package:flutter/material.dart';
import 'personal_info_screen.dart';

class ProfileVerificationScreen extends StatelessWidget {
  const ProfileVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  "Profile Verification",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
              ],
            ),

            const SizedBox(height: 10),

            // Verification Progress
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
                    "Verification Status",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      Text(
                        "70% Complete",
                        style: TextStyle(color: Colors.orange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: 0.7,
                    color: Colors.orange,
                    backgroundColor: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "30% remaining to unlock donation requests",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Verification Steps
            _stepTile(
              context,
              title: "Personal Information",
              subtitle: "Name, age, gender, weight",
              icon: Icons.person,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const PersonalInfoScreen()),
                );
              },
            ),

            _stepTile(
              context,
              title: "Blood Type Verification",
              subtitle: "Upload medical document or ID",
              icon: Icons.bloodtype,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const BloodTypeVerificationScreen()),
                );
              },
              warning: true,
            ),

            _stepTile(
              context,
              title: "Health Declaration",
              subtitle: "Current health status",
              icon: Icons.health_and_safety,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const HealthDeclarationScreen()),
                );
              },
              warning: true,
            ),

            // Why verification?
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.notification_important_outlined,
                        color: Colors.blue,
                      ),
                      const Text(
                        "Why Verification?",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Verification ensures safety for both donors and recipients. "
                    "Complete all steps to unlock blood donation requests in your area.",
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE0463A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // return to verification screen
                },
                child: const Text(
                  "Save & Back",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    bool warning = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: Icon(icon, color: Colors.black87),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: warning
            ? const Icon(Icons.error, color: Colors.red)
            : const Icon(Icons.check_circle, color: Colors.green),
        onTap: onTap,
      ),
    );
  }
}
