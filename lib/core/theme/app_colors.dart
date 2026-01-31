import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // 🔵 PALETA PRINCIPAL (PREMIUM)
  static const primary = Color(0xFF0F172A);    // Azul Marinho Profundo (Navy)
  static const primaryLight = Color(0xFF1E293B); 
  static const secondary = Color(0xFFD97706);  // Âmbar/Ouro (para destaques)
  
  // ⚪ SUPERFÍCIES
  static const background = Color(0xFFF8FAFC); // Cinza Quase Branco
  static const surface = Colors.white;
  static const card = Colors.white;

  // 📝 TEXTO
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textOnPrimary = Colors.white;

  // 🎭 ESTADOS
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);

  // 🌈 GRADIENTES (O SEGREDO DO VISUAL PREMIUM)
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accentGradient = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
