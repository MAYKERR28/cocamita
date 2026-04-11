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
            fontWeight: FontWeight.w600
          ),
        ),
        centerTitle: true,
        backgroundColor: verdeCoca,
        toolbarHeight: 80,
        elevation: 0,
        // Redondeado inferior para un estilo más orgánico
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      // --- CAMBIO: Uso de SingleChildScrollView para el scroll ---
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              // Icono de bienvenida
              const Icon(Icons.handshake, size: 72, color: Color(0xFF004D40)),
              
              const Text(
                '¡ Bienvenido !',
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.w500, 
                  color: Color(0xFF004D40)
                ),
              ),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Cuaderno digital para el agricultor coc@lero. App para facilitar el trabajo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),

              const Divider(
                height: 20,
                thickness: 1,
                indent: 50,
                endIndent: 50,   
                color: Color(0xFF004D40),             
              ),
              Text(
                'Apuntes de:', 
                style: TextStyle(
                  fontSize: 28, 
                  color: rojoVino, 
                  fontWeight: FontWeight.w500
                )
              ),
              
              const SizedBox(height: 20),

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
                    const SizedBox(height:15),
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
              
              const Divider(
                height: 30,
                thickness: 1,
                indent: 50,
                endIndent: 50,     
                color: Color(0xFF004D40),             
              ),
              const Text(
                '! Guarda batería hasta terminar el día ¡', 
                style: TextStyle(color: Color(0xFF00796B), fontSize: 12)
              ),
              
              const SizedBox(height: 20),

              // Pie de página con enlaces legales
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                  children: [
                    const TextSpan(text: "Al usar CocaMita, acepta nuestas\n"),
                    TextSpan(
                      text: "Políticas de privacidad",
                      style: TextStyle(color: rojoVino, fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()..onTap = () => _abrirEnlace('https://tuweb.com/politicas'),
                    ),
                    const TextSpan(text: " y los "),
                    TextSpan(
                      text: "Términos y condiciones",
                      style: TextStyle(color: rojoVino, fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()..onTap = () => _abrirEnlace('https://tuweb.com/terminos'),
                    ),
                    TextSpan(text: "."),
                  ],
                ),
              ),
              
              const SizedBox(height: 50),
              Text(
                "@ 2026 mayker / CocaMita. All rights reserved", 
                style: TextStyle(color: Colors.black54, fontSize: 12)
              ),              
            ],
          ),
        ),
      ),
    );
  }
}