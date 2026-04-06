import 'package:cocamita/ui/screens/pantalla_bienvenida.dart';
import 'package:intl/date_symbol_data_local.dart'; // Para inicializar la localización de fechas
import 'package:flutter/material.dart';


Future<void> main() async {
  // Asegura que los bindings de Flutter estén listos
  WidgetsFlutterBinding.ensureInitialized();

  // INICIALIZA los datos de idioma (Español)
  await initializeDateFormatting('es_ES', null);

  runApp(const CocaMitaApp());
}

class CocaMitaApp extends StatelessWidget {
  const CocaMitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CocaMita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00796B), // verdeCoca
          primary: const Color(0xFF00796B),
          secondary: const Color(0xFF7A1C1C), // rojoVino
        ),
      ),
      home: const PantallaBienvenida(),
    );
  }
}