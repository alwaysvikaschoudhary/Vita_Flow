import 'package:flutter/material.dart';
import 'package:vita_flow/services/api_service.dart';

class RewardsScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;
  const RewardsScreen({super.key, this.currentUser});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  int _activeTab = 0; // 0: Buy, 1: Redeem, 2: Referral
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final userId = widget.currentUser?['userId'] ?? widget.currentUser?['id'];
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final profile = await ApiService.getRiderById(userId);
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading rider profile: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Rewards & Achievements",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _loyaltyCard(),
              const SizedBox(height: 25),
              
              // Tab Switcher
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ],
                ),
                child: Row(
                  children: [
                    _tabItem(0, "Buy"),
                    _tabItem(1, "Redeem"),
                    _tabItem(2, "Referral"),
                  ],
                ),
              ),
              
              const SizedBox(height: 25),
              
              // Content based on tab
              _buildTabContent(),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabItem(int index, String title) {
    bool isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE0463A) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 0:
        return _bestBuyGrid();
      case 1:
        return _buildRedeemView();
      case 2:
        return _buildReferralView();
      default:
        return _bestBuyGrid();
    }
  }

  // -----------------------------------------
  // LOYALTY CARD
  // -----------------------------------------
  Widget _loyaltyCard() {
    return Container(
      width: double.infinity,
      height: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFE0463A), Color(0xFFB33229)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE0463A).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 40,
            bottom: -20,
            child: Opacity(
              opacity: 0.1,
              child: const Icon(Icons.flash_on, size: 150, color: Colors.white),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Current Points",
                style: TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                _userProfile?['rewardsCoin']?.toString() ?? "0",
                style: const TextStyle(color: Colors.orangeAccent, fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Positioned(
            right: 0,
            child: Column(
              children: [
                 Container(
                   padding: const EdgeInsets.all(10),
                   decoration: BoxDecoration(
                     color: Colors.orangeAccent.withOpacity(0.2),
                     shape: BoxShape.circle,
                   ),
                   child: const Icon(Icons.emoji_events, color: Colors.orangeAccent, size: 50),
                 ),
                 const SizedBox(height: 8),
                 Container(
                   height: 12, width: 80,
                   decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(4)),
                 )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------
  // REDEEM VIEW (Matching the Image)
  // -----------------------------------------
  Widget _buildRedeemView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _redeemSection("Entertainment", [
          _redeemItem(Icons.shopping_bag, "Amazon Gift Card worth 250 INR", 1800),
          _redeemItem(Icons.play_circle, "Buy Prime Subscription for 800 points", 800),
        ]),
        _redeemSection("Food", [
          _redeemItem(Icons.fastfood, "Buy Coupon Code worth \$25", 200),
          _redeemItem(Icons.delivery_dining, "Get 50 INR back to wallet", 300),
        ]),
        _redeemSection("Coupons", [
          _redeemItem(Icons.checkroom, "Redeem 10000 points to get Adidas Sneakers", 10000),
        ]),
      ],
    );
  }

  Widget _redeemSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF3B4A9F)),
            ],
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _redeemItem(IconData icon, String title, int points) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 30, color: Colors.black87),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          Column(
            children: [
              const Icon(Icons.circle, color: Colors.amber, size: 18),
              const SizedBox(height: 4),
              Text("$points pts", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // -----------------------------------------
  // REFERRAL VIEW
  // -----------------------------------------
  Widget _buildReferralView() {
    String refCode = _userProfile?['referralId'] ?? "Loading...";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Share your Referral Code", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.red.shade100, width: 2),
          ),
          child: Column(
            children: [
              Text(refCode, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4, color: Color(0xFFE0463A))),
              const SizedBox(height: 10),
              const Text("Tap to copy code", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Text("Referral Milestone Rewards", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        _milestoneItem("1 Referral", "+50 Points", true),
        _milestoneItem("3 Referrals", "+200 Points", false),
        _milestoneItem("5 Referrals", "+500 Points", false),
      ],
    );
  }

  Widget _milestoneItem(String count, String reward, bool isAchieved) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAchieved ? Colors.green.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isAchieved ? Colors.green.shade200 : Colors.transparent),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(reward, style: TextStyle(color: isAchieved ? Colors.green : Colors.orangeAccent, fontWeight: FontWeight.w600)),
            ],
          ),
          isAchieved ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.lock_outline, color: Colors.grey),
        ],
      ),
    );
  }

  // -----------------------------------------
  // BEST BUY GRID (EXISTING)
  // -----------------------------------------
  Widget _bestBuyGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 0.72,
      crossAxisSpacing: 16,
      mainAxisSpacing: 20,
      children: [
        _productCard("Boat Airdopes 431 ...", "assets/images/rewards/boat_airdopes.png", 690),
        _productCard("HAVELLS fabio 1250", "assets/images/rewards/havells_iron.png", 890),
        _productCard("Boat Airdopes 431 ...", "assets/images/rewards/boat_airdopes.png", 690),
        _productCard("HAVELLS fabio 1250", "assets/images/rewards/havells_iron.png", 890),
      ],
    );
  }

  Widget _productCard(String name, String imagePath, int points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.image, size: 50, color: Colors.grey.shade300)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0463A).withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Buy ", style: TextStyle(color: const Color(0xFFE0463A), fontWeight: FontWeight.w600)),
              const Icon(Icons.circle, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text("$points", style: const TextStyle(color: Color(0xFFE0463A), fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}
