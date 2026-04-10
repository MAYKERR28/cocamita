import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

class PantallaGuardados extends StatefulWidget {
  const PantallaGuardados({super.key});

  @override
  State<PantallaGuardados> createState() => _PantallaGuardadosState();
}

class _PantallaGuardadosState extends State<PantallaGuardados> {
  final Color verdeCoca = const Color(0xFF00796B);
  final Color rojoVino = const Color(0xFF7A1C1C);
  List<dynamic> _historial = [];

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('historial_resumenes');
    if (data != null) {
      List<dynamic> listaData = jsonDecode(data);
      setState(() {
      // Invertimos aquí para que el índice 0 sea el más reciente
      _historial = listaData.reversed.toList();
    });

    }
  }

  // Cálculos de la barra inferior
  int get todoG1 =>
      _historial.fold(0, (sum, item) => sum + (item['g1'] as int));
  int get todoG2 =>
      _historial.fold(0, (sum, item) => sum + (item['g2'] as int));
  int get todoTotal =>
      _historial.fold(0, (sum, item) => sum + (item['total'] as int));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Guardados',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: verdeCoca,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _historial.length,
              itemBuilder: (context, index) => _buildCard(_historial[index], index),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => OpenFilex.open(item['rutaPdf']),
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.red, size: 35),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "CocaMita ${item['fecha']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          "ID: ${item['id']}",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                        const Text(
                          "Tocar para abrir",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botón Compartir
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.blue, size: 20),
                    onPressed: () {
                      // Comparte el archivo PDF usando la ruta guardada
                      Share.shareXFiles([
                        XFile(item['rutaPdf']),
                      ], text: 'Lista de Cosecha ${item['fecha']}');
                    },
                  ),

                  // Botón Eliminar
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () =>
                        _confirmarEliminar(index), // Creamos esta función abajo
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Cant: ${item['cant']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                _resumenMini("Total G1:", "${item['g1']}", rojoVino),
                _resumenMini("Total G2:", "${item['g2']}", verdeCoca),
                _resumenMini("Total:", "${item['total']}", Colors.black),
              ],
            ),
          ),
        ],
      ),
    );
    
  }

  void _confirmarEliminar(int index) async {
  final confirmar = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('¿Eliminar registro?'),
      content: const Text('Esto quitará el resumen del historial (el archivo PDF seguirá en tu teléfono).'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCELAR')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('ELIMINAR', style: TextStyle(color: Colors.red))),
      ],
    )
  );

  if (confirmar == true) {
    setState(() {
      _historial.removeAt(index);
    });
    final prefs = await SharedPreferences.getInstance();
    // IMPORTANTE: Al guardar, invertimos de nuevo (.reversed) 
    // para que en el archivo de memoria el orden sea el correcto
    await prefs.setString('historial_resumenes', jsonEncode(_historial.reversed.toList()));
  }
}

  Widget _resumenMini(String label, String valor, Color color) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 12),
        children: [
          TextSpan(
            text: "$label ",
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: valor),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _footerText("Todo G1:", todoG1, rojoVino),
          _footerText("Todo G2:", todoG2, verdeCoca),
          _footerText("Todo Total:", todoTotal, Colors.black),
        ],
      ),
    );
  }

  Widget _footerText(String label, int valor, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Text(
          "$valor",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }
}
