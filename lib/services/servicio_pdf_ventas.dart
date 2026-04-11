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
      pw.MultiPage( // MultiPage es la clave para que cree varias hojas
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // --- ENCABEZADO ---
            pw.Text("Reporte de Venta - CocaMita", 
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            pw.Container(height: 2, color: PdfColors.black),
            pw.SizedBox(height: 15),

            pw.Text("Fecha: $fecha", style: pw.TextStyle(fontSize: 12)),
            pw.Text("Lugar: $lugar", style: pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Vendedor: $vendedor", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text("Comprador: $comprador", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 25),

            // --- TABLA DE PESOS (ESTILO LISTA) ---
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(40), // Columna N°
                1: const pw.FlexColumnWidth(),   // Columna Peso
              },
              children: [
                // Encabezado de la tabla
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text("N°", textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text("Pesos", textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                // Generar una fila por cada peso
                ...List.generate(pesos.length, (index) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text("${index + 1}", textAlign: pw.TextAlign.center),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(pesos[index].toStringAsFixed(1), textAlign: pw.TextAlign.center),
                      ),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 20),

            // --- RESUMEN FINAL ---
            // El resumen siempre aparecerá al final de la última pesada
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1),
                color: PdfColors.grey100,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  
                  _filaResumen("Cantidad de pesadas:", "${pesos.length}"),
                  _filaResumen("Total Pesos:", totalPesos.toStringAsFixed(1)),
                  _filaResumen("Arroba definida:", arroba.toStringAsFixed(0)),
                  _filaResumen("Total Arrobas:", totalArrobas.toStringAsFixed(2), esNegrita: true),
                  _filaResumen("Precio por Arroba:", "S/. ${precio.toStringAsFixed(2)}"),
                  pw.Divider(color: PdfColors.grey),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("TOTAL A PAGAR:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.Text("S/. ${totalDinero.toStringAsFixed(2)}", 
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
                    ],
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    // Lógica de guardado igual...
    final dir = await getApplicationDocumentsDirectory();
    final nombreArchivo = "Venta_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final file = File("${dir.path}/$nombreArchivo");
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  static pw.Widget _filaResumen(String etiqueta, String valor, {bool esNegrita = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(etiqueta),
          pw.Text(valor, style: pw.TextStyle(fontWeight: esNegrita ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }
}