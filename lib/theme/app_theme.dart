import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF3B82F6); // blue-500
  static const primaryDark = Color(0xFF2563EB); // blue-600
  static const primaryLight = Color(0xFF60A5FA); // blue-400
  static const surfaceSoft = Color(0xFFF1F5F9); // slate-50
  static const border = Color(0xFFE2E8F0); // slate-200
  static const textMuted = Color(0xFF64748B); // slate-500
  
  // Yeni eklenen modern tema renkleri
  static const background = Color(0xFFF8FAFC); // slate-50 with more blue tint
  static const cardBackground = Colors.white;
  static const textPrimary = Color(0xFF1E293B); // slate-800
  static const textSecondary = Color(0xFF64748B); // slate-500
  static const accent = Color(0xFFFF9500); // Warm orange for highlights
  static const success = Color(0xFF10B981); // emerald-500
  
  // Premium Profile Page Colors
  static const gradientPurple = Color(0xFF8B5CF6); // violet-500
  static const gradientBlue = Color(0xFF3B82F6); // blue-500
  static const gradientCyan = Color(0xFF06B6D4); // cyan-500
  static const gradientPink = Color(0xFFEC4899); // pink-500
  
  // Glassmorphism
  static const glassWhite = Color(0x40FFFFFF); // 25% white
  static const glassBorder = Color(0x30FFFFFF); // 19% white
  static const glassOverlay = Color(0x15FFFFFF); // 8% white
  
  // Profile specific
  static const avatarGlow = Color(0xFF8B5CF6); // violet glow
  static const cardShadow = Color(0x1A3B82F6); // blue shadow 10%
  static const favoriteRed = Color(0xFFEF4444); // red-500
  static const commentBlue = Color(0xFF3B82F6); // blue-500
  static const mealGreen = Color(0xFF22C55E); // green-500
  
  // Gradients
  static const LinearGradient profileGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientPurple, gradientBlue, gradientCyan],
  );
  
  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [glassWhite, glassBorder, glassWhite],
  );
}
