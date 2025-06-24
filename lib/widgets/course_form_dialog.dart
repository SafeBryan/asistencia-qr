import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/faculty_service.dart';
import '../models/faculty_model.dart';

class CourseFormDialog extends StatefulWidget {
  final Course? course;

  const CourseFormDialog({super.key, this.course});

  @override
  State<CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController semesterController;

  Faculty? selectedFaculty;
  List<Faculty> faculties = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.course?.name ?? '');
    semesterController = TextEditingController(
      text: widget.course?.semester ?? '',
    );
    _loadFaculties();
  }

  void _loadFaculties() async {
    try {
      faculties = await FacultyService().getAllFaculties();
      if (widget.course != null) {
        selectedFaculty = faculties.firstWhere(
          (f) => f.id == widget.course!.facultyId,
          orElse: () => faculties.first,
        );
      }
    } catch (e) {
      faculties = [];
    }
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    nameController.dispose();
    semesterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.course == null ? 'Crear Curso' : 'Editar Curso'),
      content: isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del curso',
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Campo obligatorio'
                          : null,
                    ),
                    DropdownButtonFormField<Faculty>(
                      value: selectedFaculty,
                      decoration: const InputDecoration(labelText: 'Facultad'),
                      items: faculties.map((f) {
                        return DropdownMenuItem<Faculty>(
                          value: f,
                          child: Text(f.name),
                        );
                      }).toList(),
                      onChanged: (f) {
                        setState(() => selectedFaculty = f);
                      },
                      validator: (value) =>
                          value == null ? 'Seleccione una facultad' : null,
                    ),
                    TextFormField(
                      controller: semesterController,
                      decoration: const InputDecoration(labelText: 'Semestre'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Campo obligatorio'
                          : null,
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
              final course = Course(
                id: widget.course?.id ?? '',
                name: nameController.text.trim(),
                facultyId: selectedFaculty!.id,
                semester: semesterController.text.trim(),
              );
              Navigator.pop(context, course);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
