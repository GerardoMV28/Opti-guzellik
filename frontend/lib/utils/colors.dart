import 'package:flutter/material.dart';

class AppColors {
  // Azul Real / Azul Profundo (predominante)
  static const Color azulReal = Color(0xFF1A2B4C); // #1A2B4C
  
  // Azul Marino (sombras, profundidad)
  static const Color azulMarino = Color(0xFF0F1A30); // #0F1A30
  
  // Azul Cobalto (transición)
  static const Color azulCobalto = Color(0xFF2A4F6E); // #2A4F6E
  
  // Turquesa / Aqua (toque brillante)
  static const Color turquesa = Color(0xFF40B7B7); // #40B7B7
  
  // Variantes con opacidad para gradientes
  static LinearGradient get backgroundGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      azulReal,
      azulCobalto,
      turquesa.withOpacity(0.8),
    ],
    stops: [0.0, 0.6, 1.0],
  );
  
  static LinearGradient get buttonGradient => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      azulCobalto,
      turquesa,
    ],
  );
  
  static LinearGradient get cardGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white,
      Colors.white.withOpacity(0.95),
    ],
  );

  // Gradiente sutil para AppBars, para acercar el look de las pantallas
  // internas al del login sin perder legibilidad en pantallas de trabajo.
  static LinearGradient get appBarGradient => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      azulReal,
      azulCobalto,
    ],
  );
}