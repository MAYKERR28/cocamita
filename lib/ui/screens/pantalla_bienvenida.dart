import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/boton_menu_principal.dart';
import 'pantalla_listas.dart';
import 'pantalla_ventas.dart';

class PantallaBienvenida extends StatelessWidget {
  const PantallaBienvenida({super.key});

  final Color verdeCoca = const Color(0xFF00796B);
  final Color rojoVino = const Color(0xFF7A1C1C);

  // Función para abrir los enlaces de políticas y términos
  Future<void> _abrirEnlace(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      debugPrint('No se pudo abrir $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // --- CAMBIO: Título en el AppBar ---
      appBar: AppBar(
        title: const Text(
          'CocaMita',
          style: TextStyle(
            color: Colors.white, 
            fontSize: 26, 
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        backgroundColor: verdeCoca,
        toolbarHeight: 80,
        elevation: 0,
        // Redondeado inferior para un estilo más orgánico
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(40),
          ),
        ),
      ),
      // --- CAMBIO: Uso de SingleChildScrollView para el scroll ---
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              
              // Icono de bienvenida
              const Icon(Icons.handshake, size: 80, color: Color(0xFF004D40)),
              
              const Text(
                '¡ Bienvenido !',
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: Color(0xFF004D40)
                ),
              ),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: Text(
                  'Cuaderno digital de apuntes para el agricultor coc@lero',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 20),
              Text(
                'Apuntes', 
                style: TextStyle(
                  fontSize: 32, 
                  color: rojoVino, 
                  fontWeight: FontWeight.bold
                )
              ),
              
              const SizedBox(height: 30),

              // Sección de botones principales
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    BotonMenuPrincipal(
                      titulo: 'Listas',
                      icono: Icons.edit_note,
                      color: verdeCoca,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PantallaListas()),
                        );
                      },
                    ),
                    const SizedBox(height: 25),
                    BotonMenuPrincipal(
                      titulo: 'Ventas',
                      icono: Icons.shopping_cart,
                      color: rojoVino,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PantallaVentas()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              const Text(
                '! No gastes la batería hasta terminar el día ¡', 
                style: TextStyle(color: Color(0xFF00796B), fontSize: 12)
              ),
              
              const SizedBox(height: 20),

              // Pie de página con enlaces legales
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87, fontSize: 12),
                  children: [
                    const TextSpan(text: "Al usar la CocaMita, acepta nuestras\n"),
                    TextSpan(
                      text: "Políticas de privacidad",
                      style: TextStyle(color: rojoVino, fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()..onTap = () => _abrirEnlace('https://tuweb.com/politicas'),
                    ),
                    const TextSpan(text: " y los "),
                    TextSpan(
                      text: "Términos y condiciones.",
                      style: TextStyle(color: rojoVino, fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()..onTap = () => _abrirEnlace('https://tuweb.com/terminos'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              Text(
                "@ 2026 mayker / CocaMita. All rights reserved", 
                style: TextStyle(color: verdeCoca, fontSize: 11)
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}