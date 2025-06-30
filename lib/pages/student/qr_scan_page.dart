import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/student_attendance_service.dart';
import '../../services/student_section_service.dart';
import 'attendance_confirmation_page.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key});

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  bool _isScanned = false;
  final StudentAttendanceService _attendanceService =
      StudentAttendanceService();
  final StudentSectionService _sectionService = StudentSectionService();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  /// ✅ Solicitar permisos de ubicación al abrir la pantalla
  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '❌ Permiso de ubicación denegado. No podrás registrar asistencia.',
            ),
          ),
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '❌ Permiso de ubicación denegado permanentemente. Actívalo manualmente en configuración.',
          ),
        ),
      );
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isScanned) return;
    final barcode = capture.barcodes.first;
    final qrRawValue = barcode.rawValue;
    print('✅ QR leído: $qrRawValue');

    if (qrRawValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ QR inválido o no legible.')),
      );
      return;
    }

    // ✅ Parsear JSON del QR
    late String sectionId;
    try {
      final qrData = jsonDecode(qrRawValue);
      sectionId = qrData['courseSectionId'];
      if (sectionId == null) throw Exception('QR sin courseSectionId.');
      print('✅ sectionId extraído del QR: $sectionId');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ QR inválido: ${e.toString()}')));
      return;
    }

    setState(() => _isScanned = true);

    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString('userId');
    final token = prefs.getString('accessToken');

    if (studentId == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Error: No hay sesión activa.')),
      );
      Navigator.pop(context);
      return;
    }

    try {
      await _sectionService.enrollInSection(sectionId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Inscripción realizada correctamente.')),
      );
    } catch (e) {
      if (e.toString().contains(
        'student is already enrolled in this section',
      )) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ℹ️ Ya estabas inscrito en esta sección.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error: ${e.toString()}')));
        Navigator.pop(context);
        return;
      }
    }

    // ✅ Obtener classScheduleId
    late String classScheduleId;
    try {
      classScheduleId = await _sectionService.getClassScheduleIdFromSection(
        sectionId,
      );
      print('✅ classScheduleId obtenido: $classScheduleId');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al obtener classScheduleId: ${e.toString()}'),
        ),
      );
      Navigator.pop(context);
      return;
    }

    // ✅ Obtener datos de sección (para obtener el courseId y sectionName reales)
    late String courseId;
    late String sectionName;
    try {
      final sectionDetails = await _sectionService.getSectionDetails(sectionId);
      courseId = sectionDetails['courseId'] ?? '';
      sectionName = sectionDetails['name'] ?? '';
      print('✅ courseId: $courseId, sectionName: $sectionName');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ Error al obtener detalles de sección: ${e.toString()}',
          ),
        ),
      );
      Navigator.pop(context);
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceConfirmationPage(
          classScheduleId: classScheduleId,
          courseId: courseId, // ✅ Se pasa el courseId
          sectionName: sectionName, // ✅ Se pasa el sectionName real
        ),
      ),
    ).then((_) {
      setState(() => _isScanned = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear Código QR')),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: CameraFacing.back,
        ),
        onDetect: _onDetect,
      ),
    );
  }
}
