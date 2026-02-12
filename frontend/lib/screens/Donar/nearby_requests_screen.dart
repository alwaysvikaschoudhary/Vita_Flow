import 'package:flutter/material.dart';
import 'donation_progress_screen.dart';

class NearbyRequestsScreen extends StatelessWidget {
  const NearbyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 229, 230, 234),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Nearby Requests",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            // FILTER
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: const [
                  Icon(Icons.filter_list, size: 22),
                  SizedBox(width: 8),
                  Text("Filter by blood type & distance"),
                ],
              ),
            ),

            // BODY SCROLL
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        "assets/images/map_demo.png",
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // CARD 1
                    _requestCard(
                      context: context,
                      title: "Gitanjali Hostel (Bhankrota)",
                      distance: "1.2 km",
                      urgency: "High",
                      urgencyColor: Colors.red.shade100,
                      bloodType: "O+",
                      units: "2 units",
                      time: "1 hour",
                    ),

                    const SizedBox(height: 10),

                    // CARD 2
                    _requestCard(
                      context: context,
                      title: "Balaji Soni Hospital",
                      distance: "2.5 km",
                      urgency: "Normal",
                      urgencyColor: Colors.grey.shade300,
                      bloodType: "AB-",
                      units: "1 unit",
                      time: "3 hours",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // REQUEST CARD
  // ------------------------------------------------------------------
  Widget _requestCard({
    required BuildContext context,
    required String title,
    required String distance,
    required String urgency,
    required Color urgencyColor,
    required String bloodType,
    required String units,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Tag
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: urgencyColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  urgency,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Row(
            children: [
              const Icon(Icons.location_on, size: 20),
              const SizedBox(width: 6),
              Text(distance),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              _bloodChip(bloodType),
              const SizedBox(width: 12),
              const Icon(Icons.water_drop, size: 20, color: Colors.red),
              const SizedBox(width: 4),
              Text(units),
              const SizedBox(width: 20),
              const Icon(Icons.access_time, size: 20),
              const SizedBox(width: 4),
              Text(time),
            ],
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0463A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                final nestedNavigator = Navigator.of(context);
                showEligibilityPopup(context, nestedNavigator);
              },
              child: const Text(
                "Accept Request",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // BLOOD CHIP
  // ------------------------------------------------------------------
  Widget _bloodChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.red,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // POPUP (FIXED)
  // ------------------------------------------------------------------
  void showEligibilityPopup(
    BuildContext context,
    NavigatorState nestedNavigator,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (popupCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green, size: 28),
                    SizedBox(width: 8),
                    Text(
                      "You're Eligible!",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    Spacer(),
                  ],
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFE8F8E8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "All eligibility requirements passed. You can proceed with this donation request.",
                    style: TextStyle(fontSize: 15),
                  ),
                ),

                const SizedBox(height: 10),

                const _eligibilityItem("Age & weight requirements met", true),
                const _eligibilityItem("Cooling period complete", true),
                const _eligibilityItem("Health declaration verified", true),
                const _eligibilityItem("Blood type proof verified", true),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE0463A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(popupCtx); // close popup

                      nestedNavigator.push(
                        MaterialPageRoute(
                          builder: (_) => const DonationProgressScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Confirm",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () => Navigator.pop(popupCtx),
                  child: const Text("Cancel"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _eligibilityItem extends StatelessWidget {
  final String text;
  final bool status;

  const _eligibilityItem(this.text, this.status);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.circle_outlined,
            color: status ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }
}
