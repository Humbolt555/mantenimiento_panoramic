import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/canvas_entities_repository.dart';
import '../ui/pages/auth/auth_gate.dart';

class CanvasPlannerApp extends StatelessWidget {
  const CanvasPlannerApp({super.key, required this.repository});

  final CanvasEntitiesRepository repository;

  @override
  Widget build(BuildContext context) {
    final colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF0C3B4A),
      onPrimary: Color(0xFFFDF9F3),
      secondary: Color(0xFFE06B3C),
      onSecondary: Color(0xFF1B1A17),
      tertiary: Color(0xFFF1C77A),
      onTertiary: Color(0xFF1B1A17),
      surface: Color(0xFFFDF9F3),
      onSurface: Color(0xFF1B1A17),
      error: Color(0xFFB3261E),
      onError: Color(0xFFFFFFFF),
    );

    return RepositoryProvider.value(
      value: repository,
      child: MaterialApp(
        title: 'Mantenimiento Panoramic',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          scaffoldBackgroundColor: colorScheme.surface,
          textTheme: GoogleFonts.spaceGroteskTextTheme()
              .apply(bodyColor: colorScheme.onSurface),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleTextStyle: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: colorScheme.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: colorScheme.primary.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: colorScheme.primary.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
            ),
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}
