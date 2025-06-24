import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CourseBarChart extends StatelessWidget {
  final Map<String, int> courseCounts;

  const CourseBarChart({super.key, required this.courseCounts});

  @override
  Widget build(BuildContext context) {
    final sortedKeys = courseCounts.keys.toList()..sort();
    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < sortedKeys.length; i++) {
      final semester = sortedKeys[i];
      final count = courseCounts[semester]!;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              width: 20,
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index >= 0 && index < sortedKeys.length) {
                    return Text(sortedKeys[index]);
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
              ),
            ),
          ),
          barGroups: barGroups,
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
