import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserFormDialog extends StatefulWidget {
  final User? user; // null si es nuevo

  const UserFormDialog({super.key, this.user});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController passwordController;
  String selectedRole = 'student';

  @override
  void initState() {
    super.initState();
    passwordController = TextEditingController();
    emailController = TextEditingController(text: widget.user?.email ?? '');
    firstNameController = TextEditingController(
      text: widget.user?.firstName ?? '',
    );
    lastNameController = TextEditingController(
      text: widget.user?.lastName ?? '',
    );
    selectedRole = widget.user?.role ?? 'student';
  }

  @override
  void dispose() {
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear Usuario'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Correo'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'Nombres'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Apellidos'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: const [
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Administrador'),
                  ),
                  DropdownMenuItem(value: 'teacher', child: Text('Profesor')),
                  DropdownMenuItem(value: 'student', child: Text('Estudiante')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => selectedRole = value);
                },
                decoration: const InputDecoration(labelText: 'Rol'),
              ),
              if (widget.user == null)
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo obligatorio'
                      : (value.length < 6 ? 'Mínimo 6 caracteres' : null),
                ),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final userData = {
                'email': emailController.text.trim(),
                'firstName': firstNameController.text.trim(),
                'lastName': lastNameController.text.trim(),
                'role': selectedRole,
              };

              if (widget.user == null) {
                userData['password'] = passwordController.text.trim();
              }

              Navigator.pop(
                context,
                userData,
              ); // Devuelve los datos al llamador
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
