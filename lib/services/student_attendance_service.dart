import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class StudentAttendanceService {
  final String baseUrl = '${AppConfig.baseUrl}/attendance';

  // 🔹 Método para marcar asistencia (ya estaba bien)
  Future<void> markAttendanceAdvanced({
    required String classScheduleId,
    required String status,
    required DateTime date,
    required double userLatitude,
    required double userLongitude,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString('userId');
    final token = prefs.getString('accessToken');

    if (studentId == null || token == null) {
      throw Exception('No hay sesión activa');
    }

    DateTime adjustedNow = date.toUtc().subtract(const Duration(seconds: 1));
    String isoDate = adjustedNow.toIso8601String().split('.').first + 'Z';

    final Map<String, dynamic> data = {
      "studentId": studentId,
      "classScheduleId": classScheduleId,
      "status": status,
      "date": isoDate,
      "userLatitude": userLatitude,
      "userLongitude": userLongitude,
    };

    print("📦 JSON que se enviará al backend: ${jsonEncode(data)}");

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error al marcar asistencia: ${response.body}');
    }
  }

  // 🔹 Método de matrícula automática
  Future<void> enrollStudent({required String sectionId}) async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString('userId');
    final token = prefs.getString('accessToken');

    if (studentId == null || token == null) {
      throw Exception('No hay sesión activa');
    }

    final String enrollmentUrl =
        '${AppConfig.baseUrl}/courses/sections/$sectionId/enroll';

    final Map<String, dynamic> enrollmentData = {"studentId": studentId};

    print(
      "📦 Enviando enrollment: ${jsonEncode(enrollmentData)} a $enrollmentUrl",
    );

    final response = await http.post(
      Uri.parse(enrollmentUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(enrollmentData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al matricular: ${response.body}');
    }

    print("✅ Matriculación exitosa: ${response.body}");
  }

  // 🔹 Obtener el classScheduleId filtrando en Flutter
  Future<String> getClassScheduleIdByCourseId({
    required String courseId,
    required String sectionId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) {
      throw Exception('No hay sesión activa');
    }

    final String url = '${AppConfig.baseUrl}/courses/$courseId/schedules';

    print("🔍 Obteniendo schedules de $url");

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al obtener horarios: ${response.body}');
    }

    final List<dynamic> schedules = jsonDecode(response.body);

    final matchingSchedule = schedules.firstWhere(
      (schedule) => schedule['section_id'] == sectionId,
      orElse: () => null,
    );

    if (matchingSchedule == null) {
      throw Exception('No se encontró un horario para esta sección.');
    }

    print("✅ Schedule encontrado: ${matchingSchedule['id']}");
    return matchingSchedule['id'];
  }
}
