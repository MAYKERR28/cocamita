import 'package:cocamita/constants/variables.dart';
import 'package:flutter/material.dart';

/// Widget personalizado para los botones de la pantalla de bienvenida.
/// Incluye el efecto InkWell (onda) y bordes redondeados.
class BotonMenuPrincipal extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Color color;
  final VoidCallback onTap;

  const BotonMenuPrincipal({
    super.key,
    required this.titulo,
    required this.icono,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: blanco, // Necesario para que el efecto visual sea fluido
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20), // Ajusta el efecto al borde del botón
        splashColor: color.withOpacity(0.2),    // Color de la onda al presionar
        highlightColor: color.withOpacity(0.1), // Color de fondo sostenido
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 25),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, size: 60, color: color),
              const SizedBox(width: 10),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 30, 
                  color: color, 
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}