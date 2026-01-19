import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

String authErrorMessage(FirebaseAuthException error) {
  switch (error.code) {
    case 'invalid-email':
      return 'El correo no es valido.';
    case 'user-not-found':
      return 'No existe una cuenta con ese correo.';
    case 'wrong-password':
    case 'invalid-credential':
      return 'Credenciales incorrectas. Verifica tu correo y contraseña.';
    case 'email-already-in-use':
      return 'Este correo ya esta registrado.';
    case 'weak-password':
      return 'La contraseña es muy corta. Usa al menos 6 caracteres.';
    case 'user-disabled':
      return 'La cuenta esta deshabilitada.';
    case 'too-many-requests':
      return 'Demasiados intentos. Intenta mas tarde.';
    case 'network-request-failed':
      return 'Sin conexion. Revisa tu red e intenta de nuevo.';
    case 'missing-email':
      return 'Ingresa un correo valido para continuar.';
    default:
      return 'No se pudo completar la solicitud. Intenta de nuevo.';
  }
}

void showAuthSnackBar(BuildContext context, String message,
    {bool success = false}) {
  final colorScheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor:
          success ? colorScheme.primary : colorScheme.error.withValues(alpha: 0.9),
    ),
  );
}
