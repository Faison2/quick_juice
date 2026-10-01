import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AuthField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscure;
  final IconData icon;
  final Widget? suffix;

  const AuthField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    required this.icon,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.inkMuted, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.inkMuted, size: 20),
        suffixIcon: suffix,
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.rowBg)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.navyMid, width: 2)),
      ),
    );
  }
}
