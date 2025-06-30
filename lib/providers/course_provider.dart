import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class CourseProvider with ChangeNotifier {
  List<Map<String, dynamic>> _courses = [];

  List<Map<String, dynamic>> get courses => _courses;

  Future<void> fetchCourses(String token) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/courses'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      _courses = List<Map<String, dynamic>>.from(data['data'] ?? []);
      notifyListeners();
    } else {
      throw Exception('Error al cargar cursos: ${response.body}');
    }
  }

  String getCourseNameById(String courseId) {
    final course = _courses.firstWhere(
      (c) => c['id'] == courseId,
      orElse: () => {'name': 'Curso no encontrado'},
    );
    return course['name'] ?? 'Curso no encontrado';
  }
}
