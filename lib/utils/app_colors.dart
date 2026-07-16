import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF5B29);
  static const Color background = Color(0xFFF9F8F5);
  static const Color white = Colors.white;
  static const Color textDark = Color(0xFF18181B);
  static const Color textGrey = Color(0xFFA1A1AA);
  static const Color border = Color(0xFFE4E4E7);
  static const Color error = Color(0xFFE53935);

  /// Same gradient used on the home screen wallet card; the shared fill for buttons and hero cards.
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFA21A), Color(0xFFFF7417), Color(0xFFF4511E)],
    stops: [0.0, 0.55, 1.0],
  );
}
