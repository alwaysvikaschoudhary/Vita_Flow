import 'package:vita_flow/services/api_service.dart';
import 'package:vita_flow/screens/Doctor/create_request_screen.dart';
import 'package:vita_flow/screens/Doctor/track_delivery_screen.dart';
import 'package:flutter/material.dart';

class DoctorHomeScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const DoctorHomeScreen({super.key, required this.currentUser});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  List<dynamic> _requests = [];
  Map<String, dynamic> _bloodStockMap = {};
  bool _isLoading = true;
  
  final List<String> _allBloodGroups = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];
  
  // Filters
  String _selectedStatus = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchRequests();
    // Removed listener for manual search trigger
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRequests() async {
    try {
      final requests = await ApiService.getRequestsByHospital(widget.currentUser['userId']);
      final stockData = await ApiService.getBloodStock(widget.currentUser['userId']);
      if (mounted) {
        setState(() {
          // Sort reverse to show newest first
          _requests = requests.reversed.toList();
          _bloodStockMap = stockData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching requests: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<dynamic> _getFilteredRequests() {
    final now = DateTime.now();
    return _requests.where((req) {
      // 1. Date Filter (Last 2 days)
      bool withinTwoDays = true; // default show if date missing/unparseable
      if (req['date'] != null) {
        try {
          final parts = req['date'].toString().split('-');
          if (parts.length == 3) {
            int year, month, day;
            if (parts[0].length == 4) {
              // YYYY-MM-DD
              year = int.parse(parts[0]);
              month = int.parse(parts[1]);
              day = int.parse(parts[2]);
            } else {
              // DD-MM-YYYY
              day = int.parse(parts[0]);
              month = int.parse(parts[1]);
              year = int.parse(parts[2]);
            }
            final date = DateTime(year, month, day);
            final diff = now.difference(date).inDays;
            withinTwoDays = (diff >= 0 && diff <= 2);
          }
        } catch (_) {
          withinTwoDays = true;
        }
      }
      String statusToCheck = req['status']?.toString().toUpperCase() ?? '';
      bool statusMatches = false;
      if (_selectedStatus == 'All') {
        statusMatches = true;
      } else if (_selectedStatus == 'Pickup') {
        statusMatches = statusToCheck == 'PICKED_UP';
      } else {
        statusMatches = statusToCheck == _selectedStatus.toUpperCase();
      }
      
      // 2. Search Filter (Blood Group)
      bool searchMatches = true;
      if (_searchQuery.isNotEmpty) {
        final bg = req['bloodGroup']?.toString().toLowerCase() ?? '';
        searchMatches = bg.contains(_searchQuery.toLowerCase());
      }

      return withinTwoDays && statusMatches && searchMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRequests = _getFilteredRequests();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchRequests,
          color: const Color(0xFFE0463A),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ----------------------------
                // HEADER
                // ----------------------------
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.currentUser['hospitalName'] ?? "Hospital",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "Dr. ${widget.currentUser['name']}",
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.red.shade50,
                        child: const Icon(Icons.notifications, color: Colors.red),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ----------------------------
                // STATS ROW (Keep showing total stats irrespective of filter, or filtered stats? Usually total)
                // ----------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _statCard(Icons.monitor_heart, Colors.blue, "${_requests.where((r) => r['status'] == 'ACCEPTED').length}", "Active"),),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard(Icons.access_time, Colors.orange, "${_requests.where((r) => r['status'] == 'PENDING').length}", "Pending"),),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard(Icons.check_circle, Colors.green, "${_requests.where((r) => r['status'] == 'COMPLETED').length}", "Completed"),),
                  ],
                ),

                const SizedBox(height: 10),

                // ----------------------------
                // ACTIVE REQUEST BANNER
                // ----------------------------
                ...(() {
                  final activeReqs = _requests.where((r) {
                    final s = (r['status'] ?? '').toString().toUpperCase();
                    return s == 'ACCEPTED' || s == 'PICKED_UP';
                  }).toList();
                  return activeReqs.map((req) {
                    final otp = req['deliveryOtp'] ?? req['otp'] ?? '----';
                    final status = req['status'] ?? 'Active';
                    final bloodGroup = req['bloodGroup'] ?? '';
                    final riderName = req['riderName'] ?? 'Rider';
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DoctorLiveTrackingScreen(
                            requestData: Map<String, dynamic>.from(req),
                          ),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE0463A), Color(0xFFFF6B6B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "🚨 Active Request",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Status: $status  •  Blood: $bloodGroup",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.lock, color: Colors.white, size: 16),
                                      const SizedBox(width: 5),
                                      Text(
                                        "OTP: $otp",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.delivery_dining, color: Color(0xFFE0463A), size: 20),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Rider: $riderName",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFFE0463A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DoctorLiveTrackingScreen(
                                      requestData: Map<String, dynamic>.from(req),
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  "Track Delivery →",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList();
                })(),

                // ----------------------------
                // CREATE NEW REQUEST BUTTON
                // ----------------------------
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0463A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (c) => CreateBloodRequestScreen(currentUser: widget.currentUser),
                                ),
                              );
                      if (result == true) {
                        _fetchRequests();
                      }
                    },
                    child: const Text(
                      "+   Create New Request",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ----------------------------
                // AVAILABLE STOCK
                // ----------------------------
                const Text(
                  "Available Stock",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _allBloodGroups.map((bg) {
                      final String key = bg.toLowerCase().replaceAll('+', 'p').replaceAll('-', 'n');
                      int units = _bloodStockMap[key] ?? 0;
                      return _stockCard(bg, units);
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // ----------------------------
                // ACTIVE REQUESTS LIST HEADER
                // ----------------------------
                const Text(
                  "Active Requests",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),
                
                // ----------------------------
                // FILTERS & SEARCH
                // ----------------------------
                
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search Blood Group (e.g. A+)",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFFE0463A)),
                        onPressed: () {
                          setState(() {
                            _searchQuery = _searchController.text;
                          });
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Status Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip("All"),
                      _filterChip("Pending"),
                      _filterChip("Accepted"),
                      _filterChip("Pickup"),
                      _filterChip("Completed"),
                      _filterChip("Cancelled"),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),

                // ----------------------------
                // LIST
                // ----------------------------

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (filteredRequests.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "No requests found matching criteria.", 
                        style: TextStyle(color: Colors.grey[600])
                      ),
                    )
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredRequests.length,
                    itemBuilder: (context, index) {
                      final req = filteredRequests[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DoctorLiveTrackingScreen(
                                  requestData: Map<String, dynamic>.from(req),
                                ),
                              ),
                            );
                          },
                          child: _requestCard(req),
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

  Widget _filterChip(String status) {
    bool isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(status),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _selectedStatus = status;
          });
        },
        selectedColor: const Color(0xFFE0463A),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  // -----------------------------------------
  // STAT CARD
  // -----------------------------------------
  Widget _statCard(IconData icon, Color color, String value, String label) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // -----------------------------------------
  // REQUEST CARD (Dynamic)
  // -----------------------------------------
  Widget _requestCard(dynamic req) {
    String status = req['status'] ?? "PENDING";
    Color statusColor = Colors.orange;
    if (status == "ACCEPTED") statusColor = Colors.blue;
    if (status == "COMPLETED") statusColor = Colors.green;
    if (status == "CANCELLED") statusColor = Colors.red;
    if (status == "PICKED_UP") statusColor = Colors.purple;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        "Status : ",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(color: statusColor, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text("Target: ${req['bloodGroup']}", style: TextStyle(color: Colors.grey[600])),
                Text(
                  "${req['units']} Units • ${req['urgency']}",
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // Time / ETA
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _timeAgo(req['date'], req['time']),
                style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ],
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
        int year, month, day;
        if (dateParts[0].length == 4) {
          year = int.parse(dateParts[0]);
          month = int.parse(dateParts[1]);
          day = int.parse(dateParts[2]);
        } else {
          year = int.parse(dateParts[2]);
          month = int.parse(dateParts[1]);
          day = int.parse(dateParts[0]);
        }
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

  // -----------------------------------------
  // STOCK CARD
  // -----------------------------------------
  Widget _stockCard(String type, int units) {
    return GestureDetector(
      onTap: () => _updateStockPopup(type, units),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              type,
              style: const TextStyle(
                  color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text("$units units"),
          ],
        ),
      ),
    );
  }

  void _updateStockPopup(String bloodGroup, int currentUnits) {
    final TextEditingController _unitsController = TextEditingController(text: currentUnits.toString());
    bool isUpdating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text("Update $bloodGroup Stock", style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _unitsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Units Available",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isUpdating ? null : () => Navigator.pop(ctx),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isUpdating ? null : () async {
                    setState(() => isUpdating = true);
                    final newUnits = int.tryParse(_unitsController.text) ?? 0;
                    try {
                      final updatedStock = await ApiService.updateBloodStock(widget.currentUser['userId'], bloodGroup, newUnits);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                      
                      // Immediately patch the main screen's state natively!
                      this.setState(() {
                        _bloodStockMap = updatedStock;
                      });
                    } catch (e) {
                      if (ctx.mounted) {
                        setState(() => isUpdating = false);
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    }
                  },
                  child: isUpdating 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      }
    );
  }
  
}
