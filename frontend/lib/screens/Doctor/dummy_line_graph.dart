import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DummyLineChart extends StatelessWidget {
  const DummyLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 5,
          minY: 0,
          maxY: 80,
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"];
                  return Text(months[value.toInt()]);
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),

          lineBarsData: [
            LineChartBarData(
              color: Colors.red,
              barWidth: 3,
              isCurved: true,
              dotData: FlDotData(show: true),

              spots: const [
                FlSpot(0, 45),
                FlSpot(1, 52),
                FlSpot(2, 48),
                FlSpot(3, 60),
                FlSpot(4, 58),
                FlSpot(5, 68),
              ],
            )
          ],
        ),
      ),
    );
  }
}
