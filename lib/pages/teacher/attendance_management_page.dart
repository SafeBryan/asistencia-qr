import 'package:flutter/material.dart';
import '../../models/attendance_model.dart';
import '../../services/attendance_service.dart';
import '../../widgets/attendance_form_dialog.dart';

class AttendanceManagementPage extends StatefulWidget {
  const AttendanceManagementPage({super.key});

  @override
  State<AttendanceManagementPage> createState() =>
      _AttendanceManagementPageState();
}

class _AttendanceManagementPageState extends State<AttendanceManagementPage> {
  final AttendanceService _attendanceService = AttendanceService();
  late Future<List<Attendance>> _attendancesFuture;

  @override
  void initState() {
    super.initState();
    _loadAttendances();
  }

  void _loadAttendances() {
    setState(() {
      _attendancesFuture = _attendanceService.getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Asistencia')),
      body: FutureBuilder<List<Attendance>>(
        future: _attendancesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final attendances = snapshot.data ?? [];

          return ListView.builder(
            itemCount: attendances.length,
            itemBuilder: (context, index) {
              final att = attendances[index];
              return ListTile(
                leading: const Icon(Icons.event_available),
                title: Text('Curso: ${att.courseId} • Día: ${att.dayOfWeek}'),
                subtitle: Text('De ${att.startTime} a ${att.endTime}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final updated = await showDialog<Attendance>(
                          context: context,
                          builder: (_) => AttendanceFormDialog(attendance: att),
                        );
                        if (updated != null) {
                          await _attendanceService.update(att.id, updated);
                          _loadAttendances();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Asistencia actualizada'),
                            ),
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
                            content: const Text(
                              '¿Deseas eliminar esta asistencia?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await _attendanceService.delete(att.id);
                          _loadAttendances();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Asistencia eliminada'),
                            ),
                          );
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
          final created = await showDialog<Attendance>(
            context: context,
            builder: (_) => const AttendanceFormDialog(),
          );
          if (created != null) {
            await _attendanceService.create(created);
            _loadAttendances();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Asistencia creada')));
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Registrar asistencia',
      ),
    );
  }
}
