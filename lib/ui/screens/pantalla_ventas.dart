import 'dart:convert';
import 'package:cocamita/services/servicio_pdf_ventas.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ventas_guardados.dart';

class PantallaVentas extends StatefulWidget {
  const PantallaVentas({super.key});

  @override
  State<PantallaVentas> createState() => _PantallaVentasState();
}

class _PantallaVentasState extends State<PantallaVentas> {
  final Color verdeVenta = const Color(0xFF00796B);
  final Color rojoVenta = const Color(0xFF7A1C1C);

  final _lugarCtrl = TextEditingController();
  final _vendedorCtrl = TextEditingController();
  final _compradorCtrl = TextEditingController();
  final _pesoInputCtrl = TextEditingController();
  final _arrobaValorCtrl = TextEditingController(text: "25");
  final _precioCtrl = TextEditingController();

  List<double> _listaPesos = [];
  String _fechaActual = "";

  @override
  void initState() {
    super.initState();
    _fechaActual = DateFormat(
      "EEEE d 'de' MMMM 'del' y",
      'es_ES',
    ).format(DateTime.now());
  }

  // Lógica Matemática
  double get totalPesos => _listaPesos.fold(0, (sum, item) => sum + item);
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
      setState(() {
        _listaPesos.add(double.parse(_pesoInputCtrl.text));
        _pesoInputCtrl.clear();
      });
      FocusScope.of(context).unfocus();
    }
  }

  void _confirmarGuardar() async {
    // 1. Mostrar el cuadro de diálogo al usuario
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Guardar Venta?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("NO"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("SÍ"),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      // 2. GENERAR EL PDF PRIMERO
      // Debes llamar a tu servicio de PDF y esperar a que te devuelva la RUTA (String)
      // Supongamos que tu servicio se llama ServicioPdfVentas
      String? ruta = await ServicioPdfVentas.generarPDF(
        fecha: _fechaActual,
        lugar: _lugarCtrl.text,
        vendedor: _vendedorCtrl.text,
        comprador: _compradorCtrl.text,
        pesos: _listaPesos,
        totalPesos: totalPesos,
        arroba: double.tryParse(_arrobaValorCtrl.text) ?? 25,
        totalArrobas: totalArrobas,
        precio: double.tryParse(_precioCtrl.text) ?? 0,
        totalDinero: totalDinero,
      );

      // 3. VERIFICAR SI SE CREÓ EL ARCHIVO
      if (ruta != null) {
        final prefs = await SharedPreferences.getInstance();
        final String? data = prefs.getString('historial_ventas');
        List<dynamic> historial = data != null ? jsonDecode(data) : [];

        // 4. GUARDAR EL MAPA CON LA RUTA INCLUIDA
        historial.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'fecha': _fechaActual,
          'cantidad': _listaPesos.length,
          'totalPesos': totalPesos,
          'totalArrobas': totalArrobas,
          'totalDinero': totalDinero,
          // ESTA ES LA CLAVE: Si no guardas esto, el botón compartir fallará
          'rutaPdf': ruta,
        });

        // 5. SALVAR EN EL TELÉFONO Y LIMPIAR
        await prefs.setString('historial_ventas', jsonEncode(historial));
        _limpiarTodo();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Venta guardada y PDF generado")),
        );
      } else {
        // Si rutaDelArchivo es null, algo falló al crear el PDF
        print("Error: No se pudo generar la ruta del PDF");
      }
    }
  }

  void _limpiarTodo() {
    setState(() {
      _lugarCtrl.clear();
      _vendedorCtrl.clear();
      _compradorCtrl.clear();
      _listaPesos.clear();
      _precioCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart),
            SizedBox(width: 10),
            Text("Venta"),
          ],
        ),
        backgroundColor: rojoVenta,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(_fechaActual, style: const TextStyle(fontSize: 13)),
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
                const SizedBox(width: 10),
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
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _inputVenta(
                    _pesoInputCtrl,
                    "Ingrese pesos:",
                    Icons.scale,
                    verdeVenta,
                    esNum: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _anotarPeso,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: verdeVenta,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Anotar"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTabla(),
            const SizedBox(height: 20),
            _filaResultados(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabla() {
    return Container(
      height: 250,
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
              children: [
                TableRow(
                  decoration: BoxDecoration(color: verdeVenta.withOpacity(0.1)),
                  children: [_celdaHeader("N°"), _celdaHeader("Pesos")],
                ),
                ...List.generate(
                  _listaPesos.length,
                  (index) => TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          "${index + 1}",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          "${_listaPesos[index]}",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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

  Widget _filaResultados() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Cantidad: ${_listaPesos.length}",
              style: TextStyle(color: rojoVenta, fontWeight: FontWeight.bold),
            ),
            Text(
              "Total pesos: ${totalPesos.toStringAsFixed(1)}",
              style: TextStyle(color: verdeVenta, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                const Text("Arroba: "),
                SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _arrobaValorCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() {}),
                  ),
                ),
              ],
            ),
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total arrobas",
              style: TextStyle(color: rojoVenta, fontWeight: FontWeight.bold),
            ),
            Text(
              totalArrobas.toStringAsFixed(2),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 100,
              child: _inputVenta(
                _precioCtrl,
                "Precio",
                Icons.payments,
                verdeVenta,
                esNum: true,
                alCambiar: (v) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          "Total en S/. ${totalDinero.toStringAsFixed(0)}",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: verdeVenta,
          ),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaVentasGuardados(),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: rojoVenta,
                  side: BorderSide(color: rojoVenta),
                ),
                child: const Text("Guardados"),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton(
                onPressed: _confirmarGuardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: verdeVenta,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Guardar"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _celdaHeader(String t) => Padding(
    padding: const EdgeInsets.all(10),
    child: Text(
      t,
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.bold, color: rojoVenta),
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
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      onChanged: alCambiar,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono, color: color, size: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.all(10),
        isDense: true,
      ),
    );
  }
}
