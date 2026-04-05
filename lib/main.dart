import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cocamita/ui/screens/pantalla_bienvenida.dart';

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
        
        fontFamily: "PoppinsFonts", 
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green)// Te sugiero usar una fuente como Poppins o Montserrat en el futuro
      ),
      home: const PantallaBienvenida(),
      
    );
  }
}