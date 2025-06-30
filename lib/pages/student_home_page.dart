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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Panel Estudiante',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: _sectionsFuture == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<dynamic>>(
              future: _sectionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '❌ Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.info_outline, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'ℹ️ No estás inscrito en ninguna clase.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                } else {
                  final sections = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
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
                        color: Colors.white,
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '📘 $courseName',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '📖 Sección: $sectionName',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '⏰ Horario:',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                scheduleText,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
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
