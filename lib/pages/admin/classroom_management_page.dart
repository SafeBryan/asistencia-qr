import 'package:flutter/material.dart';
import '../../models/classroom_model.dart';
import '../../services/classroom_service.dart';
import '../../widgets/classroom_form_dialog.dart';

class ClassroomManagementPage extends StatefulWidget {
  const ClassroomManagementPage({super.key});

  @override
  State<ClassroomManagementPage> createState() =>
      _ClassroomManagementPageState();
}

class _ClassroomManagementPageState extends State<ClassroomManagementPage> {
  final ClassroomService _classroomService = ClassroomService();
  late Future<List<Classroom>> _classroomsFuture;

  @override
  void initState() {
    super.initState();
    _loadClassrooms();
  }

  void _loadClassrooms() {
    setState(() {
      _classroomsFuture = _classroomService.getAllClassrooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Aulas')),
      body: FutureBuilder<List<Classroom>>(
        future: _classroomsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final classrooms = snapshot.data ?? [];

          return ListView.builder(
            itemCount: classrooms.length,
            itemBuilder: (context, index) {
              final classroom = classrooms[index];
              return ListTile(
                leading: const Icon(Icons.meeting_room),
                title: Text('${classroom.name} • ${classroom.building}'),
                subtitle: Text(
                  'Piso ${classroom.floor} - Capacidad ${classroom.capacity}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final updated = await showDialog<Classroom>(
                          context: context,
                          builder: (_) =>
                              ClassroomFormDialog(classroom: classroom),
                        );
                        if (updated != null) {
                          await _classroomService.updateClassroom(
                            classroom.id,
                            updated,
                          );
                          _loadClassrooms();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Aula actualizada')),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar eliminación'),
                            content: Text(
                              '¿Deseas eliminar el aula "${classroom.name}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          try {
                            await _classroomService.deleteClassroom(
                              classroom.id,
                            );
                            _loadClassrooms();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Aula eliminada')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error al eliminar: ${e.toString()}',
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await showDialog<Classroom>(
            context: context,
            builder: (_) => const ClassroomFormDialog(),
          );
          if (created != null) {
            await _classroomService.createClassroom(created);
            _loadClassrooms();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Aula creada')));
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Crear aula',
      ),
    );
  }
}
