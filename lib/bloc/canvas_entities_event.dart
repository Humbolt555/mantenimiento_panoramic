import 'package:equatable/equatable.dart';
import 'dart:ui';

import '../models/canvas_entity.dart';

abstract class CanvasEntitiesEvent extends Equatable {
  const CanvasEntitiesEvent();

  @override
  List<Object?> get props => [];
}

class CanvasEntitiesLoadRequested extends CanvasEntitiesEvent {
  const CanvasEntitiesLoadRequested();
}

class CanvasFilterChanged extends CanvasEntitiesEvent {
  const CanvasFilterChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class CanvasEntityAdded extends CanvasEntitiesEvent {
  const CanvasEntityAdded();
}

class CanvasEntityUpdated extends CanvasEntitiesEvent {
  const CanvasEntityUpdated(this.entity);

  final CanvasEntity entity;

  @override
  List<Object?> get props => [entity];
}

class CanvasEntityDeleted extends CanvasEntitiesEvent {
  const CanvasEntityDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class CanvasEntityPositionUpdated extends CanvasEntitiesEvent {
  const CanvasEntityPositionUpdated({
    required this.id,
    required this.delta,
    required this.canvasSize,
  });

  final String id;
  final Offset delta;
  final Size canvasSize;

  @override
  List<Object?> get props => [id, delta, canvasSize];
}

class CanvasEditorDismissed extends CanvasEntitiesEvent {
  const CanvasEditorDismissed();
}
