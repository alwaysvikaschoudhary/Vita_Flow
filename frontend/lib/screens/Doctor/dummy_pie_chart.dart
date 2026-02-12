import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DummyPieChart extends StatelessWidget {
  const DummyPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 35,
          sections: [
            PieChartSectionData(
              value: 35,
              color: Colors.red,
              title: "35%",
              radius: 55,
            ),
            PieChartSectionData(
              value: 25,
              color: Colors.orange,
              title: "25%",
              radius: 55,
            ),
            PieChartSectionData(
              value: 20,
              color: Colors.yellow.shade600,
              title: "20%",
              radius: 55,
            ),
            PieChartSectionData(
              value: 10,
              color: Colors.green,
              title: "10%",
              radius: 55,
            ),
            PieChartSectionData(
              value: 10,
              color: Colors.grey,
              title: "10%",
              radius: 55,
            ),
          ],
        ),
      ),
    );
  }
}
