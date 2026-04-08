import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

class PantallaVentasGuardados extends StatefulWidget {
  const PantallaVentasGuardados({super.key});

  @override
  State<PantallaVentasGuardados> createState() =>
      _PantallaVentasGuardadosState();
}

class _PantallaVentasGuardadosState extends State<PantallaVentasGuardados> {
  final Color verdeVenta = const Color(0xFF00796B);
  final Color rojoVenta = const Color(0xFF7A1C1C);
  List<dynamic> _historial = [];

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('historial_ventas');
    if (data != null) setState(() => _historial = jsonDecode(data));
  }

  // Sumas Generales
  int get cantGeneral =>
      _historial.fold(0, (sum, item) => sum + (item['cantidad'] as int));
  double get pesosGeneral => _historial.fold(
    0.0,
    (sum, item) => sum + (item['totalPesos'] as num).toDouble(),
  );
  double get arrobasGeneral => _historial.fold(
    0.0,
    (sum, item) => sum + (item['totalArrobas'] as num).toDouble(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ventas Guardadas"),
        backgroundColor: rojoVenta,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: _historial.length,
              itemBuilder: (context, index) =>
                  _buildCardVenta(_historial[index], index),
            ),
          ),
          _buildFooterGeneral(),
        ],
      ),
    );
  }

  Widget _buildCardVenta(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              if (item['rutaPdf'] != null) OpenFilex.open(item['rutaPdf']);
            },
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.red, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Venta ${item['fecha']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const Text(
                          "Tocar para abrir reporte",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // --- BOTÓN COMPARTIR ---
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.blue, size: 22),
                    onPressed: () async {
                      // 1. Verificamos que la ruta exista en los datos guardados
                      final String? ruta = item['rutaPdf'];

                      if (ruta != null && ruta.isNotEmpty) {
                        // 2. Verificamos si el archivo realmente existe en la memoria del celular
                        final archivo = File(ruta);
                        if (await archivo.exists()) {
                          // 3. Compartimos usando XFile
                          await Share.shareXFiles(
                            [XFile(ruta)], 
                            text: 'Reporte de Venta - ${item['fecha']}'
                          );
                        } else {
                          _mostrarMensaje("El archivo PDF ya no existe en la memoria.");
                        }
                      } else {
                        _mostrarMensaje("No se encontró la ruta del archivo.");
                      }
                    },
                  ),
                  // --- BOTÓN ELIMINAR ---
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 22,
                    ),
                    onPressed: () => _confirmarEliminarVenta(index),
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
                _datoMini("Cant:", "${item['cantidad']}"),
                _datoMini("Pesos:", "${item['totalPesos']}", c: verdeVenta),
                _datoMini(
                  "Arrobas:",
                  "${item['totalArrobas'].toStringAsFixed(1)}",
                  c: rojoVenta,
                ),
                _datoMini(
                  "Total S/.:",
                  "${item['totalDinero'].toStringAsFixed(0)}",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _datoMini(String l, String v, {Color? c}) => RichText(
    text: TextSpan(
      style: const TextStyle(color: Colors.black, fontSize: 12),
      children: [
        TextSpan(
          text: "$l ",
          style: TextStyle(
            color: c ?? Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(text: v),
      ],
    ),
  );

  Widget _buildFooterGeneral() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _footerDato("Cant. General", "$cantGeneral", Colors.black),
          _footerDato(
            "Pesos General",
            pesosGeneral.toStringAsFixed(1),
            verdeVenta,
          ),
          _footerDato(
            "Arrobas General",
            arrobasGeneral.toStringAsFixed(1),
            rojoVenta,
          ),
        ],
      ),
    );
  }

  Widget _footerDato(String l, String v, Color c) => Column(
    children: [
      Text(
        l,
        style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 11),
      ),
      Text(
        v,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ],
  );

  void _confirmarEliminarVenta(int index) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar esta venta?'),
        content: const Text(
          'Se borrará del historial. El archivo físico PDF no se eliminará del teléfono.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() {
        _historial.removeAt(index);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('historial_ventas', jsonEncode(_historial));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Registro eliminado")));
    }
  }

  void _mostrarMensaje(String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(mensaje), backgroundColor: Colors.redAccent)
  );
}
}
