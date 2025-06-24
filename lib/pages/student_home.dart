import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Borra token, rol, etc.
    Navigator.pushReplacementNamed(context, '/'); // Vuelve al login
  }

  void _showAttendanceOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Registrar Asistencia'),
        content: const Text('Selecciona una opción:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Escanear QR'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/escanearQR');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Estudiante'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.how_to_reg),
          label: const Text('Registrar Asistencia'),
          onPressed: () => _showAttendanceOptions(context),
        ),
      ),
    );
  }
}
