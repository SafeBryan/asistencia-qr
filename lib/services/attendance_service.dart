import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  final String baseUrl = '${AppConfig.baseUrl}/attendance';

  Future<List<Attendance>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((e) => Attendance.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener asistencias');
    }
  }

  Future<void> create(Attendance attendance) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(attendance.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al crear la asistencia');
    }
  }

  Future<void> update(String id, Attendance attendance) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(attendance.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar la asistencia');
    }
  }

  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la asistencia');
    }
  }
}
