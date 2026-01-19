import 'dart:async';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/canvas_entities_repository.dart';
import '../models/canvas_entity.dart';
import '../models/entity_options.dart';
import 'canvas_entities_event.dart';
import 'canvas_entities_state.dart';

class CanvasEntitiesBloc
    extends Bloc<CanvasEntitiesEvent, CanvasEntitiesState> {
  CanvasEntitiesBloc({required CanvasEntitiesRepository repository})
      : _repository = repository,
        super(const CanvasEntitiesState()) {
    on<CanvasEntitiesLoadRequested>(_onLoadRequested);
    on<CanvasFilterChanged>(_onFilterChanged);
    on<CanvasEntityAdded>(_onEntityAdded);
    on<CanvasEntityUpdated>(_onEntityUpdated);
    on<CanvasEntityDeleted>(_onEntityDeleted);
    on<CanvasEntityPositionUpdated>(_onPositionUpdated);
    on<CanvasEditorDismissed>(_onEditorDismissed);
    on<CanvasOptionsUpdated>(_onOptionsUpdated);
  }

  final CanvasEntitiesRepository _repository;
  Timer? _saveDebounce;

  static const List<Color> _palette = [
    Color(0xFF5E8B7E),
    Color(0xFF3A6EA5),
    Color(0xFFE05F5C),
    Color(0xFF7F5AF0),
    Color(0xFFF2A541),
    Color(0xFF1F7A8C),
  ];

  static const List<String> _fallbackStatuses = [
    'Activa',
    'Alerta',
    'Planificada',
  ];

  static const List<String> _fallbackCategories = [
    'Inspeccion',
  ];

  Future<void> _onLoadRequested(
    CanvasEntitiesLoadRequested event,
    Emitter<CanvasEntitiesState> emit,
  ) async {
    emit(state.copyWith(status: CanvasEntitiesStatus.loading));
    try {
      final results = await Future.wait([
        _repository.fetchEntities(),
        _repository.fetchOptions(),
      ]);
      final entities = results[0] as List<CanvasEntity>;
      final options = results[1] as EntityOptions;
      final normalizedStatuses =
          _normalizeOptions(options.statuses, fallback: _fallbackStatuses);
      final normalizedCategories =
          _normalizeOptions(options.categories, fallback: _fallbackCategories);
      emit(state.copyWith(
        status: CanvasEntitiesStatus.ready,
        entities: entities,
        statusOptions: normalizedStatuses,
        categoryOptions: normalizedCategories,
      ));
    } catch (_) {
      emit(state.copyWith(status: CanvasEntitiesStatus.failure));
    }
  }

  void _onFilterChanged(
    CanvasFilterChanged event,
    Emitter<CanvasEntitiesState> emit,
  ) {
    emit(state.copyWith(filterText: event.value));
  }

  Future<void> _onEntityAdded(
    CanvasEntityAdded event,
    Emitter<CanvasEntitiesState> emit,
  ) async {
    final color = _palette[state.entities.length % _palette.length];
    final statusOptions =
        _normalizeOptions(state.statusOptions, fallback: _fallbackStatuses);
    final categoryOptions =
        _normalizeOptions(state.categoryOptions, fallback: _fallbackCategories);
    final newEntity = CanvasEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Activo nuevo ${state.entities.length + 1}',
      type: categoryOptions.first,
      status: statusOptions.first,
      owner: 'Sin asignar',
      notes: 'Toca para editar la descripcion.',
      position: const Offset(0.5, 0.5),
      color: color,
    );
    final updatedEntities = [...state.entities, newEntity];
    await _repository.saveEntities(updatedEntities);
    emit(state.copyWith(
      entities: updatedEntities,
      pendingEditorEntity: newEntity,
    ));
  }

  Future<void> _onEntityUpdated(
    CanvasEntityUpdated event,
    Emitter<CanvasEntitiesState> emit,
  ) async {
    final index = state.entities.indexWhere((entity) => entity.id == event.entity.id);
    if (index == -1) {
      emit(state.copyWith(clearPendingEditor: true));
      return;
    }
    final updatedEntities = [...state.entities];
    updatedEntities[index] = event.entity;
    await _repository.saveEntities(updatedEntities);
    emit(state.copyWith(
      entities: updatedEntities,
      clearPendingEditor: true,
    ));
  }

  Future<void> _onEntityDeleted(
    CanvasEntityDeleted event,
    Emitter<CanvasEntitiesState> emit,
  ) async {
    final updatedEntities =
        state.entities.where((entity) => entity.id != event.id).toList();
    if (updatedEntities.length == state.entities.length) {
      emit(state.copyWith(clearPendingEditor: true));
      return;
    }
    await _repository.saveEntities(updatedEntities);
    emit(state.copyWith(
      entities: updatedEntities,
      clearPendingEditor: true,
    ));
  }

  Future<void> _onPositionUpdated(
    CanvasEntityPositionUpdated event,
    Emitter<CanvasEntitiesState> emit,
  ) async {
    final index = state.entities.indexWhere((entity) => entity.id == event.id);
    if (index == -1) {
      return;
    }
    final entity = state.entities[index];
    final newDx =
        (entity.position.dx * event.canvasSize.width + event.delta.dx) /
            event.canvasSize.width;
    final newDy =
        (entity.position.dy * event.canvasSize.height + event.delta.dy) /
            event.canvasSize.height;
    const maxExtent = 4.0;
    final updatedEntity = entity.copyWith(
      position: Offset(
        newDx.clamp(0.0, maxExtent),
        newDy.clamp(0.0, maxExtent),
      ),
    );
    final updatedEntities = [...state.entities];
    updatedEntities[index] = updatedEntity;
    emit(state.copyWith(entities: updatedEntities));
    _scheduleSave(updatedEntities);
  }

  void _onEditorDismissed(
    CanvasEditorDismissed event,
    Emitter<CanvasEntitiesState> emit,
  ) {
    emit(state.copyWith(clearPendingEditor: true));
  }

  Future<void> _onOptionsUpdated(
    CanvasOptionsUpdated event,
    Emitter<CanvasEntitiesState> emit,
  ) async {
    final normalizedStatuses =
        _normalizeOptions(event.statusOptions, fallback: _fallbackStatuses);
    final normalizedCategories =
        _normalizeOptions(event.categoryOptions, fallback: _fallbackCategories);
    await _repository.saveOptions(
      EntityOptions(
        statuses: normalizedStatuses,
        categories: normalizedCategories,
      ),
    );
    emit(state.copyWith(
      statusOptions: normalizedStatuses,
      categoryOptions: normalizedCategories,
    ));
  }

  List<String> _normalizeOptions(
    List<String> options, {
    required List<String> fallback,
  }) {
    final normalized = <String>[];
    for (final option in options) {
      final value = option.trim();
      if (value.isEmpty) {
        continue;
      }
      final exists =
          normalized.any((item) => item.toLowerCase() == value.toLowerCase());
      if (!exists) {
        normalized.add(value);
      }
    }
    if (normalized.isEmpty) {
      return [...fallback];
    }
    return normalized;
  }

  void _scheduleSave(List<CanvasEntity> entities) {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 300), () {
      unawaited(_repository.saveEntities(entities));
    });
  }

  @override
  Future<void> close() {
    _saveDebounce?.cancel();
    return super.close();
  }
}
