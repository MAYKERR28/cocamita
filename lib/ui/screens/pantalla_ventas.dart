import 'package:flutter/material.dart';

class PantallaVentas extends StatelessWidget {
  const PantallaVentas({super.key});

  final Color rojoVino = const Color(0xFF7A1C1C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas', style: TextStyle(color: Colors.white)),
        backgroundColor: rojoVino,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text('Pantalla de Ventas en construcción...'),
      ),
    );
  }
}