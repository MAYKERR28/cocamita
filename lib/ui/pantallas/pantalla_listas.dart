import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// --- MODELO PARA CADA FILA DE LA TABLA ---
class CosechadorItem {
  TextEditingController nombreCtrl;
  TextEditingController p1Ctrl;
  TextEditingController p2Ctrl;
  TextEditingController p3Ctrl;
  TextEditingController p4Ctrl;
  // Se eliminó p5Ctrl
  bool g1;
  bool g2;

  CosechadorItem({
    required String nombre,
    required String p1,
  })  : nombreCtrl = TextEditingController(text: nombre),
        p1Ctrl = TextEditingController(text: p1),
        p2Ctrl = TextEditingController(),
        p3Ctrl = TextEditingController(),
        p4Ctrl = TextEditingController(),
        g1 = false,
        g2 = false;

  int get sTot {
    int val(TextEditingController c) => int.tryParse(c.text) ?? 0;
    return val(p1Ctrl) + val(p2Ctrl) + val(p3Ctrl) + val(p4Ctrl); // Se eliminó p5
  }

  void dispose() {
    nombreCtrl.dispose();
    p1Ctrl.dispose();
    p2Ctrl.dispose();
    p3Ctrl.dispose();
    p4Ctrl.dispose();
  }

  // Convertir a JSON para guardar
  Map<String, dynamic> toJson() => {
        'nombre': nombreCtrl.text,
        'p1': p1Ctrl.text,
        'p2': p2Ctrl.text,
        'p3': p3Ctrl.text,
        'p4': p4Ctrl.text,
        'g1': g1,
        'g2': g2,
      };

  // Crear desde JSON al cargar
  factory CosechadorItem.fromJson(Map<String, dynamic> json) {
    final item = CosechadorItem(nombre: json['nombre'] ?? '', p1: json['p1'] ?? '');
    item.p2Ctrl.text = json['p2'] ?? '';
    item.p3Ctrl.text = json['p3'] ?? '';
    item.p4Ctrl.text = json['p4'] ?? '';
    item.g1 = json['g1'] ?? false;
    item.g2 = json['g2'] ?? false;
    return item;
  }
}

// --- PANTALLA PRINCIPAL ---
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

    final String datosCodificados = json.encode(_lista.map((e) => e.toJson()).toList());
    await prefs.setString('lista_tabla', datosCodificados);
  }

  String _obtenerFechaActual() {
    final ahora = DateTime.now();
    final dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final meses = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    return '${dias[ahora.weekday - 1]}, ${ahora.day} de ${meses[ahora.month - 1]} del ${ahora.year}';
  }

  void _anotar() {
    if (_nombreCtrl.text.trim().isNotEmpty && _peso1Ctrl.text.trim().isNotEmpty) {
      setState(() {
        _lista.add(CosechadorItem(
          nombre: _nombreCtrl.text,
          p1: _peso1Ctrl.text,
        ));
        _nombreCtrl.clear();
        _peso1Ctrl.clear();
      });
      
      _guardarDatos();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anotado correctamente'), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
      );
      FocusScope.of(context).requestFocus(_nombreFocusNode);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Llene Nombre y Peso 1'), backgroundColor: Colors.red),
      );
    }
  }

  int get _totalG1 => _lista.where((i) => i.g1).fold(0, (sum, i) => sum + i.sTot);
  int get _totalG2 => _lista.where((i) => i.g2).fold(0, (sum, i) => sum + i.sTot);
  int get _totalGeneral => _lista.fold(0, (sum, i) => sum + i.sTot);

  @override
  void dispose() {
    _lugarCtrl.dispose();
    _grupo1Ctrl.dispose();
    _grupo2Ctrl.dispose();
    _nombreCtrl.dispose();
    _peso1Ctrl.dispose();
    _nombreFocusNode.dispose();
    for (var item in _lista) { item.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(Icons.edit_note, color: Colors.white), SizedBox(width: 10), Text('Lista', style: TextStyle(color: Colors.white))],
        ),
        centerTitle: true,
        backgroundColor: verdeCoca,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: verdeCoca,
        onPressed: () => setState(() => _isBloqueado = !_isBloqueado),
        child: Icon(_isBloqueado ? Icons.lock : Icons.lock_open, color: Colors.white),
      ),

      body: IgnorePointer(
        ignoring: _isBloqueado,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Fecha: ', style: TextStyle(color: verdeCoca, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(_obtenerFechaActual(), style: const TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Lugar: ', style: TextStyle(color: verdeCoca, fontWeight: FontWeight.bold, fontSize: 16)),
                  Expanded(child: _inputBasico(_lugarCtrl, TextInputAction.next, capitalizar: true, onChanged: (_) => _guardarDatos())),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Grupo1: ', style: TextStyle(color: rojoVino, fontWeight: FontWeight.bold, fontSize: 16)),
                  Expanded(child: _inputBasico(_grupo1Ctrl, TextInputAction.done, capitalizar: true, onChanged: (_) => _guardarDatos())),
                  const SizedBox(width: 10),
                  Text('Grupo2: ', style: TextStyle(color: verdeCoca, fontWeight: FontWeight.bold, fontSize: 16)),
                  Expanded(child: _inputBasico(_grupo2Ctrl, TextInputAction.done, capitalizar: true, onChanged: (_) => _guardarDatos())),
                ],
              ),
              const SizedBox(height: 20),

              const Text('Anotar cosechadores', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nombre:', style: TextStyle(color: rojoVino, fontWeight: FontWeight.bold)),
                        _inputBasico(_nombreCtrl, TextInputAction.next, focusNode: _nombreFocusNode, capitalizar: true),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Peso 1:', style: TextStyle(color: rojoVino, fontWeight: FontWeight.bold)),
                        _inputBasico(_peso1Ctrl, TextInputAction.done, esNumero: true),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isBloqueado ? null : _anotar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: rojoVino,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    child: const Text('Anotar'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(border: Border.all(color: verdeCoca), borderRadius: BorderRadius.circular(10)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      columnWidths: const {
                        0: FixedColumnWidth(40),  // G1
                        1: FixedColumnWidth(40),  // G2
                        2: FixedColumnWidth(110), // Nombres
                        3: FixedColumnWidth(45),  // P1
                        4: FixedColumnWidth(45),  // P2
                        5: FixedColumnWidth(45),  // P3
                        6: FixedColumnWidth(45),  // P4
                        7: FixedColumnWidth(55),  // sTot
                      },
                      border: TableBorder.all(color: verdeCoca, width: 0.5),
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey.shade100),
                          children: [
                            _celdaHeader('G1'), _celdaHeader('G2'), _celdaHeader('Nombres'), 
                            _celdaHeader('P1'), _celdaHeader('P2'), _celdaHeader('P3'),
                            _celdaHeader('P4'), _celdaHeader('sTot'),
                          ],
                        ),
                        ..._lista.map((item) => TableRow(
                          children: [
                            _celdaCheck(item.g1, rojoVino, (val) { setState(() => item.g1 = val!); _guardarDatos(); }),
                            _celdaCheck(item.g2, verdeCoca, (val) { setState(() => item.g2 = val!); _guardarDatos(); }),
                            _celdaInput(item.nombreCtrl, false, item, capitalizar: true, alineacion: TextAlign.left),
                            _celdaInput(item.p1Ctrl, true, item),
                            _celdaInput(item.p2Ctrl, true, item),
                            _celdaInput(item.p3Ctrl, true, item),
                            _celdaInput(item.p4Ctrl, true, item),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(item.sTot.toString(), textAlign: TextAlign.center,
                              style:const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- SECCIÓN DE TOTALES ACTUALIZADA ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  RichText(text: TextSpan(style: const TextStyle(color: Colors.black, fontSize: 15), children: [
                    const TextSpan(text: 'Cant: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: '${_lista.length}'), // Contador automático
                  ])),
                  RichText(text: TextSpan(style: const TextStyle(color: Colors.black, fontSize: 15), children: [
                    TextSpan(text: 'Total G1: ', style: TextStyle(color: rojoVino, fontWeight: FontWeight.bold)),
                    TextSpan(text: '$_totalG1'),
                  ])),
                  RichText(text: TextSpan(style: const TextStyle(color: Colors.black, fontSize: 15), children: [
                    TextSpan(text: 'Total G2: ', style: TextStyle(color: verdeCoca, fontWeight: FontWeight.bold)),
                    TextSpan(text: '$_totalG2'),
                  ])),
                  RichText(text: TextSpan(style: const TextStyle(color: Colors.black, fontSize: 15), children: [
                    const TextSpan(text: 'Total: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: '$_totalGeneral'),
                  ])),
                ],
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: _isBloqueado ? null : () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: verdeCoca,
                      side: BorderSide(color: verdeCoca),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: const Text('Guardados'),
                  ),
                  ElevatedButton(
                    onPressed: _isBloqueado ? null : () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: rojoVino,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
  Widget _inputBasico(TextEditingController ctrl, TextInputAction accion, {bool esNumero = false, FocusNode? focusNode, bool capitalizar = false, ValueChanged<String>? onChanged}) {
    return SizedBox(
      height: 35,
      child: TextField(
        controller: ctrl,
        focusNode: focusNode,
        keyboardType: esNumero ? TextInputType.number : TextInputType.text,
        textInputAction: accion,
        textCapitalization: capitalizar ? TextCapitalization.words : TextCapitalization.none,
        enabled: !_isBloqueado,
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        ),
      ),
    );
  }

  Widget _celdaHeader(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(texto, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _celdaInput(TextEditingController ctrl, bool esNumero, CosechadorItem item, {bool capitalizar = false, TextAlign alineacion = TextAlign.center}) {
    return TextField(
      controller: ctrl,
      keyboardType: esNumero ? TextInputType.number : TextInputType.text,
      textCapitalization: capitalizar ? TextCapitalization.words : TextCapitalization.none,
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