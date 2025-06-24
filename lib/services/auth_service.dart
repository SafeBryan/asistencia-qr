import 'dart:convert';
import 'package:asistencia_qr/config.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/token_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "${AppConfig.baseUrl}/auth";

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final user = User.fromJson(body['data']['user']);
      final token = Token.fromJson(body['data']['token']);

      await saveSession(user, token);

      return {"user": user, "token": token};
    } else {
      throw Exception("Login fallido");
    }
  }

  Future<void> saveSession(User user, Token token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token.accessToken);
    await prefs.setString('refreshToken', token.refreshToken);
    await prefs.setString('role', user.role);
    await prefs.setString('userId', user.id);
    await prefs.setString('email', user.email);
  }
}
