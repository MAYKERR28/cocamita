import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class ServicioPdfVentas {
  static Future<String?> generarPDF({
    required String fecha,
    required String lugar,
    required String vendedor,
    required String comprador,
    required List<double> pesos,
    required double totalPesos,
    required double arroba,
    required double totalArrobas,
    required double precio,
    required double totalDinero,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Text("Reporte de Venta - CocaMita")),
              pw.Text("Fecha: $fecha"),
              pw.Text("Lugar: $lugar"),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Expanded(child: pw.Text("Vendedor: $vendedor")),
                pw.Expanded(child: pw.Text("Comprador: $comprador")),
              ]),
              pw.SizedBox(height: 20),
              
              // Tabla de Pesos
              pw.TableHelper.fromTextArray(
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                headers: ['N°', 'Peso'],
                data: List.generate(pesos.length, (index) => [
                  '${index + 1}',
                  '${pesos[index]}'
                ]),
              ),

              pw.SizedBox(height: 20),
              pw.Divider(),
              
              // Resumen de Cálculos
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text("Cantidad de pesadas: ${pesos.length}"),
                pw.Text("Total Pesos: ${totalPesos.toStringAsFixed(1)}"),
              ]),
              pw.Text("Valor de Arroba: $arroba"),
              pw.Text("Total Arrobas: ${totalArrobas.toStringAsFixed(2)}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text("Precio S/.: $precio"),
              pw.SizedBox(height: 10),
              pw.Text("TOTAL A PAGAR: S/. ${totalDinero.toStringAsFixed(2)}", 
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    try {
      // Guardar el archivo en el almacenamiento del teléfono
      final dir = await getApplicationDocumentsDirectory();
      final nombreArchivo = "Venta_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final archivo = File("${dir.path}/$nombreArchivo");
      
      await archivo.writeAsBytes(await pdf.save());
      
      // IMPORTANTE: Retornamos la ruta completa para que SharedPreferences la guarde
      return archivo.path; 
    } catch (e) {
      print("Error al crear PDF: $e");
      return null;
    }
  }
}