import 'package:flutter/material.dart';

import 'app/canvas_planner_app.dart';
import 'data/canvas_entities_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = await CanvasEntitiesRepository.create();
  runApp(CanvasPlannerApp(repository: repository));
}
