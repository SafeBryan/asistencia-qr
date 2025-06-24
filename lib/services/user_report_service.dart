import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../config.dart';

class UserReportService {
  final String baseUrl = "${AppConfig.baseUrl}/admin/users";

  Future<Map<String, int>> getUserCountsByRole() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> usersJson = jsonDecode(response.body)['data'];
      final List<User> users = usersJson.map((e) => User.fromJson(e)).toList();

      final counts = <String, int>{};
      for (final user in users) {
        counts[user.role] = (counts[user.role] ?? 0) + 1;
      }
      return counts;
    } else {
      throw Exception("Error al obtener usuarios");
    }
  }
}
