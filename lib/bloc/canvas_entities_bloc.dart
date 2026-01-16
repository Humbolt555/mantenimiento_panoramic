import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/canvas_entities_repository.dart';
import '../models/canvas_entity.dart';
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
  }

  final CanvasEntitiesRepository _repository;

  static const List<Color> _palette = [
    Color(0xFF5E8B7E),
    Color(0xFF3A6EA5),
    Color(0xFFE05F5C),
    Color(0xFF7F5AF0),
    Color(0xFFF2A541),
    Color(0xFF1F7A8C),
  ];

  Future<void> _onLoadRequested(
    CanvasEntitiesLoadRequested event,
    Emitter<CanvasEntitiesState> emit,
  ) async {
    emit(state.copyWith(status: CanvasEntitiesStatus.loading));
    try {
      final entities = await _repository.fetchEntities();
      emit(state.copyWith(
        status: CanvasEntitiesStatus.ready,
        entities: entities,
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
    final newEntity = CanvasEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Activo nuevo ${state.entities.length + 1}',
      type: 'Inspeccion',
      status: 'Planificada',
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
    const maxExtent = 2.5;
    final updatedEntity = entity.copyWith(
      position: Offset(
        newDx.clamp(0.0, maxExtent),
        newDy.clamp(0.0, maxExtent),
      ),
    );
    final updatedEntities = [...state.entities];
    updatedEntities[index] = updatedEntity;
    await _repository.saveEntities(updatedEntities);
    emit(state.copyWith(entities: updatedEntities));
  }

  void _onEditorDismissed(
    CanvasEditorDismissed event,
    Emitter<CanvasEntitiesState> emit,
  ) {
    emit(state.copyWith(clearPendingEditor: true));
  }
}
