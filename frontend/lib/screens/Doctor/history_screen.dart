import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vita_flow/services/api_service.dart';

class DoctorHistoryScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const DoctorHistoryScreen({super.key, required this.currentUser});

  @override
  State<DoctorHistoryScreen> createState() => _DoctorHistoryScreenState();
}

class _DoctorHistoryScreenState extends State<DoctorHistoryScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;

  // Filters
  String _selectedStatus = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRequests() async {
    try {
      final requests = await ApiService.getRequestsByHospital(widget.currentUser['userId']);
      if (mounted) {
        setState(() {
          // Sort reverse to show newest first
          _requests = requests.reversed.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching history requests: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<dynamic> _getFilteredRequests() {
    return _requests.where((req) {
      // 1. Status Filter
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

      // NO DATE FILTER - Show all history
      return statusMatches && searchMatches;
    }).toList();
  }

  // Stats Calculation
  Map<String, double> _calculateBloodStats() {
    Map<String, double> counts = {};
    int total = _requests.length;
    if (total == 0) return {};

    for (var req in _requests) {
      String bg = req['bloodGroup'] ?? 'Unknown';
      counts[bg] = (counts[bg] ?? 0) + 1;
    }

    // Convert to percentages? Or just counts. Pie chart needs values. 
    // Let's return raw counts for pie chart.
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final filteredRequests = _getFilteredRequests();
    final totalRequests = _requests.length;
    final fulfilled = _requests.where((r) => r['status'] == 'COMPLETED').length;
    final fulfillmentRate = totalRequests > 0 ? ((fulfilled / totalRequests) * 100).toInt() : 0;
    
    final bloodStats = _calculateBloodStats();

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
                // -------------------------
                // HEADER
                // -------------------------
                const Text(
                  "Reports & Analytics",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                // -------------------------
                // TOP METRICS ROW
                // -------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _metricCard("$totalRequests", "Total Requests", Icons.show_chart, Colors.blue.shade100),
                    _metricCard("$fulfillmentRate%", "Fulfillment", Icons.emoji_events, Colors.green.shade100),
                    // Avg Time is tricky without complex date diffs, keeping static for now or maybe "Pending" count?
                    _metricCard("${_requests.where((r) => r['status']=='PENDING').length}", "Pending", Icons.access_time, Colors.purple.shade100),
                  ],
                ),

                const SizedBox(height: 10),

                // -------------------------
                // Monthly Requests Chart (Mocked for visual, or implemented if we have date parsing)
                // -------------------------
                _sectionCard(
                  title: "Monthly Requests",
                  child: SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"];
                                if (value.toInt() < 0 || value.toInt() >= months.length) return Container();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(months[value.toInt()]),
                                );
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                            spots: const [
                              FlSpot(0, 5), // Mock data
                              FlSpot(1, 8),
                              FlSpot(2, 6),
                              FlSpot(3, 12),
                              FlSpot(4, 9),
                              FlSpot(5, 15),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // -------------------------
                // DONUT CHART
                // -------------------------
                if (bloodStats.isNotEmpty)
                _sectionCard(
                  title: "Blood Type Demand",
                  child: Column(
                    children: [
                      SizedBox(
                        height: 220,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 0,
                            centerSpaceRadius: 45,
                            sections: bloodStats.entries.map((entry) {
                              return _pieSection(entry.value, _getColorForBlood(entry.key), entry.key);
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: bloodStats.keys.map((key) {
                          int count = bloodStats[key]!.toInt();
                          int percent = ((count / totalRequests) * 100).toInt();
                          return _legend(key, "$percent%", _getColorForBlood(key));
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                const Text(
                  "History Log",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 10),

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
                        child: _requestCard(req),
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

  Color _getColorForBlood(String type) {
    switch (type) {
      case 'A+': return Colors.orange;
      case 'A-': return Colors.deepOrange;
      case 'B+': return Colors.yellow;
      case 'B-': return Colors.amber;
      case 'O+': return Colors.red;
      case 'O-': return Colors.pink;
      case 'AB+': return Colors.green;
      case 'AB-': return Colors.teal;
      default: return Colors.grey;
    }
  }

  // ----------------------------------------------------
  // METRIC CARD
  // ----------------------------------------------------
  Widget _metricCard(String value, String label, IconData icon, Color bg) {
    return Container(
      width: 110,
      padding: const EdgeInsets.only(top: 13, bottom: 13),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 26),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(fontSize: 15 ,color: Colors.black54)),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // SECTION CARD
  // ----------------------------------------------------
  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // DONUT CHART SECTION
  // ----------------------------------------------------
  PieChartSectionData _pieSection(double value, Color color, String title) {
    return PieChartSectionData(
      value: value,
      color: color,
      radius: 50,
      title: "",
    );
  }

  Widget _legend(String type, String percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 12, bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 4,
            backgroundColor: color,
          ),
          const SizedBox(width: 6),
          Text("$type ($percent)", style: const TextStyle(fontSize: 12)),
        ],
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
                    Text(
                      "Status : ",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
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
          
          // Time
          Column(
             children: [
                Text(
                  req['date'] ?? '',
                   style: const TextStyle(fontSize: 12, color: Colors.grey),
                )
             ],
          )
        ],
      ),
    );
  }
}
