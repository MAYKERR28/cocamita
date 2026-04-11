import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ventas_guardados.dart';
import '../../services/servicio_pdf_ventas.dart';

class PantallaVentas extends StatefulWidget {
  const PantallaVentas({super.key});

  @override
  State<PantallaVentas> createState() => _PantallaVentasState();
}

class _PantallaVentasState extends State<PantallaVentas> {
  // Colores del diseño
  final Color verdeVenta = const Color(0xFF00796B);
  final Color rojoVenta = const Color(0xFF7A1C1C);

  // Controladores principales
  final _lugarCtrl = TextEditingController();
  final _vendedorCtrl = TextEditingController();
  final _compradorCtrl = TextEditingController();
  final _pesoInputCtrl = TextEditingController();
  final _arrobaValorCtrl = TextEditingController(text: "25");
  final _precioCtrl = TextEditingController();

  // Lista de controladores para que la tabla sea editable
  List<TextEditingController> _controlesPesos = [];
  String _fechaActual = "";

  @override
  void initState() {
    super.initState();
    String fecha = DateFormat(
      "EEEE d 'de' MMMM 'del' y",
      'es_ES',
    ).format(DateTime.now());

    // Convertimos la primera letra a Mayúscula
    _fechaActual = _capitalizarTexto(fecha);
    _cargarDatosTemporales(); // Cargar datos si se cerró la app
  }

  String _capitalizarTexto(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1);
  }

  // --- PERSISTENCIA (DATOS TEMPORALES) ---

  Future<void> _guardarDatosTemporales() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('temp_lugar', _lugarCtrl.text);
    await prefs.setString('temp_vendedor', _vendedorCtrl.text);
    await prefs.setString('temp_comprador', _compradorCtrl.text);
    await prefs.setString('temp_arroba', _arrobaValorCtrl.text);
    await prefs.setString('temp_precio', _precioCtrl.text);

    List<String> listaString = _controlesPesos.map((c) => c.text).toList();
    await prefs.setStringList('temp_pesos', listaString);
  }

  Future<void> _cargarDatosTemporales() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lugarCtrl.text = prefs.getString('temp_lugar') ?? '';
      _vendedorCtrl.text = prefs.getString('temp_vendedor') ?? '';
      _compradorCtrl.text = prefs.getString('temp_comprador') ?? '';
      _arrobaValorCtrl.text = prefs.getString('temp_arroba') ?? '25';
      _precioCtrl.text = prefs.getString('temp_precio') ?? '';

      List<String>? listaGuardada = prefs.getStringList('temp_pesos');
      if (listaGuardada != null) {
        _controlesPesos = listaGuardada
            .map((p) => TextEditingController(text: p))
            .toList();
      }
    });
  }

  // --- LÓGICA MATEMÁTICA ---

  double get totalPesos =>
      _controlesPesos.fold(0, (sum, c) => sum + (double.tryParse(c.text) ?? 0));

  double get totalArrobas {
    double arroba = double.tryParse(_arrobaValorCtrl.text) ?? 1;
    return arroba > 0 ? totalPesos / arroba : 0;
  }

  double get totalDinero {
    double precio = double.tryParse(_precioCtrl.text) ?? 0;
    return totalArrobas * precio;
  }

  void _anotarPeso() {
    if (_pesoInputCtrl.text.isNotEmpty) {
      // Guardamos el valor para mostrarlo en el mensaje
      String pesoAnotado = _pesoInputCtrl.text;

      setState(() {
        _controlesPesos.insert(0, TextEditingController(text: pesoAnotado));
        _pesoInputCtrl.clear();
      });
      _guardarDatosTemporales();
      FocusScope.of(context).unfocus(); // Ocultar teclado

      // --- NUEVA NOTIFICACIÓN ---
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Peso $pesoAnotado agregado correctamente"),
          backgroundColor: verdeVenta, // Usamos el color verde de tu diseño
          duration: const Duration(seconds: 2), // Se quita solo en 2 segundos
          behavior:
              SnackBarBehavior.floating, // Hace que flote sobre los botones
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      // Opcional: Notificación si intentan anotar vacío
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, ingrese un peso primero"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // --- GUARDADO FINAL Y PDF ---

  void _confirmarGuardar() async {
    if (_controlesPesos.isEmpty) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Guardar Venta?"),
        content: const Text(
          "Se generará un archivo PDF y se limpiará la pantalla.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sí, Aceptar"),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      // 1. Generar PDF y obtener ruta
      String? ruta = await ServicioPdfVentas.generarPDF(
        fecha: _fechaActual,
        lugar: _lugarCtrl.text,
        vendedor: _vendedorCtrl.text,
        comprador: _compradorCtrl.text,
        pesos: _controlesPesos
            .map((c) => double.tryParse(c.text) ?? 0)
            .toList(),
        totalPesos: totalPesos,
        arroba: double.tryParse(_arrobaValorCtrl.text) ?? 25,
        totalArrobas: totalArrobas,
        precio: double.tryParse(_precioCtrl.text) ?? 0,
        totalDinero: totalDinero,
      );

      if (ruta != null) {
        // 2. Guardar en Historial
        final prefs = await SharedPreferences.getInstance();
        final String? data = prefs.getString('historial_ventas');
        List<dynamic> historial = data != null ? jsonDecode(data) : [];

        historial.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'fecha': _fechaActual,
          'cantidad': _controlesPesos.length,
          'totalPesos': totalPesos,
          'totalArrobas': totalArrobas,
          'totalDinero': totalDinero,
          'rutaPdf': ruta, // Clave vital para el botón compartir
        });

        await prefs.setString('historial_ventas', jsonEncode(historial));
        _limpiarPantalla();
      }
    }
  }

  void _limpiarPantalla() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('temp_lugar');
    await prefs.remove('temp_vendedor');
    await prefs.remove('temp_comprador');
    await prefs.remove('temp_pesos');
    await prefs.remove('temp_precio');

    setState(() {
      _lugarCtrl.clear();
      _vendedorCtrl.clear();
      _compradorCtrl.clear();
      _controlesPesos.clear();
      _precioCtrl.clear();
      _arrobaValorCtrl.text = "25";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30), // Ajusta el radio según prefieras
          ),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Venta",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: rojoVenta,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _fechaActual,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 15),
            _inputVenta(
              _lugarCtrl,
              "Lugar de pesada:",
              Icons.location_on,
              Colors.black,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _inputVenta(
                    _vendedorCtrl,
                    "Vendedor:",
                    Icons.person,
                    rojoVenta,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _inputVenta(
                    _compradorCtrl,
                    "Comprador:",
                    Icons.person_outline,
                    rojoVenta,
                  ),
                ),
              ],
            ),

            const Divider(height: 20),

            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _inputVenta(
                    _pesoInputCtrl,
                    "Ingrese peso:",
                    Icons.scale,
                    verdeVenta,
                    esNum: true,
                  ),
                ),
                const SizedBox(width: 8),

                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _anotarPeso,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: verdeVenta,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Anotar"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTablaEditable(),
            const SizedBox(height: 20),
            _buildSeccionCalculos(),
            const SizedBox(height: 30),
            _buildBotonesFinales(),
          ],
        ),
      ),
    );
  }

  Widget _buildTablaEditable() {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        border: Border.all(color: verdeVenta),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ListView(
          children: [
            Table(
              border: TableBorder.symmetric(
                inside: BorderSide(color: verdeVenta.withOpacity(0.2)),
              ),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: verdeVenta.withOpacity(0.1)),
                  children: [_celdaHeader("N°"), _celdaHeader("Pesos")],
                ),
                ...List.generate(
                  _controlesPesos.length,
                  (index) => TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          "${_controlesPesos.length - index}",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      TextField(
                        controller: _controlesPesos[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: (v) {
                          setState(() {});
                          _guardarDatosTemporales();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionCalculos() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Cant: ${_controlesPesos.length}",
              style: TextStyle(color: rojoVenta, fontWeight: FontWeight.w600),
            ),
            Text(
              "Total P: ${totalPesos.toStringAsFixed(1)}",
              style: TextStyle(color: verdeVenta, fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                const Text("Arroba: "),
                SizedBox(
                  width: 45,
                  child: TextField(
                    controller: _arrobaValorCtrl,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      setState(() {});
                      _guardarDatosTemporales();
                    },
                    decoration: const InputDecoration(isDense: true),
                  ),
                ),
              ],
            ),
          ],
        ),
        const Divider(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total arrobas:",
              style: TextStyle(color: rojoVenta, fontWeight: FontWeight.bold),
            ),
            Text(
              totalArrobas.toStringAsFixed(2),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 145,
              child: _inputVenta(
                _precioCtrl,
                "Precio",
                Icons.payments,
                verdeVenta,
                esNum: true,
                alCambiar: (v) {
                  setState(() {});
                  _guardarDatosTemporales();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        Text(
          "Total S/. ${totalDinero.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: verdeVenta,
          ),
        ),
      ],
    );
  }

  Widget _buildBotonesFinales() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PantallaVentasGuardados(),
              ),
            ),
            icon: const Icon(Icons.folder_open),
            label: const Text("Guardados"),
            style: OutlinedButton.styleFrom(
              foregroundColor: rojoVenta,
              side: BorderSide(color: rojoVenta),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _confirmarGuardar,
            icon: const Icon(Icons.save),
            label: const Text("Guardar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: verdeVenta,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              elevation: 3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _celdaHeader(String t) => Padding(
    padding: const EdgeInsets.all(10),
    child: Text(
      t,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: rojoVenta,
        fontSize: 12,
      ),
    ),
  );

  Widget _inputVenta(
    TextEditingController ctrl,
    String label,
    IconData icono,
    Color color, {
    bool esNum = false,
    Function(String)? alCambiar,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: esNum ? TextInputType.number : TextInputType.text,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,

      onChanged: (v) {
        if (alCambiar != null) alCambiar(v);
        _guardarDatosTemporales();
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono, color: color, size: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.all(12),
        isDense: true,
      ),
    );
  }
}
