import 'package:cocamita/constants/variables.dart';
import 'package:cocamita/ui/screens/pantalla_listas.dart';
import 'package:cocamita/ui/screens/pantalla_ventas.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/boton_menu_principal.dart'; // Importamos nuestro widget

class PantallaBienvenida extends StatelessWidget {
  const PantallaBienvenida({super.key});

  Future<void> _abrirEnlace(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      debugPrint('No se pudo abrir $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: verdePrimario,
        foregroundColor: blanco,
        title: const Text(
          'CocaMita',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        // ---- Aquí redondear ----
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
        ),
        toolbarHeight: 80,
      ),
      backgroundColor: const Color(0xFFFFFFFF),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 4),
            const Icon(Icons.handshake, size: 64, color: Color(0xFF004D40)),
            const Text(
              '¡ Bienvenido !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF004D40),
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                'Cuaderno digital para el agricultor\ncoc@lero. Registra tus actividades\nde cosecha en un solo lugar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),
            Text(
              'Apuntes',
              style: TextStyle(
                fontSize: 28,
                color: vinoSecundario,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Sección de botones usando el widget reutilizable
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  BotonMenuPrincipal(
                    titulo: 'Listas',
                    icono: Icons.edit_note,
                    color: verdePrimario,
                    onTap: () {
                      // Navegar a Listas
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PantallaListas(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  BotonMenuPrincipal(
                    titulo: 'Ventas',
                    icono: Icons.shopping_cart,
                    color: vinoSecundario,
                    onTap: () {
                      // Navegar a Ventas
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PantallaVentas(),
                        ),
                      );
                    },
                  ),
                  
                ],
              ),
            ),
            
            // Lleva todo el espacio restante para que el texto de abajo quede pegado al final
            // const Spacer(),  
            
            const SizedBox(height: 30),
            const Text(
              'Ten batería disponible',
              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            
            // TEXTO CON ENLACES CLICKABLES
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 16, fontFamily: "PoppinsFonts"),
                children: [
                  const TextSpan(
                    text: "Al usar la App CocaMita, acepta las\n",
                  ),
                  TextSpan(
                    text: "Políticas de privacidad",
                    style: TextStyle(color: vinoSecundario, decoration: TextDecoration.underline),
                    
                    recognizer: TapGestureRecognizer()
                      ..onTap = () =>
                          _abrirEnlace('https://tuweb.com/politicas'),
                  ),
                  const TextSpan(text: " y los "),
                  TextSpan(
                    text: "\nTérminos y Condiciones",
                    style: TextStyle(color: vinoSecundario, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () =>
                          _abrirEnlace('https://tuweb.com/terminos'),
                  ),
                  TextSpan(
                    text: "."
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),
            Text(
              "@ 2026 mayker / CocaMita. All rights reserved.",
              style: TextStyle(color: verdePrimarioDark, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
