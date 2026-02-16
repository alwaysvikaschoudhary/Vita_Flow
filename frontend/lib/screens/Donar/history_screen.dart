import 'package:flutter/material.dart';
import 'package:vita_flow/services/api_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const HistoryScreen({super.key, required this.currentUser});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _history = [];
  bool _isLoading = true;
  String _sortOption = 'Newest First'; // Default sort option

  final List<String> _sortOptions = [
    'Newest First',
    'Oldest First',
    'Blood Group (A-Z)',
    'Blood Group (Z-A)',
  ];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final history = await ApiService.getDonorHistory(widget.currentUser['userId']);
      if (mounted) {
        setState(() {
          _history = history;
          _isLoading = false;
        });
        _sortHistory(); // Initial sort
      }
    } catch (e) {
      print("Error fetching history: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _sortHistory() {
    setState(() {
      switch (_sortOption) {
        case 'Newest First':
          _history.sort((a, b) {
            String dateA = a['date'] ?? '';
            String dateB = b['date'] ?? '';
            return dateB.compareTo(dateA); // Descending
          });
          break;
        case 'Oldest First':
          _history.sort((a, b) {
            String dateA = a['date'] ?? '';
            String dateB = b['date'] ?? '';
            return dateA.compareTo(dateB); // Ascending
          });
          break;
        case 'Blood Group (A-Z)':
          _history.sort((a, b) {
            String bgA = a['bloodGroup'] ?? '';
            String bgB = b['bloodGroup'] ?? '';
            return bgA.compareTo(bgB);
          });
          break;
        case 'Blood Group (Z-A)':
          _history.sort((a, b) {
            String bgA = a['bloodGroup'] ?? '';
            String bgB = b['bloodGroup'] ?? '';
            return bgB.compareTo(bgA);
          });
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Donation History",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
            ),

            // METRICS BOX
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                   Expanded(
                     child: _metricBox(
                         Icons.favorite, 
                         Colors.red, 
                         "${_history.length}", 
                         "Total Donations",
                         Colors.white
                     ),
                   ),
                ],
              ),
            ),

            const SizedBox(height: 15),
            
            // SORT FILTER UI
            if (!_isLoading && _history.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Filter by:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sortOption,
                        icon: const Icon(Icons.sort, size: 20),
                        isDense: true,
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _sortOption = newValue;
                            });
                            _sortHistory();
                          }
                        },
                        items: _sortOptions.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator()) 
                  : _history.isEmpty 
                      ? const Center(child: Text("No donation history yet"))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            children: _history.map((req) {
                              
                              // Logic for Hospital + Doctor Name
                              String hospital = req['hospitalName'] ?? "Unknown Hospital";
                              String doctor = req['doctorName'] ?? "Unknown Doctor";
                              String displayHospital = "$hospital ($doctor)";

                              return _historyCard(
                                hospital: displayHospital,
                                date: req['date'] ?? "Unknown Date",
                                bloodType: req['bloodGroup'] ?? widget.currentUser['bloodGroup'] ?? "-",
                                units: req['units']?.toString() ?? "1",
                                status: req['status'] ?? "Completed"
                              );
                            }).toList(),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricBox(
      IconData icon, Color iconColor, String value, String label, Color bg) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: iconColor),
          const SizedBox(height: 10),
          Text(value,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _historyCard({
    required String hospital,
    required String date,
    required String bloodType,
    required String units,
    required String status,
  }) {
    // Format date if possible
    String displayDate = date;
    try {
       // Assuming date comes as YYYY-MM-DD
       final parsedDate = DateTime.parse(date);
       displayDate = DateFormat.yMMMMd().format(parsedDate);
    } catch (e) {
       // keep original string
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
             color: Colors.grey.withOpacity(0.05),
             blurRadius: 5,
             offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_hospital, color: Colors.red, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hospital,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(displayDate, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status.toUpperCase(), // "COMPLETED"
                    style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _historyField("Blood Type", bloodType,
                  valueColor: Colors.red),
              _verticalDivider(),
              _historyField("Units", "$units Unit"),
              _verticalDivider(),
               _historyField("Type", "Donation"), // Placeholder for "Type" or similar
            ],
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.shade200,
    );
  }

  Widget _historyField(String label, String value,
      {Color valueColor = Colors.black}) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: valueColor, 
          ),
        ),
      ],
    );
  }
}
