import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../services/student_attendance_service.dart';
import '../../providers/course_provider.dart';

class AttendanceConfirmationPage extends StatefulWidget {
  final String classScheduleId;
  final String courseId;
  final String sectionName;

  const AttendanceConfirmationPage({
    super.key,
    required this.classScheduleId,
    required this.courseId,
    required this.sectionName,
  });

  @override
  State<AttendanceConfirmationPage> createState() =>
      _AttendanceConfirmationPageState();
}

class _AttendanceConfirmationPageState
    extends State<AttendanceConfirmationPage> {
  final StudentAttendanceService _attendanceService =
      StudentAttendanceService();
  bool _isLoading = false;

  Future<void> _markAttendance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 📍 Obtener ubicación
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // ✅ Registrar asistencia
      await _attendanceService.markAttendanceAdvanced(
        classScheduleId: widget.classScheduleId,
        status: "present",
        date: DateTime.now(),
        userLatitude: position.latitude,
        userLongitude: position.longitude,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Asistencia registrada correctamente'),
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/student',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al registrar asistencia:\n${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final courseName = courseProvider.getCourseNameById(
      widget.courseId,
    ); // ✅ Resolver dinámico

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar Asistencia')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.school, size: 80),
                  const SizedBox(height: 20),
                  Text(
                    'Bienvenido a:',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    courseName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sección: ${widget.sectionName}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: _markAttendance,
                    icon: const Icon(Icons.check_circle),
                    label: const Text(
                      'Confirmar Asistencia',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
