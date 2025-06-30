import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/course_provider.dart';

// Pages
import 'pages/login_page.dart';
import 'pages/admin_home.dart';
import 'pages/teacher_home.dart';
import 'pages/student_home_page.dart';
import 'pages/admin/user_management_page.dart';
import 'pages/admin/course_management_page.dart';
import 'pages/admin/classroom_management_page.dart';
import 'pages/admin/reports_page.dart';
import 'pages/teacher/attendance_management_page.dart';
import 'pages/student/qr_scan_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // necesario para SharedPreferences

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
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CourseProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Asistencia QR',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(centerTitle: true),
        ),
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
      ),
    );
  }
}
