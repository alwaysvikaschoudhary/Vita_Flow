import 'package:flutter/material.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _loyaltyCard(),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Best Buy",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.arrow_forward_ios, size: 18),
              ],
            ),

            const SizedBox(height: 20),

            _bestBuyGrid(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------
  // LOYALTY CARD (Matching the Image)
  // -----------------------------------------
  Widget _loyaltyCard() {
    return Container(
      width: double.infinity,
      height: 220,
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
          // Background abstract pattern (simplified with Opacity)
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.1,
              child: const Icon(Icons.flash_on, size: 250, color: Colors.white),
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Loyalty Card",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.stars, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text("Gold", style: TextStyle(color: Color(0xFFB33229), fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              const Text(
                "Current Points",
                style: TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Text(
                "20,525",
                style: TextStyle(color: Colors.orangeAccent, fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const Text(
                "4 points = 1 rupee",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Spacer(),
              const Text(
                "Expiry  06/22",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          
          // Trophy Image
          Positioned(
            right: 0,
            bottom: 20,
            child: Column(
              children: [
                 Container(
                   padding: const EdgeInsets.all(10),
                   decoration: BoxDecoration(
                     color: Colors.orangeAccent.withOpacity(0.2),
                     shape: BoxShape.circle,
                   ),
                   child: const Icon(Icons.emoji_events, color: Colors.orangeAccent, size: 70),
                 ),
                 const SizedBox(height: 8),
                 Container(
                   height: 12,
                   width: 80,
                   decoration: BoxDecoration(
                     color: Colors.grey.shade400,
                     borderRadius: BorderRadius.circular(4),
                   ),
                 )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------
  // BEST BUY GRID
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
        _productCard(
            "Boat Airdopes 431 ...", "assets/images/rewards/boat_airdopes.png", 690),
        _productCard(
            "HAVELLS fabio 1250", "assets/images/rewards/havells_iron.png", 890),
        _productCard(
            "Boat Airdopes 431 ...", "assets/images/rewards/boat_airdopes.png", 690),
        _productCard(
            "HAVELLS fabio 1250", "assets/images/rewards/havells_iron.png", 890),
        _productCard(
            "HAVELLS fabio 1250", "assets/images/rewards/havells_iron.png", 890),
        _productCard(
            "Boat Airdopes 431 ...", "assets/images/rewards/boat_airdopes.png", 690),
        _productCard(
            "HAVELLS fabio 1250", "assets/images/rewards/havells_iron.png", 890),
        _productCard(
            "Boat Airdopes 431 ...", "assets/images/rewards/boat_airdopes.png", 690),
        _productCard(
            "HAVELLS fabio 1250", "assets/images/rewards/havells_iron.png", 890),
        _productCard(
            "Boat Airdopes 431 ...", "assets/images/rewards/boat_airdopes.png", 690),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                  Center(child: Icon(Icons.image, size: 50, color: Colors.grey.shade300)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
              const Text(
                "Buy ",
                style: TextStyle(color: Color(0xFFE0463A), fontWeight: FontWeight.w600),
              ),
              const Icon(Icons.circle, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                "$points",
                style: const TextStyle(color: Color(0xFFE0463A), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
