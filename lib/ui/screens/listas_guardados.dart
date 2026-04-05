import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/servicio_imagenes.dart';

class PantallaGuardados extends StatefulWidget {
  const PantallaGuardados({super.key});

  @override
  State<PantallaGuardados> createState() => _PantallaGuardadosState();
}

class _PantallaGuardadosState extends State<PantallaGuardados> {
  final Color verdeCoca = const Color(0xFF00796B);
  List<String> _rutasImagenes = [];

  @override
  void initState() {
    super.initState();
    _cargarImagenes();
  }

  Future<void> _cargarImagenes() async {
    final rutas = await ServicioImagenes.obtenerRutas();
    setState(() {
      _rutasImagenes = rutas.reversed.toList(); // Mostrar las más recientes primero
    });
  }

  void _abrirVisor(int indexInicial) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _VisorImagenesCompleto(
          rutas: _rutasImagenes,
          indexInicial: indexInicial,
          alEliminar: _cargarImagenes, // Refresca la galería al volver
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardados', style: TextStyle(color: Colors.white)),
        backgroundColor: verdeCoca,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _rutasImagenes.isEmpty
          ? const Center(child: Text('No hay listas guardadas aún.'))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 columnas
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7, // Proporción de la miniatura (más alta que ancha)
              ),
              itemCount: _rutasImagenes.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _abrirVisor(index),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(_rutasImagenes[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// --- VISOR DE IMÁGENES A PANTALLA COMPLETA ---
class _VisorImagenesCompleto extends StatefulWidget {
  final List<String> rutas;
  final int indexInicial;
  final VoidCallback alEliminar;

  const _VisorImagenesCompleto({
    required this.rutas,
    required this.indexInicial,
    required this.alEliminar,
  });

  @override
  State<_VisorImagenesCompleto> createState() => _VisorImagenesCompletoState();
}

class _VisorImagenesCompletoState extends State<_VisorImagenesCompleto> {
  late PageController _pageController;
  late int _indexActual;
  final Color rojoVino = const Color(0xFF7A1C1C);

  @override
  void initState() {
    super.initState();
    _indexActual = widget.indexInicial;
    _pageController = PageController(initialPage: widget.indexInicial);
  }

  Future<void> _compartirImagen() async {
    final ruta = widget.rutas[_indexActual];
    await Share.shareXFiles([XFile(ruta)], text: 'Comparto mi lista de CocaMita');
  }

  Future<void> _confirmarEliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar lista'),
        content: const Text('¿Estás seguro de que deseas eliminar esta lista guardada?'),
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
      await ServicioImagenes.eliminarImagen(widget.rutas[_indexActual]);
      widget.alEliminar(); // Actualiza la pantalla anterior
      if (mounted) Navigator.pop(context); // Cierra el visor
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _compartirImagen),
          IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: _confirmarEliminar),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _indexActual = index),
        itemCount: widget.rutas.length,
        itemBuilder: (context, index) {
          // InteractiveViewer permite hacer zoom (pellizcar)
          return InteractiveViewer(
            child: Center(
              child: Image.file(File(widget.rutas[index]), fit: BoxFit.contain),
            ),
          );
        },
      ),
    );
  }
}