import 'package:asistencia_qr/widgets/user_form_dialog.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final UserService _userService = UserService();
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _userService.getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Usuarios')),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text('${user.firstName} ${user.lastName}'),
                subtitle: Text('${user.email} • ${user.role.toUpperCase()}'),
                trailing: const Icon(Icons.lock_outline, color: Colors.grey),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (_) => const UserFormDialog(),
          );

          if (result != null) {
            final created = await _userService.createUser(result);
            if (created) {
              setState(() {
                _usersFuture = _userService.getAllUsers();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuario creado correctamente')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No se pudo crear el usuario')),
              );
            }
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Crear nuevo usuario',
      ),
    );
  }
}
