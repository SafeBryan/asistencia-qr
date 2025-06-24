import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/classroom_model.dart';
import '../config.dart';

class ClassroomService {
  final String baseUrl = "${AppConfig.baseUrl}/classrooms";

  Future<List<Classroom>> getAllClassrooms() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map((json) => Classroom.fromJson(json)).toList();
    } else {
      throw Exception("Error al obtener aulas");
    }
  }

  Future<void> createClassroom(Classroom classroom) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(classroom.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Error al crear aula");
    }
  }

  Future<void> updateClassroom(String id, Classroom classroom) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(classroom.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Error al actualizar aula");
    }
  }

  Future<void> deleteClassroom(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception("Error al eliminar aula");
    }
  }
}
