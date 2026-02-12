import 'package:flutter/material.dart';

class CreateBloodRequestScreen extends StatefulWidget {
  const CreateBloodRequestScreen({super.key});

  @override
  State<CreateBloodRequestScreen> createState() =>
      _CreateBloodRequestScreenState();
}

class _CreateBloodRequestScreenState extends State<CreateBloodRequestScreen> {
  String selectedBlood = "O+";
  String urgency = "Medium";

  final List<String> bloodTypes = [
    "A+",
    "A-",
    "B+",
    "B-",
    "O+",
    "O-",
    "AB+",
    "AB-"
  ];

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
              // HEADER
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Create Blood Request",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                      Text("Fill in the details below",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 20),

              // BLOOD TYPE CARD
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Blood Type Required",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: bloodTypes.map((type) {
                        final isSelected = selectedBlood == type;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedBlood = type;
                            });
                          },
                          child: Container(
                            width: 70,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: isSelected
                                      ? Colors.red
                                      : Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                              color:
                                  isSelected ? Colors.red.shade50 : Colors.white,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected ? Colors.red : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // UNITS REQUIRED
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Units Required",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "2",
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // URGENCY LEVEL
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Urgency Level",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    // Low
                    _urgencyTile("Low"),
                    const SizedBox(height: 10),

                    // Medium
                    _urgencyTile("Medium", highlight: true),
                    const SizedBox(height: 10),

                    // Critical
                    _urgencyTile("Critical", subtitle: "Within 2 hours"),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // TIME NEEDED
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Time Needed By",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Select date & time",
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // BUTTON
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
                  onPressed: () {},
                  child: const Text(
                    "Create Request",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // REUSABLE CARD WRAPPER
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  // URGENCY SELECTOR TILE
  Widget _urgencyTile(String level, {bool highlight = false, String? subtitle}) {
    final isSelected = urgency == level;

    return GestureDetector(
      onTap: () {
        setState(() {
          urgency = level;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
              color: isSelected ? Colors.red : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(14),
          color: isSelected ? Colors.red.shade50 : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.circle_outlined,
              color: isSelected ? Colors.red : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              level,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.red : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(width: 6),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
