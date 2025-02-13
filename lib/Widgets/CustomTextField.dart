import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final Icon prefixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.prefixIcon,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.08),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.1), // Fond semi-transparent
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // Ombre légère
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color, // Texte en fonction du thème
          ),
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(
              color: theme.textTheme.bodyMedium?.color, // Couleur adaptée au thème
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(
              prefixIcon.icon,
              color: theme.primaryColor, // Icône colorée avec le thème
            ),
            filled: true,
            fillColor: Colors.transparent, // Pas besoin d’un fond ici, déjà ajouté au container
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.primaryColor, width: 2), // Bordure active
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.dividerColor, width: 1.5), // Bordure normale
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
