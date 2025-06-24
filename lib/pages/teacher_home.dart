import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherHomePage extends StatelessWidget {
  const TeacherHomePage({super.key});

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Borra tokens, rol, etc.
    Navigator.pushReplacementNamed(context, '/'); // Regresa al login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Docente'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.book),
            label: const Text('Gestión de Cursos'),
            onPressed: () {
              Navigator.pushNamed(context, '/cursos');
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.meeting_room),
            label: const Text('Gestión de Aulas'),
            onPressed: () {
              Navigator.pushNamed(context, '/aulas');
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.assignment),
            label: const Text('Gestión de Asistencia'),
            onPressed: () {
              Navigator.pushNamed(context, '/asistencias');
            },
          ),
        ],
      ),
    );
  }
}
