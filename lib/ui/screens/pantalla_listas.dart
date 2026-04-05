import 'dart:typed_data';

import 'package:cocamita/constants/variables.dart';
import 'package:cocamita/models/cosechador_item.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
// Nuevas importaciones necesarias
import 'package:screenshot/screenshot.dart';
import '../../services/servicio_imagenes.dart';
import 'listas_guardados.dart';

// --- PANTALLA PRINCIPAL ---
class PantallaListas extends StatefulWidget {
  const PantallaListas({super.key});

  @override
  State<PantallaListas> createState() => _PantallaListasState();
}

class _PantallaListasState extends State<PantallaListas> {
  // Instancia del controlador de capturas
  final ScreenshotController _screenshotController = ScreenshotController();

  final TextEditingController _lugarCtrl = TextEditingController();
  final TextEditingController _grupo1Ctrl = TextEditingController();
  final TextEditingController _grupo2Ctrl = TextEditingController();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _peso1Ctrl = TextEditingController();

  final FocusNode _nombreFocusNode = FocusNode();
  final List<CosechadorItem> _lista = [];
  bool _isBloqueado = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosGuardados();
  }

  // --- PERSISTENCIA DE DATOS ---
  Future<void> _cargarDatosGuardados() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _lugarCtrl.text = prefs.getString('lista_lugar') ?? '';
      _grupo1Ctrl.text = prefs.getString('lista_g1') ?? '';
      _grupo2Ctrl.text = prefs.getString('lista_g2') ?? '';
    });

    final String? datosString = prefs.getString('lista_tabla');
    if (datosString != null) {
      final List<dynamic> jsonList = json.decode(datosString);
      setState(() {
        _lista.clear();
        for (var item in jsonList) {
          _lista.add(CosechadorItem.fromJson(item));
        }
      });
    }
  }

  Future<void> _guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lista_lugar', _lugarCtrl.text);
    await prefs.setString('lista_g1', _grupo1Ctrl.text);
    await prefs.setString('lista_g2', _grupo2Ctrl.text);

    final String datosCodificados = json.encode(
      _lista.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('lista_tabla', datosCodificados);
  }

  String _obtenerFechaActual() {
    final ahora = DateTime.now();
    final dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    final meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${dias[ahora.weekday - 1]}, ${ahora.day} de ${meses[ahora.month - 1]} del ${ahora.year}';
  }

  // --- NUEVA LÓGICA DE BOTONES ---

  void _limpiarTodo() {
    setState(() {
      _lugarCtrl.clear();
      _grupo1Ctrl.clear();
      _grupo2Ctrl.clear();
      _nombreCtrl.clear();
      _peso1Ctrl.clear();
      _lista.clear(); // Vaciamos la tabla
    });
    _guardarDatos(); // Sobrescribimos SharedPreferences con datos vacíos
  }

  Future<void> _mostrarDialogoGuardar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Obliga a tocar un botón
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Column(
          children: [
            Icon(Icons.warning_amber_rounded, size: 50, color: Colors.black),
            SizedBox(height: 10),
            Text('Ventana de advertencia', textAlign: TextAlign.center),
          ],
        ),
        content: const Text(
          '¡Recuerda que guardar se usa al terminar de apuntar en el día!',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: vinoSecundario,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, false), // Cancelar
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: verdePrimario,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true), // Aceptar
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      // 1. Capturar la imagen
      final Uint8List? bytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 10),
        pixelRatio: 2.0, // Mayor calidad
      );

      if (bytes != null) {
        // 2. Guardar usando nuestro servicio
        await ServicioImagenes.guardarImagen(bytes);

        // 3. Limpiar pantalla
        _limpiarTodo();

        // 4. Notificar éxito
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Datos guardados correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } else if (confirmar == false) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se guardaron los datos'),
            backgroundColor: vinoSecundario,
          ),
        );
      }
    }
  }

  void _anotar() {
    if (_nombreCtrl.text.trim().isNotEmpty &&
        _peso1Ctrl.text.trim().isNotEmpty) {
      setState(() {
        _lista.add(
          CosechadorItem(nombre: _nombreCtrl.text, p1: _peso1Ctrl.text),
        );
        _nombreCtrl.clear();
        _peso1Ctrl.clear();
      });

      _guardarDatos();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anotado correctamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
      FocusScope.of(context).requestFocus(_nombreFocusNode);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Llene Nombre y Peso 1'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int get _totalG1 =>
      _lista.where((i) => i.g1).fold(0, (sum, i) => sum + i.sTot);
  int get _totalG2 =>
      _lista.where((i) => i.g2).fold(0, (sum, i) => sum + i.sTot);
  int get _totalGeneral => _lista.fold(0, (sum, i) => sum + i.sTot);

  @override
  void dispose() {
    _lugarCtrl.dispose();
    _grupo1Ctrl.dispose();
    _grupo2Ctrl.dispose();
    _nombreCtrl.dispose();
    _peso1Ctrl.dispose();
    _nombreFocusNode.dispose();
    for (var item in _lista) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_note, color: Colors.white),
            SizedBox(width: 10),
            Text('Lista', style: TextStyle(color: Colors.white)),
          ],
        ),
        centerTitle: true,
        backgroundColor: verdePrimario,
        toolbarHeight: 80,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: vinoSecundario,
        onPressed: () => setState(() => _isBloqueado = !_isBloqueado),
        child: Icon(
          _isBloqueado ? Icons.lock : Icons.lock_open,
          color: Colors.white,
        ),
      ),

      body: IgnorePointer(
        ignoring: _isBloqueado,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              // 1. EL ÁREA QUE SE VA A CAPTURAR (El "Recibo")
              Screenshot(
                controller: _screenshotController,
                child: Container(
                  color: Colors
                      .white, // Fondo blanco obligatorio para evitar capturas negras
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Fecha: ',
                            style: TextStyle(
                              color: verdePrimario,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _obtenerFechaActual(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Lugar: ',
                            style: TextStyle(
                              color: verdePrimario,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Expanded(
                            child: _inputBasico(
                              _lugarCtrl,
                              TextInputAction.next,
                              capitalizar: true,
                              onChanged: (_) => _guardarDatos(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Grupo1: ',
                            style: TextStyle(
                              color: vinoSecundario,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Expanded(
                            child: _inputBasico(
                              _grupo1Ctrl,
                              TextInputAction.done,
                              capitalizar: true,
                              onChanged: (_) => _guardarDatos(),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'G2: ',
                            style: TextStyle(
                              color: verdePrimario,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Expanded(
                            child: _inputBasico(
                              _grupo2Ctrl,
                              TextInputAction.done,
                              capitalizar: true,
                              onChanged: (_) => _guardarDatos(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Anotar cosechadores',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nombre:',
                                  style: TextStyle(
                                    color: vinoSecundario,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                _inputBasico(
                                  _nombreCtrl,
                                  TextInputAction.next,
                                  focusNode: _nombreFocusNode,
                                  capitalizar: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Peso 1:',
                                  style: TextStyle(
                                    color: vinoSecundario,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                _inputBasico(
                                  _peso1Ctrl,
                                  TextInputAction.done,
                                  esNumero: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton(
                            onPressed: _isBloqueado ? null : _anotar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: vinoSecundario,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                            ),
                            child: const Text('Anotar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: verdePrimario),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Table(
                              columnWidths: const {
                                0: FixedColumnWidth(40), // G1
                                1: FixedColumnWidth(40), // G2
                                2: FixedColumnWidth(110), // Nombres
                                3: FixedColumnWidth(45), // P1
                                4: FixedColumnWidth(45), // P2
                                5: FixedColumnWidth(45), // P3
                                6: FixedColumnWidth(45), // P4
                                7: FixedColumnWidth(55), // sTot
                              },
                              border: TableBorder.all(
                                color: verdePrimario,
                                width: 0.5,
                              ),
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFc2e5c8),
                                  ),
                                  children: [
                                    _celdaHeader('G1'),
                                    _celdaHeader('G2'),
                                    _celdaHeader('Nombres'),
                                    _celdaHeader('P1'),
                                    _celdaHeader('P2'),
                                    _celdaHeader('P3'),
                                    _celdaHeader('P4'),
                                    _celdaHeader('sTot'),
                                  ],
                                ),
                                ..._lista.map(
                                  (item) => TableRow(
                                    children: [
                                      _celdaCheck(item.g1, vinoSecundario, (
                                        val,
                                      ) {
                                        setState(() => item.g1 = val!);
                                        _guardarDatos();
                                      }),
                                      _celdaCheck(item.g2, verdePrimario, (
                                        val,
                                      ) {
                                        setState(() => item.g2 = val!);
                                        _guardarDatos();
                                      }),
                                      _celdaInput(
                                        item.nombreCtrl,
                                        false,
                                        item,
                                        capitalizar: true,
                                        alineacion: TextAlign.left,
                                      ),
                                      _celdaInput(item.p1Ctrl, true, item),
                                      _celdaInput(item.p2Ctrl, true, item),
                                      _celdaInput(item.p3Ctrl, true, item),
                                      _celdaInput(item.p4Ctrl, true, item),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          item.sTot.toString(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // --- SECCIÓN DE TOTALES ACTUALIZADA ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: "PoppinsFonts",
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Cant: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: '${_lista.length}',
                                ), // Contador automático
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: "PoppinsFonts",
                              ),
                              children: [
                                TextSpan(
                                  text: 'Total G1: ',
                                  style: TextStyle(
                                    color: vinoSecundario,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(text: '$_totalG1'),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: "PoppinsFonts",
                              ),
                              children: [
                                TextSpan(
                                  text: 'Total G2: ',
                                  style: TextStyle(
                                    color: verdePrimario,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(text: '$_totalG2'),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: "PoppinsFonts",
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Total: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: '$_totalGeneral'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Botones fuera del Screenshot para evitar que se capturen
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: _isBloqueado ? null : () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaGuardados()));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: verdePrimario,
                      side: BorderSide(color: verdePrimario),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text('Guardados'),
                  ),
                  ElevatedButton(
                    onPressed: _isBloqueado ? null : _mostrarDialogoGuardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: verdePrimario,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text('Guardar'),
                  ),
                ],
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---
  Widget _inputBasico(
    TextEditingController ctrl,
    TextInputAction accion, {
    bool esNumero = false,
    FocusNode? focusNode,
    bool capitalizar = false,
    ValueChanged<String>? onChanged,
  }) {
    return SizedBox(
      height: 35,
      child: TextField(
        controller: ctrl,
        focusNode: focusNode,
        keyboardType: esNumero ? TextInputType.number : TextInputType.text,
        textInputAction: accion,
        textCapitalization: capitalizar
            ? TextCapitalization.words
            : TextCapitalization.none,
        enabled: !_isBloqueado,
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 2,
            vertical: 0,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        ),
      ),
    );
  }

  Widget _celdaHeader(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _celdaInput(
    TextEditingController ctrl,
    bool esNumero,
    CosechadorItem item, {
    bool capitalizar = false,
    TextAlign alineacion = TextAlign.center,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: esNumero ? TextInputType.number : TextInputType.text,
      textCapitalization: capitalizar
          ? TextCapitalization.words
          : TextCapitalization.none,
      enabled: !_isBloqueado,
      textAlign: alineacion,
      onChanged: (val) {
        setState(() {});
        _guardarDatos();
      },
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 2),
      ),
    );
  }

  Widget _celdaCheck(bool valor, Color color, ValueChanged<bool?> onChanged) {
    return Checkbox(
      value: valor,
      activeColor: color,
      onChanged: _isBloqueado ? null : onChanged,
    );
  }
}
