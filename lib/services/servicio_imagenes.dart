import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServicioImagenes {
  static const String _clavePref = 'imagenes_guardadas';

  /// Guarda una imagen temporal en el almacenamiento permanente del teléfono
  /// y registra su ruta en SharedPreferences.
  static Future<String?> guardarImagen(List<int> bytesImagen) async {
    try {
      // 1. Obtener el directorio de documentos del teléfono
      final directorio = await getApplicationDocumentsDirectory();
      
      // 2. Crear un nombre único basado en la fecha y hora
      final nombreArchivo = 'lista_${DateTime.now().millisecondsSinceEpoch}.png';
      final rutaCompleta = '${directorio.path}/$nombreArchivo';
      
      // 3. Escribir los bytes en el archivo
      final archivo = File(rutaCompleta);
      await archivo.writeAsBytes(bytesImagen);

      // 4. Guardar la ruta en SharedPreferences para saber qué imágenes tenemos
      final prefs = await SharedPreferences.getInstance();
      List<String> rutas = prefs.getStringList(_clavePref) ?? [];
      rutas.add(rutaCompleta);
      await prefs.setStringList(_clavePref, rutas);

      return rutaCompleta;
    } catch (e) {
      print("Error al guardar imagen: $e");
      return null;
    }
  }

  /// Devuelve la lista de rutas de todas las imágenes guardadas
  static Future<List<String>> obtenerRutas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_clavePref) ?? [];
  }

  /// Elimina el archivo físico y su ruta de las preferencias
  static Future<void> eliminarImagen(String ruta) async {
    try {
      final archivo = File(ruta);
      if (await archivo.exists()) {
        await archivo.delete();
      }
      final prefs = await SharedPreferences.getInstance();
      List<String> rutas = prefs.getStringList(_clavePref) ?? [];
      rutas.remove(ruta);
      await prefs.setStringList(_clavePref, rutas);
    } catch (e) {
      print("Error al eliminar imagen: $e");
    }
  }
}