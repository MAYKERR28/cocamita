import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cosechador_item.dart';

class ServicioPdf {
  static const String _clavePref = 'pdfs_guardados';

  static Future<String?> generarYGuardarPDF({
    required String fecha,
    required String lugar,
    required String grupo1,
    required String grupo2,
    required List<CosechadorItem> lista,
    required int totalG1,
    required int totalG2,
    required int granTotal,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Text('Apuntes de Cosecha - CocaMita', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Fecha: $fecha', style: const pw.TextStyle(fontSize: 14)),
              pw.Text('Lugar: $lugar', style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Grupo 1: $grupo1', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Grupo 2: $grupo2', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ]
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                cellAlignment: pw.Alignment.center,
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                headers: ['Nombres', 'P1', 'P2', 'P3', 'P4', 'G1', 'G2', 'sTot'],
                data: lista.map((item) {
                  return [
                    item.nombreCtrl.text,
                    item.p1Ctrl.text,
                    item.p2Ctrl.text,
                    item.p3Ctrl.text,
                    item.p4Ctrl.text,
                    item.g1 ? 'X' : '', 
                    item.g2 ? 'X' : '',
                    item.sTot.toString(),
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Cant: ${lista.length}'),
                  pw.Text('Total G1: $totalG1', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
                  pw.Text('Total G2: $totalG2', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.teal800)),
                  pw.Text('TOTAL: $granTotal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                ]
              ),
            ];
          },
        ),
      );

      final directorio = await getApplicationDocumentsDirectory();
      final nombreLimpio = fecha.replaceAll(' ', '_').replaceAll(',', '');
      final nombreArchivo = 'CocaMita_${nombreLimpio}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final rutaCompleta = '${directorio.path}/$nombreArchivo';
      
      final archivo = File(rutaCompleta);
      await archivo.writeAsBytes(await pdf.save());

      final prefs = await SharedPreferences.getInstance();
      List<String> rutas = prefs.getStringList(_clavePref) ?? [];
      rutas.add(rutaCompleta);
      await prefs.setStringList(_clavePref, rutas);

      return rutaCompleta;
    } catch (e) {
      print("Error al generar PDF: $e");
      return null;
    }
  }

  static Future<List<String>> obtenerRutas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_clavePref) ?? [];
  }

  static Future<void> eliminarPdf(String ruta) async {
    try {
      final archivo = File(ruta);
      if (await archivo.exists()) await archivo.delete();
      final prefs = await SharedPreferences.getInstance();
      List<String> rutas = prefs.getStringList(_clavePref) ?? [];
      rutas.remove(ruta);
      await prefs.setStringList(_clavePref, rutas);
    } catch (e) {}
  }
}