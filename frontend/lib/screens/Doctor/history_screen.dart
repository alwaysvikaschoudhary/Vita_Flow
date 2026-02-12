import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DoctorHistoryScreen extends StatelessWidget {
  const DoctorHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  _metricCard("156", "Total Requests", Icons.show_chart, Colors.blue.shade100),
                  _metricCard("98%", "Fulfillment", Icons.emoji_events, Colors.green.shade100),
                  _metricCard("24m", "Avg Time", Icons.access_time, Colors.purple.shade100),
                ],
              ),

              const SizedBox(height: 10),

              // -------------------------
              // Monthly Requests Chart
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
                              if (value.toInt() < 0 || value.toInt() > 5) return Container();
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
                            FlSpot(0, 45),
                            FlSpot(1, 52),
                            FlSpot(2, 48),
                            FlSpot(3, 61),
                            FlSpot(4, 58),
                            FlSpot(5, 70),
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
                          sections: [
                            _pieSection(35, Colors.red),          // O+
                            _pieSection(25, Colors.orange),       // A+
                            _pieSection(20, Colors.yellow),       // B+
                            _pieSection(10, Colors.green),        // AB+
                            _pieSection(10, Colors.grey),         // Others
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    _legend("O+", "35%", Colors.red),
                    _legend("A+", "25%", Colors.orange),
                    _legend("B+", "20%", Colors.yellow),
                    _legend("AB+", "10%", Colors.green),
                    _legend("Others", "10%", Colors.grey),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
  PieChartSectionData _pieSection(double value, Color color) {
    return PieChartSectionData(
      value: value,
      color: color,
      radius: 50,
      title: "",
    );
  }

  Widget _legend(String type, String percent, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Row(
        children: [
          CircleAvatar(
            radius: 6,
            backgroundColor: color,
          ),
          const SizedBox(width: 8),
          Text(type),
          const Spacer(),
          Text(percent),
        ],
      ),
    );
  }
}
