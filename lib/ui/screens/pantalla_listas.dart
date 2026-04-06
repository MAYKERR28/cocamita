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

  // --- LÓGICA DE DATOS ---
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
      // --- NUEVA FUNCIONALIDAD: Ocultar teclado y Notificación ---
      FocusScope.of(context).unfocus(); 
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Anotado correctamente'),
          backgroundColor: verdeCoca,
          duration: const Duration(seconds: 2),
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

  // --- CÁLCULOS ---
  int _calcularTotalG1() =>
      _lista.where((e) => e.g1).fold(0, (sum, item) => sum + item.sTot);
  int _calcularTotalG2() =>
      _lista.where((e) => e.g2).fold(0, (sum, item) => sum + item.sTot);

  // --- DISEÑO DE INPUTS ---
  InputDecoration _outlineInput(String label, IconData icono, Color color) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icono, color: color),
      labelStyle: TextStyle(color: color),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.all(8),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos el gran total absoluto sumando todo lo que hay en la tabla
    int granTotalCalculado = _lista.fold(0, (sum, item) => sum + item.sTot);
    int totalG1 = _calcularTotalG1();
    int totalG2 = _calcularTotalG2();

    

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: verdeCoca,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 20),

            TextField(
              controller: _lugarCtrl,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: _outlineInput(
                'Lugar de cosecha',
                Icons.location_on,
                verdeCoca,
              ),
              onChanged: (v) => _guardarDatos(),
            ),
            const SizedBox(height: 15),
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

            const Divider(height: 30),
            const Text(
              'Anotar cosechadores:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller: _nombreNuevoCtrl,
                    decoration: _outlineInput(
                      'Nombre',
                      Icons.person_add,
                      Colors.black54,
                    ),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _pesoNuevoCtrl,
                    decoration: _outlineInput(
                      'Peso 1',
                      Icons.scale,
                      Colors.black54,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 6),
                
                
                IconButton.filled(                  
                  onPressed: _agregarCosechador,
                  style: IconButton.styleFrom(
                    backgroundColor: rojoVino,
                    padding: const EdgeInsets.all(12),
                    ),
                  
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // --- TABLA ---
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                border: Border.all(color: verdeCoca),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Table(
                border: TableBorder.all(color: verdeCoca.withOpacity(0.2)),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(3.5),
                  3: FlexColumnWidth(1.6),
                  4: FlexColumnWidth(1.6),
                  5: FlexColumnWidth(1.6),
                  6: FlexColumnWidth(1.6),
                  7: FlexColumnWidth(1.6),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: verdeCoca.withOpacity(0.1),
                    ),
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
                        _checkCelda(
                          item.g1,
                          rojoVino,
                          (v) => setState(() {
                            item.g1 = v!;
                            _guardarDatos();
                          }),
                        ),
                        _checkCelda(
                          item.g2,
                          verdeCoca,
                          (v) => setState(() {
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
                          padding: const EdgeInsets.symmetric(vertical: 8),
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
            ),

            const SizedBox(height: 25),

            // --- SECCIÓN DE TOTALES ---
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ResumenDato("Cant:", "${_lista.length}", Colors.black),
                      _ResumenDato("Total G1:", "$totalG1", rojoVino),
                      _ResumenDato("Total G2:", "$totalG2", verdeCoca),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Totalizado: ",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "$granTotalCalculado",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- BOTONES DE ACCIÓN ---
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: verdeCoca),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PantallaGuardados(),
                      ),
                    ),
                    icon: Icon(Icons.folder, color: verdeCoca),
                    label: Text(
                      "Guardados",
                      style: TextStyle(
                        color: verdeCoca,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: rojoVino,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _mostrarConfirmacion(totalG1, totalG2),
                    icon: const Icon(Icons.save),
                    label: const Text(
                      "Guardar",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- COMPONENTES INTERNOS ---
  void _mostrarConfirmacion(int g1, int g2) async {

    // Calculamos el Gran Total absoluto sumando todos los 'sTot' de la lista
  final int granTotalReal = _lista.fold(0, (sum, item) => sum + item.sTot);

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Finalizar apunte?'),
        content: const Text(
          'Se guardará la lista y se limpiará la lista actual.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, Guardar'),
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
        granTotal: granTotalReal,
      );
      if (ruta != null) {
        _limpiarTodo();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Apunte guardado con éxito")));
      }
    }
  }

  Widget _ResumenDato(String label, String valor, Color color) {
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

  Widget _checkCelda(bool val, Color col, Function(bool?) onCh) =>
      Checkbox(value: val, activeColor: col, onChanged: onCh);

  Widget _inputTabla(TextEditingController ctrl, bool num, TextAlign ali) {
    return TextField(
      controller: ctrl,
      keyboardType: num ? TextInputType.number : TextInputType.text,
      textAlign: ali,
      style: const TextStyle(fontSize: 13),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(8),
      ),
      onChanged: (v) {
        setState(() {});
        _guardarDatos();
      },
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
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
