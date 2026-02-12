import 'package:vita_flow/screens/role_select.dart';
import 'package:vita_flow/screens/login_screen.dart';
import 'package:flutter/material.dart';


class RiderProfileScreen extends StatelessWidget {
  const RiderProfileScreen({super.key});

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

              const Text(
                "Profile",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 16),

              _profileHeader(),

              const SizedBox(height: 20),

              _infoSection(),

              const SizedBox(height: 20),

              _badgesSection(),

              const SizedBox(height: 20),

              _logoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // HEADER SECTION
  Widget _profileHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue.shade100,
            child: const Text("RS",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Rahul Singh",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              Text("Rider ID: VF-R-2341",
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  // INFO SECTION
  Widget _infoSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _infoRow("Phone", "+91 9876543210"),
          _infoRow("Email", "rahul123@gmail.com"),
          _infoRow("Vehicle", "RJ-14-AB-1234"),
          _infoRow("License", "DL-1234567890"),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // BADGES
  Widget _badgesSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration:
          BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Badges & Achievements",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _badge("Top Performer", Icons.emoji_events, Colors.orange),
              _badge("Speed Demon", Icons.flash_on, Colors.blue),
              _badge("100 Deliveries", Icons.whatshot, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: color.withOpacity(.15),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // LOGOUT BUTTON — FIXED & CORRECT
  Widget _logoutButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 180,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 14),
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
    );
  }
}
