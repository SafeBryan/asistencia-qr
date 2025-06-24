import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class UserRolePieChart extends StatelessWidget {
  final Map<String, int> roleCounts;

  const UserRolePieChart({super.key, required this.roleCounts});

  @override
  Widget build(BuildContext context) {
    final total = roleCounts.values.fold<int>(0, (a, b) => a + b);

    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [Colors.blue, Colors.green, Colors.orange];
    final roles = roleCounts.keys.toList();

    for (int i = 0; i < roles.length; i++) {
      final role = roles[i];
      final count = roleCounts[role]!;
      final percentage = (count / total) * 100;

      sections.add(
        PieChartSectionData(
          value: count.toDouble(),
          title: '${percentage.toStringAsFixed(1)}%',
          color: colors[i % colors.length],
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 16,
          children: List.generate(roles.length, (i) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: colors[i % colors.length],
                  radius: 6,
                ),
                const SizedBox(width: 6),
                Text('${roles[i]} (${roleCounts[roles[i]]})'),
              ],
            );
          }),
        ),
      ],
    );
  }
}
