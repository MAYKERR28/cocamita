import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/cosechador_item.dart';
import '../../services/servicio_pdf.dart';
import 'listas_guardados.dart';

class PantallaListas extends StatefulWidget {
  const PantallaListas({super.key});

  @override
  State<PantallaListas> createState() => _PantallaListasState();
}

class _PantallaListasState extends State<PantallaListas> {
  final Color verdeCoca = const Color(0xFF00796B);
  final Color rojoVino = const Color(0xFF7A1C1C);

  final TextEditingController _lugarCtrl = TextEditingController();
  final TextEditingController _grupo1Ctrl = TextEditingController();
  final TextEditingController _grupo2Ctrl = TextEditingController();
  final TextEditingController _nombreNuevoCtrl = TextEditingController();
  final TextEditingController _pesoNuevoCtrl = TextEditingController();

  String _fechaActual = "";
  List<CosechadorItem> _lista = [];

  @override
  void initState() {
    super.initState();
    _inicializarFecha();
    _cargarDatos();
  }

  void _inicializarFecha() {
    var ahora = DateTime.now();
    var formato = DateFormat("EEEE, d 'de' MMMM 'de' y", 'es_ES').format(ahora);
    setState(() {
      _fechaActual = formato[0].toUpperCase() + formato.substring(1);
    });
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lugarCtrl.text = prefs.getString('lugar') ?? '';
      _grupo1Ctrl.text = prefs.getString('grupo1') ?? '';
      _grupo2Ctrl.text = prefs.getString('grupo2') ?? '';
      final String? listaStr = prefs.getString('lista_cosechadores');
      if (listaStr != null) {
        final List<dynamic> decodificado = jsonDecode(listaStr);
        _lista = decodificado
            .map((item) => CosechadorItem.fromJson(item))
            .toList();
      }
    });
  }

  Future<void> _guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lugar', _lugarCtrl.text);
    await prefs.setString('grupo1', _grupo1Ctrl.text);
    await prefs.setString('grupo2', _grupo2Ctrl.text);
    final listaMapeada = _lista.map((e) => e.toJson()).toList();
    await prefs.setString('lista_cosechadores', jsonEncode(listaMapeada));
  }

  void _agregarCosechador() {
    if (_nombreNuevoCtrl.text.isNotEmpty) {
      setState(() {
        _lista.add(
          CosechadorItem(
            nombre: _nombreNuevoCtrl.text,
            p1: _pesoNuevoCtrl.text,
          ),
        );
        _nombreNuevoCtrl.clear();
        _pesoNuevoCtrl.clear();
      });
      _guardarDatos();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Anotado correctamente'),
          backgroundColor: verdeCoca,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _limpiarTodo() {
    setState(() {
      _lugarCtrl.clear();
      _grupo1Ctrl.clear();
      _grupo2Ctrl.clear();
      _lista.clear();
    });
    _guardarDatos();
  }

  int _calcularTotalG1() =>
      _lista.where((e) => e.g1).fold(0, (sum, item) => sum + item.sTot);
  int _calcularTotalG2() =>
      _lista.where((e) => e.g2).fold(0, (sum, item) => sum + item.sTot);

  @override
  Widget build(BuildContext context) {
    int totalG1 = _calcularTotalG1();
    int totalG2 = _calcularTotalG2();
    int granTotalCalculado = _lista.fold(0, (sum, item) => sum + item.sTot);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listas', style: TextStyle(color: Colors.white)),
        backgroundColor: verdeCoca,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Text(
                _fechaActual,
                style: TextStyle(
                  color: verdeCoca,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _lugarCtrl,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: _outlineInput('Lugar', Icons.location_on, verdeCoca),
              onChanged: (v) => _guardarDatos(),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _grupo1Ctrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: _outlineInput('Grupo 1', Icons.group, rojoVino),
                    onChanged: (v) => _guardarDatos(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _grupo2Ctrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: _outlineInput(
                      'Grupo 2',
                      Icons.group,
                      verdeCoca,
                    ),
                    onChanged: (v) => _guardarDatos(),
                  ),
                ),
              ],
            ),
            const Divider(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Anotar cosechador',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _nombreNuevoCtrl,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: _outlineInput(
                      'Nombre',
                      Icons.person_add,
                      Colors.black54,
                    ),
                  ),
                ),

                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _pesoNuevoCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _outlineInput(
                      'Peso 1',
                      Icons.scale,
                      Colors.black54,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: IconButton.filled(
                    onPressed: _agregarCosechador,

                    style: IconButton.styleFrom(backgroundColor: rojoVino),

                    icon: const Text( "Anotar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            _buildTabla(),
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _resumenDato("Cant:", "${_lista.length}", Colors.black),
                      _resumenDato("Tot G1:", "$totalG1", rojoVino),
                      _resumenDato("Tot G2:", "$totalG2", verdeCoca),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Gran Total: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "$granTotalCalculado",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _buildBotonGuardar(totalG1, totalG2, granTotalCalculado),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonGuardar(int g1, int g2, int total) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PantallaGuardados(),
              ),
            ),
            icon: const Icon(Icons.folder_open), // Icono de carpeta
            label: const Text("GUARDADOS"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              side: BorderSide(color: verdeCoca),
              foregroundColor: verdeCoca,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Botón GUARDAR (Antiguo Guardar Día)
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _mostrarConfirmacion(g1, g2, total),
            icon: const Icon(Icons.save), // Icono de guardar
            label: const Text("GUARDAR"),
            style: ElevatedButton.styleFrom(
              backgroundColor: rojoVino,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              elevation: 3,
            ),
          ),
        ),
      ],
    );
  }

  void _mostrarConfirmacion(int g1, int g2, int granTotal) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Finalizar día?'),
        content: const Text(
          'Se guardará en el historial y se generará el PDF.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('NO'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('SÍ'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final ruta = await ServicioPdf.generarYGuardarPDF(
        fecha: _fechaActual,
        lugar: _lugarCtrl.text,
        grupo1: _grupo1Ctrl.text,
        grupo2: _grupo2Ctrl.text,
        lista: _lista,
        totalG1: g1,
        totalG2: g2,
        granTotal: granTotal,
      );

      if (ruta != null) {
        final prefs = await SharedPreferences.getInstance();
        final String? historialPrevio = prefs.getString('historial_resumenes');
        List<dynamic> historial = historialPrevio != null
            ? jsonDecode(historialPrevio)
            : [];

        historial.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'fecha': _fechaActual,
          'cant': _lista.length,
          'g1': g1,
          'g2': g2,
          'total': granTotal,
          'rutaPdf': ruta,
        });

        await prefs.setString('historial_resumenes', jsonEncode(historial));
        _limpiarTodo();
      }
    }
  }

  InputDecoration _outlineInput(String label, IconData icono, Color color) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icono, color: color),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.all(12),
    );
  }

  Widget _buildTabla() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: verdeCoca),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(10),
          1: FlexColumnWidth(10),
          2: FlexColumnWidth(35),
          3: FlexColumnWidth(16),
          4: FlexColumnWidth(16),
          5: FlexColumnWidth(16),
          6: FlexColumnWidth(16),
          7: FlexColumnWidth(20),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: verdeCoca.withOpacity(0.1)),
            children: const [
              _HeaderCelda('G1'),
              _HeaderCelda('G2'),
              _HeaderCelda('Nombre'),
              _HeaderCelda('P1'),
              _HeaderCelda('P2'),
              _HeaderCelda('P3'),
              _HeaderCelda('P4'),
              _HeaderCelda('Tot'),
            ],
          ),
          ..._lista.map(
            (item) => TableRow(
              children: [
                Checkbox(
                  value: item.g1,
                  activeColor: rojoVino,
                  onChanged: (v) => setState(() {
                    item.g1 = v!;
                    _guardarDatos();
                  }),
                ),
                Checkbox(
                  value: item.g2,
                  activeColor: verdeCoca,
                  onChanged: (v) => setState(() {
                    item.g2 = v!;
                    _guardarDatos();
                  }),
                ),
                _inputTabla(item.nombreCtrl, false, TextAlign.left),
                _inputTabla(item.p1Ctrl, true, TextAlign.center),
                _inputTabla(item.p2Ctrl, true, TextAlign.center),
                _inputTabla(item.p3Ctrl, true, TextAlign.center),
                _inputTabla(item.p4Ctrl, true, TextAlign.center),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    item.sTot.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputTabla(TextEditingController ctrl, bool num, TextAlign ali) {
    return TextField(
      controller: ctrl,
      keyboardType: num ? TextInputType.number : TextInputType.text,
      textAlign: ali,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true, // Hace el campo más compacto
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 2),
      ),
      onChanged: (v) {
        setState(() {});
        _guardarDatos();
      },
    );
  }

  Widget _resumenDato(String label, String valor, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          valor,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _HeaderCelda extends StatelessWidget {
  final String texto;
  const _HeaderCelda(this.texto);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        texto,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}
