import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';
import '../config.dart';

class CourseReportService {
  final String baseUrl = "${AppConfig.baseUrl}/courses";

  Future<Map<String, int>> getCourseCountBySemester() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      final List<Course> courses = data.map((e) => Course.fromJson(e)).toList();

      final Map<String, int> counts = {};
      for (final course in courses) {
        final semestre = course.semester;
        counts[semestre] = (counts[semestre] ?? 0) + 1;
      }
      return counts;
    } else {
      throw Exception('Error al obtener cursos');
    }
  }
}
