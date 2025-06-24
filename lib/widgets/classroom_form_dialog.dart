import 'package:flutter/material.dart';
import '../models/classroom_model.dart';
import '../models/faculty_model.dart';
import '../services/faculty_service.dart';

class ClassroomFormDialog extends StatefulWidget {
  final Classroom? classroom;

  const ClassroomFormDialog({super.key, this.classroom});

  @override
  State<ClassroomFormDialog> createState() => _ClassroomFormDialogState();
}

class _ClassroomFormDialogState extends State<ClassroomFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _buildingController = TextEditingController();
  final _floorController = TextEditingController();
  final _capacityController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  Faculty? selectedFaculty;
  List<Faculty> faculties = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.classroom != null) {
      _nameController.text = widget.classroom!.name;
      _buildingController.text = widget.classroom!.building;
      _floorController.text = widget.classroom!.floor.toString();
      _capacityController.text = widget.classroom!.capacity.toString();
      _latController.text = widget.classroom!.locationLat.toString();
      _lngController.text = widget.classroom!.locationLng.toString();
    }
    _loadFaculties();
  }

  void _loadFaculties() async {
    try {
      faculties = await FacultyService().getAllFaculties();
      if (widget.classroom != null) {
        selectedFaculty = faculties.firstWhere(
          (f) => f.id == widget.classroom!.facultyId,
        );
      }
    } catch (_) {
      faculties = [];
    }
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _capacityController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.classroom == null ? 'Crear Aula' : 'Editar Aula'),
      content: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del aula',
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      controller: _buildingController,
                      decoration: const InputDecoration(labelText: 'Edificio'),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      controller: _floorController,
                      decoration: const InputDecoration(labelText: 'Piso'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      controller: _capacityController,
                      decoration: const InputDecoration(labelText: 'Capacidad'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    DropdownButtonFormField<Faculty>(
                      value: selectedFaculty,
                      decoration: const InputDecoration(labelText: 'Facultad'),
                      items: faculties.map((f) {
                        return DropdownMenuItem(value: f, child: Text(f.name));
                      }).toList(),
                      onChanged: (f) => setState(() => selectedFaculty = f),
                      validator: (value) =>
                          value == null ? 'Seleccione una facultad' : null,
                    ),
                    TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(labelText: 'Latitud'),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      controller: _lngController,
                      decoration: const InputDecoration(labelText: 'Longitud'),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo requerido' : null,
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
              final aula = Classroom(
                id: widget.classroom?.id ?? '',
                name: _nameController.text.trim(),
                building: _buildingController.text.trim(),
                floor: int.parse(_floorController.text),
                capacity: int.parse(_capacityController.text),
                facultyId: selectedFaculty!.id,
                locationLat: double.parse(_latController.text),
                locationLng: double.parse(_lngController.text),
              );
              Navigator.pop(context, aula);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
