import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/faculty_model.dart';
import '../config.dart';

class FacultyService {
  final String baseUrl = "${AppConfig.baseUrl}/faculties";

  Future<List<Faculty>> getAllFaculties() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map((json) => Faculty.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener facultades');
    }
  }
}
