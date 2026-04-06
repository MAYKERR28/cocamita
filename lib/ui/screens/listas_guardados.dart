import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/servicio_pdf.dart';

class PantallaGuardados extends StatefulWidget {
  const PantallaGuardados({super.key});

  @override
  State<PantallaGuardados> createState() => _PantallaGuardadosState();
}

class _PantallaGuardadosState extends State<PantallaGuardados> {
  final Color verdeCoca = const Color(0xFF00796B);
  final Color rojoVino = const Color(0xFF7A1C1C);
  List<String> _rutasPdfs = [];

  @override
  void initState() {
    super.initState();
    _cargarPdfs();
  }

  Future<void> _cargarPdfs() async {
    final rutas = await ServicioPdf.obtenerRutas();
    setState(() {
      _rutasPdfs = rutas.reversed.toList();
    });
  }

  Future<void> _eliminar(String ruta) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Documento'),
        content: const Text('¿Estás seguro de eliminar este apunte?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: rojoVino, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Eliminar')
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await ServicioPdf.eliminarPdf(ruta);
      _cargarPdfs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apuntes Guardados', style: TextStyle(color: Colors.white)),
        backgroundColor: verdeCoca,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _rutasPdfs.isEmpty
          ? const Center(child: Text('No hay documentos guardados aún.'))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _rutasPdfs.length,
              itemBuilder: (context, index) {
                final ruta = _rutasPdfs[index];
                final nombreArchivo = ruta.split('/').last;

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 40),
                    title: Text(nombreArchivo.replaceAll('_', ' ').replaceAll('.pdf', ''), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Tocar para abrir'),
                    onTap: () => OpenFilex.open(ruta),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.blue),
                          onPressed: () => Share.shareXFiles([XFile(ruta)], text: 'Te comparto el apunte de CocaMita'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.grey),
                          onPressed: () => _eliminar(ruta),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}