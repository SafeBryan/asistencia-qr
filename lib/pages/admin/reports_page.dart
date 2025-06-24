import 'package:flutter/material.dart';
import '../../services/user_report_service.dart';
import '../../services/course_report_service.dart';
import '../../widgets/user_role_pie_chart.dart';
import '../../widgets/course_bar_chart.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final UserReportService _userReportService = UserReportService();
  final CourseReportService _courseReportService = CourseReportService();

  late Future<Map<String, int>> _userRoleCounts;
  late Future<Map<String, int>> _courseCounts;

  @override
  void initState() {
    super.initState();
    _userRoleCounts = _userReportService.getUserCountsByRole();
    _courseCounts = _courseReportService.getCourseCountBySemester();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes Generales')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Usuarios por rol',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          FutureBuilder<Map<String, int>>(
            future: _userRoleCounts,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final counts = snapshot.data!;
              return Column(
                children: [
                  UserRolePieChart(roleCounts: counts),
                  const SizedBox(height: 16),
                  ...counts.entries.map(
                    (entry) => ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(entry.key.toUpperCase()),
                      trailing: Text('${entry.value} usuarios'),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Cursos por semestre',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          FutureBuilder<Map<String, int>>(
            future: _courseCounts,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final courseData = snapshot.data!;
              return CourseBarChart(courseCounts: courseData);
            },
          ),
        ],
      ),
    );
  }
}
