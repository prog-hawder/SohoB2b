import 'package:b2b/Themes/colors.dart';
import 'package:flutter/material.dart';

class AppTextStyles {
  static TextStyle get bodyText => const TextStyle(
        fontSize: 16,
        color: Color.fromARGB(157, 36, 36, 36),
      );
        static TextStyle get botomText => const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 26,
        color: Colors.white
      );
        static TextStyle get maincolorText => const TextStyle(
        fontSize: 16,
        color: AppColors.primary,
      );
        static TextStyle get bodyText2 => const TextStyle(
        fontSize: 18,
        color: Color.fromARGB(157, 49, 49, 49),
      );
              static TextStyle get botomText2 => const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 16,
        color: Colors.white
      );
}
