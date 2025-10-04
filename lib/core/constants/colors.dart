import 'package:flutter/material.dart';

/// App color palette
class AppColors {
  // Primary - Sage Green theme 🌿
  static const primary = Color(0xFF4CAF50);
  static const primaryDark = Color(0xFF388E3C);
  static const primaryLight = Color(0xFF81C784);

  // Expiration Status Colors
  static const fresh = Color(0xFF4CAF50); // Green
  static const caution = Color(0xFFFFEB3B); // Yellow
  static const warning = Color(0xFFFF9800); // Orange
  static const critical = Color(0xFFF44336); // Red
  static const expired = Color(0xFF9E9E9E); // Gray

  // UI Colors
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const divider = Color(0xFFBDBDBD);

  // Semantic Colors
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFF44336);
  static const info = Color(0xFF2196F3);
  static const warning2 = Color(0xFFFF9800);

  // Location Colors (subtle backgrounds)
  static const fridgeColor = Color(0xFFE3F2FD); // Light blue
  static const freezerColor = Color(0xFFE1F5FE); // Lighter blue
  static const pantryColor = Color(0xFFFFF9C4); // Light yellow
  static const spiceRackColor = Color(0xFFFFECB3); // Light amber
  static const countertopColor = Color(0xFFE8F5E9); // Light green
  static const otherColor = Color(0xFFF5F5F5); // Light gray
}
