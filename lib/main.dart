import 'package:asistencia_qr/pages/admin/classroom_management_page.dart';
import 'package:asistencia_qr/pages/admin/reports_page.dart';
import 'package:asistencia_qr/pages/teacher/attendance_management_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/login_page.dart';
import 'pages/admin_home.dart';
import 'pages/teacher_home.dart';
import 'pages/student_home.dart';
import 'pages/admin/user_management_page.dart';
import 'pages/admin/course_management_page.dart';
import 'package:asistencia_qr/pages/student/qr_scan_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que SharedPreferences funcione bien

  final prefs = await SharedPreferences.getInstance();
  final role = prefs.getString('role');
  final token = prefs.getString('accessToken');

  String initialRoute = '/';
  if (token != null && role != null) {
    switch (role) {
      case 'admin':
        initialRoute = '/admin';
        break;
      case 'teacher':
        initialRoute = '/teacher';
        break;
      case 'student':
        initialRoute = '/student';
        break;
    }
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asistencia QR',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const LoginPage(),
        '/admin': (context) => const AdminHomePage(),
        '/teacher': (context) => const TeacherHomePage(),
        '/student': (context) => const StudentHomePage(),
        '/usuarios': (context) => const UserManagementPage(),
        '/cursos': (context) => const CourseManagementPage(),
        '/aulas': (context) => const ClassroomManagementPage(),
        '/reportes': (context) => const ReportsPage(),
        '/asistencias': (context) => const AttendanceManagementPage(),
        '/escanearQR': (context) => const QRScanPage(),
      },
    );
  }
}
