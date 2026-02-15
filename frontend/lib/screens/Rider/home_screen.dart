import 'package:vita_flow/services/api_service.dart';
import 'package:vita_flow/screens/Rider/pickup_screen.dart';
import 'package:flutter/material.dart';

class RiderHomeScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const RiderHomeScreen({super.key, required this.currentUser});

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen> {
  Map<String, dynamic>? _activeTask;
  List<dynamic> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final userId = widget.currentUser['userId'] ?? widget.currentUser['id'];
    if (userId == null) {
        setState(() => _isLoading = false);
        return;
    }

    try {
      // 1. Fetch Active Task
      final active = await ApiService.getActiveRiderRequest(userId);
      
      // 2. Fetch Nearby Tasks
      final nearby = await ApiService.getRiderNearbyRequests(userId);

      if (mounted) {
        setState(() {
          _activeTask = active;
          _tasks = nearby;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading rider data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),

                const SizedBox(height: 16),

                _buildStatsRow(),

                const SizedBox(height: 16),

                // Show Active Delivery Card OR Online Card
                if (_activeTask != null) 
                  _activeDeliveryCard()
                else 
                  _buildOnlineCard(),

                const SizedBox(height: 16),

                const Text(
                  "Nearby Requests", // Changed from Active Tasks to avoid confusion
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 12),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_tasks.isEmpty)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("No new pickup tasks nearby."),
                  ))
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _tasks.length,
                    separatorBuilder: (ctx, index) => const SizedBox(height: 12),
                    itemBuilder: (ctx, index) {
                      final task = _tasks[index];
                      return _taskCard(
                        context,
                        name: task['donorName'] ?? "Unknown Donor",
                        bloodType: task['bloodGroup'] ?? "?",
                        hospital: task['hospitalName'] ?? "Unknown Hospital",
                        distance: "Nearby", 
                        tag: "New Request", // Changed tag
                        tagColor: Colors.green,
                        request: task,
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
  
  // ---------------- HEADER ----------------
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hi, ${widget.currentUser['name']} 👋",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                Text("Vehicle: ${widget.currentUser['bikeNumber'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 15, color: Colors.grey)),
              ],
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.red.shade50,
            child: const Icon(Icons.notifications, color: Colors.red),
          ),
        ],
      ),
    );
  }

  // ---------------- STATS ROW ----------------
  Widget _buildStatsRow() {
    return Row(
      children: [
        _statBox(Icons.local_shipping, Colors.blue, "2", "Active"),
        _statBox(Icons.currency_rupee, Colors.red, "₹490", "Today"),
        _statBox(Icons.trending_up, Colors.purple, "52", "Total"),
      ],
    );
  }

  Widget _statBox(IconData icon, Color color, String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // ---------------- ONLINE CARD ----------------
  Widget _buildOnlineCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.shade400,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("You're Online",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              Switch(value: true, onChanged: (_) {}, activeColor: Colors.white),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: const [
              Expanded(child: MiniStat("Rating", "4.8")),
              SizedBox(width: 10),
              Expanded(child: MiniStat("Acceptance", "96%")),
            ],
          )
        ],
      ),
    );
  }
  
  // ---------------- ACTIVE DELIVERY CARD ----------------
  Widget _activeDeliveryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade100, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.delivery_dining, color: Colors.blue, size: 28),
              const SizedBox(width: 10),
              const Text(
                "Active Delivery",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _activeTask!['status'] ?? "IN PROGRESS", 
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text("Donor: ${_activeTask!['donorName']}", style: const TextStyle(fontWeight: FontWeight.w600)),
          Text("Hospital: ${_activeTask!['hospitalName']}", style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                 await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PickupVerificationScreen(
                      requestData: _activeTask!, 
                      riderId: widget.currentUser['userId'] ?? widget.currentUser['id'],
                    ),
                  ),
                );
                _loadData(); // Refresh on return
              },
              child: const Text("Continue Delivery", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- TASK CARD ----------------
  Widget _taskCard(
    BuildContext context, {
    required String name,
    required String bloodType,
    required String hospital,
    required String distance,
    required String tag,
    required Color tagColor,
    required Map<String, dynamic> request,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(tag, style: TextStyle(color: tagColor, fontSize: 12)),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text("Blood Type: $bloodType",
              style: const TextStyle(color: Colors.red)),

          Text(hospital, style: const TextStyle(color: Colors.black87)),
          Text(distance, style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0463A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              // ---------------- NAVIGATION FIX ----------------
              onPressed: () {
                // Pass request data to Pickup Screen if needed
                // For now just navigate
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PickupVerificationScreen(
                      requestData: request, 
                      riderId: widget.currentUser['userId'] ?? widget.currentUser['id'],
                    ),
                  ),
                );
              },
              child: const Text("Start Pickup", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- MINI STAT ----------------
class MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const MiniStat(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
