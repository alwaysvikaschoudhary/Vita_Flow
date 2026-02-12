import 'package:flutter/material.dart';

class VerificationCompleteScreen extends StatelessWidget {
  final VoidCallback? onStartDonating; 

  const VerificationCompleteScreen({super.key, this.onStartDonating});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FFF6),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 40),

            // BIG GREEN CHECK ICON
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green,
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 70,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Verification Complete!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "You're now a verified donor. Start accepting blood donation requests and save lives!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),

            const SizedBox(height: 25),

            // VERIFIED DONOR BADGE CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.verified, color: Color.fromARGB(255, 116, 198, 119), size: 40),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Verified Donor Badge",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "Active on your profile",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            "🩸Your verified status will be visible to hospitals and riders, ensuring faster matching and safer donations.",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // START DONATING BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE0463A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  if (onStartDonating != null) {
                    onStartDonating!();  // tells navbar to go home
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Start Donating",
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
