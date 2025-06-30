import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../services/student_section_service.dart';
import '../../providers/course_provider.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final StudentSectionService _sectionService = StudentSectionService();
  Future<List<dynamic>>? _sectionsFuture; // ✅ Permitir nulo

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    try {
      await courseProvider.fetchCourses(token);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error al cargar cursos: $e')));
    }

    setState(() {
      _sectionsFuture = _sectionService.getEnrolledSections();
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  void _navigateToQRScanner() {
    Navigator.pushNamed(context, '/escanearQR').then((_) {
      setState(() {
        _sectionsFuture = _sectionService.getEnrolledSections();
      });
    });
  }

  String buildScheduleString(List<dynamic> schedules) {
    if (schedules.isEmpty) {
      return 'No disponible';
    }
    return schedules
        .map((s) {
          final day = _dayOfWeekToString(s['dayOfWeek']);
          final start = s['startTime'].toString().substring(0, 5);
          final end = s['endTime'].toString().substring(0, 5);
          return '$day: $start - $end';
        })
        .join('\n');
  }

  String _dayOfWeekToString(int dayOfWeek) {
    const days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return days[(dayOfWeek - 1).clamp(0, 6)];
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Estudiante'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: _sectionsFuture == null
          ? const Center(
              child: CircularProgressIndicator(),
            ) // ✅ Loading inicial
          : FutureBuilder<List<dynamic>>(
              future: _sectionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('❌ Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('ℹ️ No estás inscrito en ninguna clase.'),
                  );
                } else {
                  final sections = snapshot.data!;
                  return ListView.builder(
                    itemCount: sections.length,
                    itemBuilder: (context, index) {
                      final section = sections[index];
                      final sectionName =
                          section['name'] ?? 'Nombre no disponible';
                      final courseId = section['courseId'] ?? '';
                      final courseName = courseProvider.getCourseNameById(
                        courseId,
                      );
                      final schedules = section['schedules'] ?? [];
                      final scheduleText = buildScheduleString(schedules);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            '📘 $courseName',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '📖 Sección: $sectionName\n⏰ Horario:\n$scheduleText',
                          ),
                          leading: const Icon(Icons.book),
                        ),
                      );
                    },
                  );
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToQRScanner,
        tooltip: 'Registrar nueva clase',
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
