import 'package:flutter/material.dart';

class HealthDeclarationScreen extends StatefulWidget {
  const HealthDeclarationScreen({super.key});

  @override
  State<HealthDeclarationScreen> createState() =>
      _HealthDeclarationScreenState();
}

class _HealthDeclarationScreenState extends State<HealthDeclarationScreen> {
  String lastDonationDate = "10/06/2025";

  // Checklist states
  final List<bool> checklist = [false, false, false, false, false];

  final List<String> checklistText = [
    "I have not been ill in the past 14 days",
    "I am not taking any major medications",
    "Do you understand the donation process and give permission to donate?",
    "I have not consumed alcohol in the past 24 hours",
    "I am well-rested and have eaten today",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // HEADER
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  "Health Declaration",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.only(left: 52),
              child: Text("Step 3 of 3", style: TextStyle(color: Colors.grey)),
            ),

            const SizedBox(height: 10),

            // --------------------
            // LAST DONATION DATE
            // --------------------
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
                    "Last Donation Date",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  
                  const SizedBox(height: 5),

                  // DATE BOX
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      lastDonationDate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: const [
                      Icon(Icons.info_outline, size: 18, color: Colors.grey),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Must be at least 90 days ago for males, 120 days for females",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // --------------------
            // HEALTH CHECKLIST
            // --------------------

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
                    "Health Checklist",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),

                  // CHECKBOXES
                  for (int i = 0; i < checklist.length; i++)
                    GestureDetector(
                      onTap: () {
                        setState(() => checklist[i] = !checklist[i]);
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: checklist[i]
                                    ? Colors.green
                                    : Colors.grey.shade600,
                                width: 2,
                              ),
                              color: checklist[i]
                                  ? Colors.green
                                  : Colors.transparent,
                            ),
                            child: checklist[i]
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              child: Text(
                                checklistText[i],
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // --------------------
            // ELIGIBILITY BOX
            // --------------------

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "You're Eligible!",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Based on your responses, you're eligible to donate blood. Complete verification to start saving lives.",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // --------------------
            // COMPLETE VERIFICATION BUTTON
            // --------------------

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
                  Navigator.pop(context); // go back to verification screen
                },
                child: const Text(
                  "Complete Verification",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
