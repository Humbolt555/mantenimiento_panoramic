import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/canvas_entities_bloc.dart';
import '../../../bloc/canvas_entities_event.dart';
import '../../../data/canvas_entities_repository.dart';
import '../canvas_planner_page.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('No se pudo verificar la sesion.')),
          );
        }
        if (snapshot.hasData) {
          final repository = context.read<CanvasEntitiesRepository>();
          return BlocProvider(
            create: (_) => CanvasEntitiesBloc(repository: repository)
              ..add(const CanvasEntitiesLoadRequested()),
            child: const CanvasPlannerPage(),
          );
        }
        return const LoginPage();
      },
    );
  }
}
