import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cocamita/ui/pantallas/pantalla_bienvenida.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CocaMita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(        
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: "PoppinsFonts", // Te sugiero usar una fuente como Poppins o Montserrat en el futuro
      ),
      home: const PantallaBienvenida(),
    );
  }
}