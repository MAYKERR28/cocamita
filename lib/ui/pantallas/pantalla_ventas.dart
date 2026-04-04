import 'package:flutter/material.dart';

class PantallaVentas extends StatelessWidget {
  const PantallaVentas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Ventas', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF7A1C1C), // rojoVino
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text(
          'Pantalla de Ventas en construcción',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}