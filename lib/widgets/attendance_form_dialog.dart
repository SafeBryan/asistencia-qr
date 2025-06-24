import 'package:flutter/material.dart';
import '../models/attendance_model.dart';

class AttendanceFormDialog extends StatefulWidget {
  final Attendance? attendance;

  const AttendanceFormDialog({super.key, this.attendance});

  @override
  State<AttendanceFormDialog> createState() => _AttendanceFormDialogState();
}

class _AttendanceFormDialogState extends State<AttendanceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _courseIdController = TextEditingController();
  final _sectionIdController = TextEditingController();
  final _classroomIdController = TextEditingController();
  final _dayOfWeekController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.attendance != null) {
      _courseIdController.text = widget.attendance!.courseId;
      _sectionIdController.text = widget.attendance!.sectionId;
      _classroomIdController.text = widget.attendance!.classroomId;
      _dayOfWeekController.text = widget.attendance!.dayOfWeek;
      _startTimeController.text = widget.attendance!.startTime;
      _endTimeController.text = widget.attendance!.endTime;
    }
  }

  @override
  void dispose() {
    _courseIdController.dispose();
    _sectionIdController.dispose();
    _classroomIdController.dispose();
    _dayOfWeekController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.attendance == null
            ? 'Registrar Asistencia'
            : 'Editar Asistencia',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _courseIdController,
                decoration: const InputDecoration(labelText: 'ID del Curso'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _sectionIdController,
                decoration: const InputDecoration(
                  labelText: 'ID de la Sección',
                ),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _classroomIdController,
                decoration: const InputDecoration(labelText: 'ID del Aula'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _dayOfWeekController,
                decoration: const InputDecoration(
                  labelText: 'Día de la semana (ej. Monday)',
                ),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _startTimeController,
                decoration: const InputDecoration(
                  labelText: 'Hora de inicio (HH:mm)',
                ),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _endTimeController,
                decoration: const InputDecoration(
                  labelText: 'Hora de fin (HH:mm)',
                ),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
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
              final att = Attendance(
                id: widget.attendance?.id ?? '',
                courseId: _courseIdController.text.trim(),
                sectionId: _sectionIdController.text.trim(),
                classroomId: _classroomIdController.text.trim(),
                dayOfWeek: _dayOfWeekController.text.trim(),
                startTime: _startTimeController.text.trim(),
                endTime: _endTimeController.text.trim(),
              );
              Navigator.pop(context, att);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
