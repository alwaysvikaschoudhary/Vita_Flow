import 'package:flutter/material.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      bottomNavigationBar: _shareButton(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              const SizedBox(height: 10),
              _livesSavedCard(),
              const SizedBox(height: 10),
              const Text(
                "Achievement Badges",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              _badgesRow(),
              const SizedBox(height: 10),
              const Text(
                "Rewards & Vouchers",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              _voucherCard("Apollo Pharmacy", "₹150 OFF"),
              const SizedBox(height: 10),
              _voucherCard("HealthCare Lab", "Free Test"),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------
  // HEADER
  // -----------------------------------------
  Widget _header(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Rewards & Achievements",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        Spacer(),
        Stack(
          children: [
            const Icon(Icons.notifications_outlined, size: 30),
            Positioned(
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  "2",
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // -----------------------------------------
  // LIVES SAVED CARD
  // -----------------------------------------
  Widget _livesSavedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Hi Jitesh 👋",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),

          const SizedBox(height: 20),

          // Circular counter
          SizedBox(
            height: 150,
            width: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: CircularProgressIndicator(
                    value: 12 / 20, // example percent
                    strokeWidth: 10,
                    valueColor: AlwaysStoppedAnimation(Color(0xFFE0463A)),
                    backgroundColor: Colors.red.shade100,
                  ),
                ),

                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "12",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("Lives Saved", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Points
          const Text(
            "🏆 2,350 VitaPoints",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 6),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Next reward at 3,000 points 🎉",
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),

          const SizedBox(height: 20),

          // Progress bar
          Column(
            children: [
              LinearProgressIndicator(
                value: 2350 / 3000,
                color: Colors.red,
                backgroundColor: Colors.grey.shade300,
              ),
              const SizedBox(height: 5),
              const Text(
                "650 points to next reward",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -----------------------------------------
  // BADGES ROW
  // -----------------------------------------
  Widget _badgesRow() {
    return Row(
      children: [
        _badgeCard(
          icon: "🩸",
          title: "Life Saver",
          subtitle: "Donated 1st time",
          unlocked: "Unlocked Jan 2026",
        ),
        const SizedBox(width: 12),
        _badgeCard(
          icon: "💪",
          title: "Hero Donor",
          subtitle: "5 donations completed",
          unlocked: "Unlocked Apr 2026",
        ),
        const SizedBox(width: 12),
        _badgeCard(
          icon: "🌍",
          title: "Community",
          subtitle: "Shared 10 referrals",
          unlocked: "Unlocked May 2026",
        ),
      ],
    );
  }

  Widget _badgeCard({
    required String icon,
    required String title,
    required String subtitle,
    required String unlocked,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 3),
            Text(
              unlocked,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------
  // VOUCHER CARD
  // -----------------------------------------
  Widget _voucherCard(String title, String offer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.card_giftcard, color: Colors.red.shade400, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(offer, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  // -----------------------------------------
  // SHARE BUTTON
  // -----------------------------------------
  Widget _shareButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE0463A),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () {},
        child: const Text(
          "🔗  Share Your Impact",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
