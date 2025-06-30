import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ClassScheduleService {
  final String sectionBaseUrl = "${AppConfig.baseUrl}/sections";
  final String scheduleBaseUrl = "${AppConfig.baseUrl}/class-schedules";

  /// Obtener todos los horarios de una sección
  Future<List<dynamic>> getSchedulesBySection(String sectionId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse('$sectionBaseUrl/$sectionId/schedules'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'];
    } else {
      throw Exception(
        'Error al obtener horarios de la sección: ${response.body}',
      );
    }
  }

  /// Obtener detalles de un horario por ID (usado al escanear QR)
  Future<Map<String, dynamic>> getScheduleById(String scheduleId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse('$scheduleBaseUrl/$scheduleId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'] as Map<String, dynamic>;
    } else {
      throw Exception(
        'Error al obtener detalles del horario: ${response.body}',
      );
    }
  }
}
