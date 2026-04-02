import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cocamita/ui/widgets/boton_menu.dart';

class PantallaBienvenida extends StatelessWidget {
  const PantallaBienvenida({super.key});

  // Colores extraídos de tu diseño
  final Color verdeCoca = const Color(0xFF00796B);
  final Color rojoVino = const Color(0xFF7A1C1C);

  Future<void> _abrirEnlace(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      debugPrint('No se pudo abrir $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // CABECERA CURVA
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20, // Respeta el notch/barra de estado
              bottom: 30,
            ),
            decoration: BoxDecoration(
              color: verdeCoca,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: const Text(
              "CocaMita",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w500),
            ),
          ),

          // CONTENIDO DESLIZABLE (Responsivo)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Icon(Icons.handshake, size: 50, color: verdeCoca),
                  const SizedBox(height: 10),
                  Text("¡ Bienvenido !", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: verdeCoca)),
                  const SizedBox(height: 10),
                  const Text(
                    "Cuaderno digital de apuntes\npara el agricultor coc@lero",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  
                  const SizedBox(height: 30),
                  const Text("Apuntes", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF4A1010))),
                  const SizedBox(height: 30),

                  // BOTONES
                  BotonMenu(
                    texto: "Listas",
                    icono: Icons.edit_note, // Ícono similar al del mockup
                    color: verdeCoca,
                    onPressed: () {
                      // TODO: Navegar a Listas
                    },
                  ),
                  const SizedBox(height: 20),
                  BotonMenu(
                    texto: "Ventas",
                    icono: Icons.shopping_cart,
                    color: rojoVino,
                    onPressed: () {
                      // TODO: Navegar a Ventas
                    },
                  ),

                  const SizedBox(height: 40),

                  // PIE DE PÁGINA
                  Text("! No gastes la batería hasta terminar el día ¡", style: TextStyle(color: verdeCoca, fontSize: 13)),
                  const SizedBox(height: 20),
                  
                  // TEXTO CON ENLACES CLICKABLES
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black87, fontSize: 12),
                      children: [
                        const TextSpan(text: "Al usar la CocaMita, acepta nuestras\n"),
                        TextSpan(
                          text: "Políticas de privacidad",
                          style: TextStyle(color: rojoVino),
                          recognizer: TapGestureRecognizer()..onTap = () => _abrirEnlace('https://tuweb.com/politicas'),
                        ),
                        const TextSpan(text: " y los "),
                        TextSpan(
                          text: "Términos y condiciones.",
                          style: TextStyle(color: rojoVino),
                          recognizer: TapGestureRecognizer()..onTap = () => _abrirEnlace('https://tuweb.com/terminos'),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  Text("@ 2026 mayker / CocaMita. All rights reserved", style: TextStyle(color: verdeCoca, fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}