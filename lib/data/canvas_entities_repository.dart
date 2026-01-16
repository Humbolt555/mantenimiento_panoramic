import 'dart:convert';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/canvas_entity.dart';

class CanvasEntitiesRepository {
  CanvasEntitiesRepository({required SharedPreferences preferences})
      : _preferences = preferences;

  static const _storageKey = 'canvas_entities_storage';

  final SharedPreferences _preferences;

  static Future<CanvasEntitiesRepository> create() async {
    final preferences = await SharedPreferences.getInstance();
    return CanvasEntitiesRepository(preferences: preferences);
  }

  Future<List<CanvasEntity>> fetchEntities() async {
    final raw = _preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return _seedEntities;
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => CanvasEntity.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _seedEntities;
    }
  }

  Future<void> saveEntities(List<CanvasEntity> entities) async {
    final encoded = jsonEncode(entities.map((e) => e.toJson()).toList());
    await _preferences.setString(_storageKey, encoded);
  }

  List<CanvasEntity> get _seedEntities => const [
        CanvasEntity(
          id: 'A01',
          name: 'Torre de enfriamiento',
          type: 'Mecanica',
          status: 'Activa',
          owner: 'Equipo Atlas',
          notes: 'Inspeccion trimestral lista.',
          position: Offset(0.22, 0.28),
          color: Color(0xFF5E8B7E),
        ),
        CanvasEntity(
          id: 'A02',
          name: 'Bahia de interruptores',
          type: 'Electrica',
          status: 'Alerta',
          owner: 'Operaciones Norte',
          notes: 'Anomalia termica registrada.',
          position: Offset(0.62, 0.22),
          color: Color(0xFFE05F5C),
        ),
        CanvasEntity(
          id: 'A03',
          name: 'Estacion de bombas',
          type: 'Hidraulica',
          status: 'Activa',
          owner: 'Equipo Delta',
          notes: 'Calibracion de caudal actualizada.',
          position: Offset(0.32, 0.62),
          color: Color(0xFF3A6EA5),
        ),
        CanvasEntity(
          id: 'A04',
          name: 'Sala de filtros',
          type: 'Proceso',
          status: 'Planificada',
          owner: 'Equipo de preparacion',
          notes: 'Esperando envio de repuestos.',
          position: Offset(0.7, 0.66),
          color: Color(0xFFF2A541),
        ),
        CanvasEntity(
          id: 'A05',
          name: 'Modulo de control',
          type: 'Automatizacion',
          status: 'Activa',
          owner: 'Estudio 4',
          notes: 'Actualizacion de firmware pendiente.',
          position: Offset(0.48, 0.45),
          color: Color(0xFF1F7A8C),
        ),
      ];
}
