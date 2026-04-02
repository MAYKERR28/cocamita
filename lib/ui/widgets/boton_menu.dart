import 'package:flutter/material.dart';

class BotonMenu extends StatelessWidget {
  final String texto;
  final IconData icono;
  final Color color;
  final VoidCallback onPressed;

  const BotonMenu({
    super.key,
    required this.texto,
    required this.icono,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400), // Responsivo: no crecerá más de 400px en tablets
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icono, color: Colors.white, size: 40),
            ),
            const SizedBox(width: 20),
            Text(
              texto,
              style: TextStyle(
                fontSize: 32,
                color: color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}