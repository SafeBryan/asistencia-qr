import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';
import '../config.dart';

class StudentCourseService {
  final String baseUrl = "${AppConfig.baseUrl}/courses";

  Future<List<Course>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] as List<dynamic>;
      return data.map((json) => Course.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener cursos: ${response.body}');
    }
  }
}
