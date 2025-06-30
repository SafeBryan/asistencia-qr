import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class StudentSectionService {
  final String baseUrl = "${AppConfig.baseUrl}/courses/sections";
  final String sectionBaseUrl = "${AppConfig.baseUrl}/sections";

  /// 🔹 Matricular automáticamente en la sección (flujo QR)
  Future<void> enrollInSection(String sectionId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final studentId = prefs.getString('userId');

    if (studentId == null || token == null) {
      throw Exception('No hay sesión activa.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/$sectionId/enroll'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"studentId": studentId}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al inscribirse en la sección: ${response.body}');
    }

    print("✅ Matrícula en sección exitosa: ${response.body}");
  }

  /// 🔹 Obtener el classScheduleId a partir del sectionId para registrar asistencia
  Future<String> getClassScheduleIdFromSection(String sectionId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      throw Exception('No hay sesión activa.');
    }

    final response = await http.get(
      Uri.parse('$sectionBaseUrl/$sectionId/schedules'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      print('✅ Respuesta cruda: $data');

      final schedules = data['data'];

      if (schedules is List && schedules.isNotEmpty) {
        final classScheduleId = schedules[0]['id'];
        print('✅ classScheduleId obtenido: $classScheduleId');
        return classScheduleId;
      } else {
        throw Exception('No hay horarios disponibles para esta sección.');
      }
    } else {
      print('❌ Error al obtener classScheduleId: ${response.body}');
      throw Exception(
        'No se pudo obtener el classScheduleId para la sección: ${response.body}',
      );
    }
  }

  /// ✅ Obtener las secciones en las que está inscrito el estudiante (para HomePage)
  Future<List<dynamic>> getEnrolledSections() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final studentId = prefs.getString('userId');

    if (studentId == null || token == null) {
      throw Exception('No hay sesión activa.');
    }

    final url = Uri.parse(
      "${AppConfig.baseUrl}/courses/student/$studentId/sections",
    );

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      print("✅ Datos de secciones obtenidas: $data");
      return data['data'] ?? [];
    } else {
      print('❌ Error al obtener secciones: ${response.body}');
      throw Exception('Error al obtener las clases: ${response.body}');
    }
  }

  /// ✅ Obtener detalles de una sección específica por sectionId
  Future<Map<String, dynamic>> getSectionDetails(String sectionId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      throw Exception('No hay sesión activa.');
    }

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/courses/sections/$sectionId'), // ✅ Corregido
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      print("✅ Detalles de sección obtenidos: $data");
      return data['data'] ?? {};
    } else {
      print('❌ Error al obtener detalles de sección: ${response.body}');
      throw Exception('Error al obtener detalles de sección: ${response.body}');
    }
  }
}
