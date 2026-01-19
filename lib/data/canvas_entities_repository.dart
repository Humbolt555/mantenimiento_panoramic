import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/canvas_entity.dart';
import '../models/entity_options.dart';

class CanvasEntitiesRepository {
  CanvasEntitiesRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  static const _userCollection = 'users';
  static const _canvasCollection = 'canvas';
  static const _entitiesDocument = 'canvas_state';
  static const _optionsDocument = 'options';

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<List<CanvasEntity>> fetchEntities() async {
    final user = _auth.currentUser;
    if (user == null) {
      return _seedEntities;
    }
    try {
      final snapshot = await _firestore
          .collection(_userCollection)
          .doc(user.uid)
          .collection(_canvasCollection)
          .doc(_entitiesDocument)
          .get();
      final data = snapshot.data();
      final raw = data?['entities'];
      if (raw is List) {
        return raw
            .map((item) => CanvasEntity.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      await saveEntities(_seedEntities);
      return _seedEntities;
    } catch (_) {
      return _seedEntities;
    }
  }

  Future<void> saveEntities(List<CanvasEntity> entities) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }
    await _firestore
        .collection(_userCollection)
        .doc(user.uid)
        .collection(_canvasCollection)
        .doc(_entitiesDocument)
        .set({
      'entities': entities.map((entity) => entity.toJson()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<EntityOptions> fetchOptions() async {
    final user = _auth.currentUser;
    if (user == null) {
      return _seedOptions;
    }
    try {
      final snapshot = await _firestore
          .collection(_userCollection)
          .doc(user.uid)
          .collection(_canvasCollection)
          .doc(_optionsDocument)
          .get();
      final data = snapshot.data();
      if (data == null || data.isEmpty) {
        await saveOptions(_seedOptions);
        return _seedOptions;
      }
      final options = EntityOptions.fromJson(data);
      if (options.statuses.isEmpty || options.categories.isEmpty) {
        final merged = EntityOptions(
          statuses:
              options.statuses.isEmpty ? _seedOptions.statuses : options.statuses,
          categories: options.categories.isEmpty
              ? _seedOptions.categories
              : options.categories,
        );
        await saveOptions(merged);
        return merged;
      }
      return options;
    } catch (_) {
      return _seedOptions;
    }
  }

  Future<void> saveOptions(EntityOptions options) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }
    await _firestore
        .collection(_userCollection)
        .doc(user.uid)
        .collection(_canvasCollection)
        .doc(_optionsDocument)
        .set(options.toJson(), SetOptions(merge: true));
  }

  EntityOptions get _seedOptions => const EntityOptions(
        statuses: [
          'Activa',
          'Alerta',
          'Planificada',
        ],
        categories: [
          'Mecanica',
          'Electrica',
          'Hidraulica',
          'Proceso',
          'Automatizacion',
          'Inspeccion',
        ],
      );

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
