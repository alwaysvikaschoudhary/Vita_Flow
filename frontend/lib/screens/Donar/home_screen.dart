import 'package:vita_flow/screens/Donar/reward_screen.dart';
import 'package:flutter/material.dart';
import 'nearby_requests_screen.dart';
import 'package:vita_flow/services/api_service.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const HomeScreen({super.key, required this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _nearbyRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNearbyRequests();
  }

  Future<void> _fetchNearbyRequests() async {
    try {
      final requests = await ApiService.getNearbyRequests(widget.currentUser['userId']);
      if (mounted) {
        setState(() {
          _nearbyRequests = requests;
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

  bool _isProfileVerified() {
    final user = widget.currentUser;
    return (user['name'] != null && user['name'].toString().isNotEmpty) &&
           (user['phoneNumber'] != null && user['phoneNumber'].toString().isNotEmpty) &&
           (user['bloodGroup'] != null && user['bloodGroup'].toString().isNotEmpty) &&
           (user['address'] != null && user['address'].toString().isNotEmpty);
  }

  Map<String, dynamic> _getEligibilityStatus() {
    final lastDonation = widget.currentUser['lastDonationDate'];
    if (lastDonation == null || lastDonation.toString().isEmpty) {
      return {"eligible": true, "msg": "Available Now"};
    }

    try {
      final date = DateTime.parse(lastDonation);
      final difference = DateTime.now().difference(date).inDays;
      if (difference > 90) { // 3 months approx
        return {"eligible": true, "msg": "Available Now"};
      } else {
        return {"eligible": false, "msg": "Eligible in ${90 - difference} days"};
      }
    } catch (e) {
      return {"eligible": true, "msg": "Available Now"};
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVerified = _isProfileVerified();
    final eligibility = _getEligibilityStatus();
    final isEligible = eligibility['eligible'];
    final donations = widget.currentUser['numberOfDonation'] ?? "0";
    final livesSaved = (int.tryParse(donations.toString()) ?? 0) * 3;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 229, 230, 234),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchNearbyRequests,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------
                // TOP HEADER CARD
                // ------------------------
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi, ${widget.currentUser['name']} 👋",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.black, // Explicit color for better visibility
                            ),
                          ),

                          Text(
                            "Blood Group: ${widget.currentUser['bloodGroup'] ?? 'N/A'}",
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0xFFFFECEC),
                        child: Icon(
                          Icons.notifications_none,
                          color: Color(0xFFE0463A),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // ------------------------
                // VERIFIED DONOR CARD
                // ------------------------
                if (isVerified)
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 209, 239, 209),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color.fromARGB(255, 29, 187, 50),
                        child: Icon(
                          Icons.shield_outlined,
                          color: const Color.fromARGB(255, 240, 243, 240),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Verified Donor",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Your profile is verified and active",
                              style: TextStyle(fontSize: 15, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                )
                else
                 Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.orange,
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Complete Profile",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Please complete your profile to verify.",
                              style: TextStyle(fontSize: 15, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // ------------------------
                // ELIGIBLE TO DONATE
                // ------------------------
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: isEligible ? Color(0xFFE8F8E8) : Colors.red.shade50,
                        child: Icon(Icons.calendar_today, color: isEligible ? Colors.green : Colors.red),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEligible ? "Eligible to Donate" : "Not Eligible Yet",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            Text(
                              eligibility['msg'],
                              style: TextStyle(
                                fontSize: 15,
                                color: isEligible ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              isEligible ? "You can accept donation requests" : "Please wait before donating again",
                              style: TextStyle(fontSize: 15, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // ------------------------
                // TOTAL DONATIONS + LIVES SAVED
                // ------------------------
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 10, right: 2),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.favorite_border, color: Colors.red),
                            SizedBox(height: 10),
                            Text(
                              "Total Donations",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 4),
                            Text(donations.toString()),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 2, right: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.emoji_events, color: Colors.green),
                            SizedBox(height: 10),
                            Text(
                              "Lives Saved",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 4),
                            Text(livesSaved.toString()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // ------------------------
                // REWARDS CARD
                // ------------------------
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RewardsScreen()),
                    );
                  },
                  child: Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF5D6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.emoji_events, color: Colors.orange),
                          SizedBox(width: 10),
                          Text(
                            "Rewards & Points",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "2,350 VitaPoints earned",
                        style: TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        children: [
                          Chip(
                            label: Text("4 Badges Unlocked"),
                            backgroundColor: Colors.orange.shade100,
                          ),
                          Chip(
                            label: Text("3 Rewards Available"),
                            backgroundColor: Colors.orange.shade100,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ),
                

                const SizedBox(height: 15),

              // ------------------------
              // URGENT / BLOOD REQUESTS
              // ------------------------
              Builder(
                builder: (context) {
                  if (_isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (_nearbyRequests.isEmpty) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(child: Text("No blood requests nearby")),
                    );
                  }

                  // Check if any request is Urgent
                  print("DEBUG: Nearby Requests Data: $_nearbyRequests");
                  final hasUrgent = _nearbyRequests.any((req) {
                    final u = (req['urgency'] ?? '').toString().trim().toLowerCase();
                    return u == 'high' || u == 'critical';
                  });

                  // Define styles based on urgency
                  final cardColor = hasUrgent ? const Color(0xFFE0463A) : const Color(0xFFFFF5D6); // Red or Yellow
                  final textColor = hasUrgent ? Colors.white : Colors.black;
                  final titleText = hasUrgent ? "Urgent Requests" : "Blood Requests";
                  final subTitleText = hasUrgent ? "Blood needed within 5 km" : "Requests nearby";
                  final iconColor = hasUrgent ? Colors.white : Colors.orange;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NearbyRequestsScreen(
                            userId: widget.currentUser['userId'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 10, right: 10),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: iconColor),
                              SizedBox(width: 12),
                              Text(
                                titleText,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              SizedBox(width: 8),
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: hasUrgent ? Colors.white : Colors.orange,
                                child: Text(
                                  "${_nearbyRequests.length}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: hasUrgent ? Colors.black : Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            subTitleText,
                            style: TextStyle(color: textColor),
                          ),
                          SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _nearbyRequests.take(5).map((req) {
                                return _bloodChip(req['bloodGroup'] ?? "?", hasUrgent);
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  static Widget _bloodChip(String text, bool isUrgent) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isUrgent ? Colors.white24 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text, 
        style: TextStyle(
          color: isUrgent ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }
}
