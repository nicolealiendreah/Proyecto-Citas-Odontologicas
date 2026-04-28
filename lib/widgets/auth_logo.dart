import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class AuthLogo extends StatelessWidget {
  final bool dark;

  const AuthLogo({super.key, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: dark ? AppColors.primary : AppColors.secondary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        Icons.medical_services_outlined,
        color: dark ? Colors.white : AppColors.primary,
        size: 34,
      ),
    );
  }
}