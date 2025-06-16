import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/qr_matricula_screen.dart';
import '../screens/asistencia_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String qrMatricula = '/qr';
  static const String asistencia = '/asistencia';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    qrMatricula: (context) => const QrMatriculaScreen(),
    asistencia: (context) => const AsistenciaScreen(),
  };
}
