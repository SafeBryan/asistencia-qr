import 'package:flutter/material.dart';

class QrMatriculaScreen extends StatelessWidget {
  const QrMatriculaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matrícula por QR')),
      body: const Center(child: Text('Escanear código QR')),
    );
  }
}
