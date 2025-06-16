import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrMatriculaScreen extends StatefulWidget {
  const QrMatriculaScreen({super.key});

  @override
  State<QrMatriculaScreen> createState() => _QrMatriculaScreenState();
}

class _QrMatriculaScreenState extends State<QrMatriculaScreen> {
  String? resultado;
  final MobileScannerController cameraController = MobileScannerController();

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear código QR')),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null && resultado == null) {
                    setState(() {
                      resultado = barcode.rawValue!;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Matrícula completada para: $resultado'),
                      ),
                    );
                    break;
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: resultado == null
                  ? const Text('Escanea un código QR')
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Resultado: $resultado'),
                        ElevatedButton(
                          onPressed: () {
                            setState(() => resultado = null);
                            cameraController.start();
                          },
                          child: const Text('Escanear nuevamente'),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
