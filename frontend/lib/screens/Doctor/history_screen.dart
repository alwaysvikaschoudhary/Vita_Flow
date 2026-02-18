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
  bool _isNewestFirst = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Chart Logic
  String _chartFilter = 'Last 6 Months';
  // Use static const to avoid null initialization issues on hot reload
  static const List<String> _chartFilters = ['Last 3 Months', 'Last 6 Months', 'Last Year', 'All Time'];

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
          // Sort by date and time
          _requests = requests..sort(_compareRequests);
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

  int _compareRequests(dynamic a, dynamic b) {
    int comparison;
    try {
      final String dateA = a['date'] ?? '1970-01-01';
      final String timeA = a['time'] ?? '00:00';
      final String dateB = b['date'] ?? '1970-01-01';
      final String timeB = b['time'] ?? '00:00';
      
      final dtA = DateTime.parse("$dateA $timeA"); // Expects yyyy-MM-dd HH:mm
      final dtB = DateTime.parse("$dateB $timeB");
      
      comparison = dtB.compareTo(dtA);
    } catch (e) {
      // Fallback to string comparison
      final String dtA = "${a['date']} ${a['time']}";
      final String dtB = "${b['date']} ${b['time']}";
      comparison = dtB.compareTo(dtA);
    }
    return _isNewestFirst ? comparison : -comparison;
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

  // Chart Helpers
  List<FlSpot> _getChartSpots() {
    final now = DateTime.now();
    int monthsBack = 6;
    if (_chartFilter == 'Last 3 Months') monthsBack = 3;
    if (_chartFilter == 'Last 6 Months') monthsBack = 6;
    if (_chartFilter == 'Last Year' || _chartFilter == 'All Time') monthsBack = 12;

    // Initialize counts for each month bucket [0..monthsBack-1]
    // Index 0 = (now - monthsBack + 1) months ago
    // Index monthsBack-1 = current month
    List<double> monthlyCounts = List.filled(monthsBack, 0.0);

    for (var req in _requests) {
      String dateStr = req['date'] ?? '';
      if (dateStr.isEmpty) continue;
      
      try {
        DateTime reqDate;
        // Handle various date formats if necessary, assuming yyyy-MM-dd
        // If date comes as dd-MM-yyyy or similar, might need adjustment. 
        // Based on _compareRequests, it seems to parse standard format or is consistent string.
        // Let's safe parse.
        try {
          reqDate = DateTime.parse(dateStr);
        } catch (_) {
          continue; 
        }

        // Calculate difference in months from now
        // diff = (now.year - req.year) * 12 + now.month - req.month
        int monthDiff = (now.year - reqDate.year) * 12 + now.month - reqDate.month;
        
        // We want data within [0, monthsBack-1] range of difference
        // The chart displays from oldest (left) to newest (right)
        // If monthDiff is 0 (current month), it goes to last index: index = monthsBack - 1 - 0
        // If monthDiff is monthsBack - 1, it goes to first index: index = monthsBack - 1 - (monthsBack - 1) = 0
        
        if (monthDiff >= 0 && monthDiff < monthsBack) {
          int index = monthsBack - 1 - monthDiff;
          monthlyCounts[index]++;
        }
      } catch (e) {
        // ignore invalid dates
      }
    }

    return List.generate(monthsBack, (index) {
      return FlSpot(index.toDouble(), monthlyCounts[index]);
    });
  }

  List<String> _getChartMonths() {
    final now = DateTime.now();
    int count = 6;
    if (_chartFilter == 'Last 3 Months') count = 3;
    if (_chartFilter == 'Last 6 Months') count = 6;
    if (_chartFilter == 'Last Year' || _chartFilter == 'All Time') count = 12;

    List<String> months = [];
    for (int i = count - 1; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      months.add(_monthName(d.month));
    }
    return months;
  }

  String _monthName(int month) {
    const m = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    if (month < 1 || month > 12) return "";
    return m[month - 1];
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
                  children: [
                    Expanded(child: _metricCard("$totalRequests", "Total Requests", Icons.show_chart, Colors.blue.shade50, Colors.blue)),
                    const SizedBox(width: 12),
                    Expanded(child: _metricCard("$fulfillmentRate%", "Fulfillment", Icons.emoji_events, Colors.green.shade50, Colors.green)),
                    const SizedBox(width: 12),
                    Expanded(child: _metricCard("${_requests.where((r) => r['status']=='PENDING').length}", "Action Needed", Icons.assignment_late, Colors.orange.shade50, Colors.orange)),
                  ],
                ),

                const SizedBox(height: 10),

                // -------------------------
                // Monthly Requests Chart
                // -------------------------
                _sectionCard(
                  title: "Monthly Requests",
                  action: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _chartFilter,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 20),
                        isDense: true,
                        style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                        onChanged: (String? newValue) {
                          if (newValue != null) setState(() => _chartFilter = newValue);
                        },
                        items: _chartFilters.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  child: SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true, 
                          drawVerticalLine: false,
                          horizontalInterval: 5,
                          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                final months = _getChartMonths();
                                if (value.toInt() < 0 || value.toInt() >= months.length) return Container();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    months[value.toInt()],
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 10, 
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            preventCurveOverShooting: true,
                            color: const Color(0xFFE0463A),
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                radius: 2,
                                color: Colors.white,
                                strokeWidth: 2,
                                strokeColor: const Color(0xFFE0463A),
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: const Color(0xFFE0463A).withOpacity(0.1),
                            ),
                            spots: _getChartSpots(),
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
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "History Log",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _isNewestFirst = !_isNewestFirst;
                          _requests.sort(_compareRequests);
                        });
                      },
                      icon: Icon(
                        _isNewestFirst ? Icons.arrow_downward : Icons.arrow_upward,
                        size: 16,
                        color: const Color(0xFFE0463A),
                      ),
                      label: Text(
                        _isNewestFirst ? "Newest First" : "Oldest First",
                        style: const TextStyle(
                          color: Color(0xFFE0463A),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
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
  Widget _metricCard(String value, String label, IconData icon, Color bg, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.w800,
              color: Colors.black87
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label, 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
              height: 1.2
            )
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // SECTION CARD
  // ----------------------------------------------------
  Widget _sectionCard({required String title, required Widget child, Widget? action}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (action != null) action,
            ],
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
