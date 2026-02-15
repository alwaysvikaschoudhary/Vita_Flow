import 'package:flutter/material.dart';
import 'package:vita_flow/services/api_service.dart';
import 'donation_progress_screen.dart';

class NearbyRequestsScreen extends StatefulWidget {
  final String userId;
  const NearbyRequestsScreen({super.key, required this.userId});

  @override
  State<NearbyRequestsScreen> createState() => _NearbyRequestsScreenState();
}

class _NearbyRequestsScreenState extends State<NearbyRequestsScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      final data = await ApiService.getNearbyRequests(widget.userId);
      if (mounted) {
        setState(() {
          _requests = data;
          // Sort: High/Critical first
          _requests.sort((a, b) {
            int priority(String? u) {
              final lower = u?.toLowerCase().trim() ?? "";
              if (lower == 'high' || lower == 'critical') return 0;
              return 1;
            }
            return priority(a['urgency']).compareTo(priority(b['urgency']));
          });
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching nearby requests: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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

            // BODY SCROLL
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _fetchRequests,
                      child: _requests.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 50),
                                Center(child: Text("No nearby requests found.")),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(15),
                              itemCount: _requests.length,
                              itemBuilder: (context, index) {
                                final req = _requests[index];
                                return Column(
                                  children: [
                                    _requestCard(
                                      context: context,
                                      title: req['doctorName'] != null
                                          ? "${req['hospitalName']} (${req['doctorName']})"
                                          : (req['hospitalName'] ?? "Unknown Hospital"),
                                      distance: "Nearby",
                                      urgency: req['urgency'] ?? "Normal",
                                      urgencyColor: _getUrgencyColor(req['urgency']),
                                      bloodType: req['bloodGroup'] ?? "?",
                                      units: "${req['units']} units",
                                      time: _timeAgo(req['date'], req['time']),
                                      requestId: req['requestId'] ?? "", 
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(String? dateStr, String? timeStr) {
    if (dateStr == null || timeStr == null) return "Just now";
    try {
      final now = DateTime.now();
      final dateParts = dateStr.split('-');
      final timeParts = timeStr.split(':');

      if (dateParts.length == 3 && timeParts.length >= 2) {
        final year = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final day = int.parse(dateParts[2]);
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final dt = DateTime(year, month, day, hour, minute);

        final diff = now.difference(dt);

        if (diff.inDays >= 365) {
          return "${(diff.inDays / 365).floor()} years ago";
        } else if (diff.inDays >= 30) {
          return "${(diff.inDays / 30).floor()} months ago";
        } else if (diff.inDays > 0) {
          return "${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'} ago";
        } else if (diff.inHours > 0) {
          final mins = diff.inMinutes % 60;
          if (mins > 0) {
             return "${diff.inHours} h $mins min ago";
          }
          return "${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago";
        } else if (diff.inMinutes > 0) {
          return "${diff.inMinutes} min ago";
        } else {
          return "Just now";
        }
      }
      return "Recently";
    } catch (e) {
      return "Recently";
    }
  }

  Color _getUrgencyColor(String? urgency) {
    final lower = urgency?.toLowerCase().trim() ?? "";
    if (lower == 'high' || lower == 'critical') {
      return Colors.red.shade100;
    }
    return Colors.grey.shade300;
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
    required String requestId,
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
                showEligibilityPopup(context, nestedNavigator, requestId);
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
    String requestId,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (popupCtx) {
        bool isLoading = false;
        
        return StatefulBuilder(
          builder: (context, setState) {
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
                        color: const Color(0xFFE8F8E8),
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

                    if (isLoading)
                      const CircularProgressIndicator()
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE0463A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            setState(() => isLoading = true);
                            try {
                              final acceptedReq = await ApiService.acceptRequest(requestId, widget.userId);
                              if (context.mounted) {
                                Navigator.pop(popupCtx); // close popup
                                // Close Nearby Screen as well? No, just navigate forward.
                                nestedNavigator.push(
                                  MaterialPageRoute(
                                    builder: (_) => DonationProgressScreen(requestData: acceptedReq),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                setState(() => isLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: $e")),
                                );
                              }
                            }
                          },
                          child: const Text(
                            "Confirm",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      
                    if (!isLoading)
                      TextButton(
                        onPressed: () => Navigator.pop(popupCtx),
                        child: const Text("Cancel"),
                      ),
                  ],
                ),
              ),
            );
          }
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
