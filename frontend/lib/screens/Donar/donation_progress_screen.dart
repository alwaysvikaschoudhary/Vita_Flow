import 'package:flutter/material.dart';
import 'package:vita_flow/services/api_service.dart';
import 'donation_certificate_screen.dart';

class DonationProgressScreen extends StatefulWidget {
  final Map<String, dynamic> requestData;

  const DonationProgressScreen({super.key, required this.requestData});

  @override
  State<DonationProgressScreen> createState() => _DonationProgressScreenState();
}

class _DonationProgressScreenState extends State<DonationProgressScreen> {
  late Map<String, dynamic> _currentRequest;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _currentRequest = widget.requestData;
  }

  Future<void> _refreshRequest() async {
    setState(() => _isRefreshing = true);
    try {
      final updatedData = await ApiService.getRequestById(_currentRequest['requestId']);
      if (mounted) {
        setState(() {
          _currentRequest = updatedData;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRefreshing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error refreshing status: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Parse Status to determine active step
    final status = _currentRequest['status'] ?? "ACCEPTED";
    final otp = _currentRequest['otp'] ?? "----";
    final riderId = _currentRequest['riderId'];
    
    int currentStep = 1;
    if (status == "ACCEPTED" || status == "PENDING") currentStep = 1;
    else if (status == "RIDER_ASSIGNED") currentStep = 2;
    // Note: status might be differentiating between Assigned, Picked Up, etc. 
    // Assuming backend updates status strings accordingly.
    else if (status == "COLLECTED") currentStep = 3;
    else if (status == "DELIVERED" || status == "COMPLETED") currentStep = 4;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 229, 230, 234),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshRequest,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Donation in Progress",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),

                const SizedBox(height: 4),
                Text(
                  _currentRequest['hospitalName'] ?? "Hospital",
                  style: const TextStyle(color: Colors.black),
                ),

                const SizedBox(height: 16),

                // Progress bar logic
                LinearProgressIndicator(
                  value: currentStep / 4,
                  color: Colors.black,
                  backgroundColor: const Color.fromARGB(255, 192, 192, 192),
                ),

                const SizedBox(height: 20),

                // Steps row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _step("1", "Request\nAccepted", currentStep >= 1),
                    _step("2", "Rider\nAssigned", currentStep >= 2),
                    _step("3", "Blood\nCollection", currentStep >= 3),
                    _step("4", "Delivered\nSuccessful", currentStep >= 4),
                  ],
                ),

                const SizedBox(height: 20),

                // OTP DISPLAY
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade100, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Your OTP for Verification",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        otp,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                          color: Color(0xFFE0463A),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Share this with the Rider upon arrival",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // RIDER CARD (Conditional)
                if (riderId != null) ...[
                  // Rider card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.blue.shade50,
                          child: const Text("RS"), // Initials placeholder
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text(
                                "Rahul Singh", // Placeholder
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Rider ID: $riderId",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Icon(Icons.phone, color: Colors.green),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 11),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.location_on),
                        SizedBox(width: 8),
                        Text("Arriving in"),
                        Spacer(),
                        Text(
                          "12 mins",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                   // Waiting for Rider State
                   Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                         SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                         SizedBox(width: 20),
                         Expanded(child: Text("Waiting for Rider Assignment... (Pull to refresh)")),
                      ],
                    ),
                   ),
                ],
                
                const SizedBox(height: 20),
                
                 if (currentStep >= 3)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: false).push(
                        MaterialPageRoute(
                          builder: (c) => const DonationCertificateScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0463A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "Finish Donation (Demo)",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _step extends StatelessWidget {
  final String num;
  final String text;
  final bool active;

  const _step(this.num, this.text, this.active);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: active
              ? Colors.red
              : const Color.fromARGB(255, 199, 199, 199),
          child: Text(num, style: const TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 6),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: active ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }
}
