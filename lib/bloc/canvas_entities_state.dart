import 'package:equatable/equatable.dart';

import '../models/canvas_entity.dart';

enum CanvasEntitiesStatus {
  initial,
  loading,
  ready,
  failure,
}

class CanvasEntitiesState extends Equatable {
  const CanvasEntitiesState({
    this.status = CanvasEntitiesStatus.initial,
    this.entities = const [],
    this.statusOptions = const [],
    this.categoryOptions = const [],
    this.filterText = '',
    this.pendingEditorEntity,
  });

  final CanvasEntitiesStatus status;
  final List<CanvasEntity> entities;
  final List<String> statusOptions;
  final List<String> categoryOptions;
  final String filterText;
  final CanvasEntity? pendingEditorEntity;

  CanvasEntitiesState copyWith({
    CanvasEntitiesStatus? status,
    List<CanvasEntity>? entities,
    List<String>? statusOptions,
    List<String>? categoryOptions,
    String? filterText,
    CanvasEntity? pendingEditorEntity,
    bool clearPendingEditor = false,
  }) {
    return CanvasEntitiesState(
      status: status ?? this.status,
      entities: entities ?? this.entities,
      statusOptions: statusOptions ?? this.statusOptions,
      categoryOptions: categoryOptions ?? this.categoryOptions,
      filterText: filterText ?? this.filterText,
      pendingEditorEntity:
          clearPendingEditor ? null : pendingEditorEntity ?? this.pendingEditorEntity,
    );
  }

  List<CanvasEntity> get filteredEntities {
    if (filterText.trim().isEmpty) {
      return entities;
    }
    final query = filterText.toLowerCase();
    return entities.where((entity) {
      return entity.name.toLowerCase().contains(query) ||
          entity.type.toLowerCase().contains(query) ||
          entity.status.toLowerCase().contains(query) ||
          entity.owner.toLowerCase().contains(query) ||
          entity.notes.toLowerCase().contains(query);
    }).toList();
  }

  bool get filterActive => filterText.trim().isNotEmpty;

  @override
  List<Object?> get props => [
        status,
        entities,
        statusOptions,
        categoryOptions,
        filterText,
        pendingEditorEntity,
      ];
}
