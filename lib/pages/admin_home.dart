import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Administrador'),
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
            icon: const Icon(Icons.people),
            label: const Text('Gestión de Usuarios'),
            onPressed: () {
              Navigator.pushNamed(context, '/usuarios');
            },
          ),
          const SizedBox(height: 12),
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
            icon: const Icon(Icons.analytics),
            label: const Text('Reportes Generales'),
            onPressed: () {
              Navigator.pushNamed(context, '/reportes');
            },
          ),
        ],
      ),
    );
  }
}
