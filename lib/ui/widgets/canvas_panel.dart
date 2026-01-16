import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/canvas_entity.dart';
import 'canvas_grid_painter.dart';
import 'canvas_tag.dart';
import 'entity_marker.dart';

class CanvasPanel extends StatefulWidget {
  const CanvasPanel({
    super.key,
    required this.entities,
    required this.onEdit,
    required this.onDrag,
    required this.filterActive,
  });

  final List<CanvasEntity> entities;
  final ValueChanged<CanvasEntity> onEdit;
  final void Function(String id, Offset delta, Size size) onDrag;
  final bool filterActive;

  @override
  State<CanvasPanel> createState() => _CanvasPanelState();
}

class _CanvasPanelState extends State<CanvasPanel> {
  static const double _minScale = 0.5;
  static const double _maxScale = 4.0;

  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetView() {
    _transformationController.value = Matrix4.identity();
  }

  void _applyScale(double scaleDelta, Offset focalPoint) {
    final matrix = _transformationController.value;
    final currentScale = matrix.getMaxScaleOnAxis();
    final nextScale =
        (currentScale * scaleDelta).clamp(_minScale, _maxScale).toDouble();
    final scaleFactor = nextScale / currentScale;
    if (scaleFactor == 1.0) {
      return;
    }
    final transform = Matrix4.identity()
      ..translate(focalPoint.dx, focalPoint.dy)
      ..scale(scaleFactor)
      ..translate(-focalPoint.dx, -focalPoint.dy);
    _transformationController.value = transform * matrix;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        const targetRatio = 1.6;
        double canvasWidth = maxWidth;
        double canvasHeight = maxHeight;
        if (maxWidth / maxHeight > targetRatio) {
          canvasWidth = maxHeight * targetRatio;
        } else {
          canvasHeight = maxWidth / targetRatio;
        }
        const extraPadding = 0.5;
        const maxExtent = 4.0;
        var maxDx = 1.0;
        var maxDy = 1.0;
        for (final entity in widget.entities) {
          maxDx = max(maxDx, entity.position.dx);
          maxDy = max(maxDy, entity.position.dy);
        }
        final widthFactor = (maxDx + extraPadding).clamp(1.0, maxExtent);
        final heightFactor = (maxDy + extraPadding).clamp(1.0, maxExtent);
        final viewportSize = Size(canvasWidth, canvasHeight);
        final virtualSize = Size(
          canvasWidth * widthFactor,
          canvasHeight * heightFactor,
        );
        final canPan = widthFactor > 1.0 || heightFactor > 1.0;
        final focalPoint = Offset(canvasWidth / 2, canvasHeight / 2);

        return Center(
          child: SizedBox(
            width: canvasWidth,
            height: canvasHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: InteractiveViewer(
                      constrained: false,
                      panEnabled: canPan,
                      scaleEnabled: true,
                      minScale: _minScale,
                      maxScale: _maxScale,
                      boundaryMargin: const EdgeInsets.all(120),
                      transformationController: _transformationController,
                      child: SizedBox(
                        width: virtualSize.width,
                        height: virtualSize.height,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colorScheme.primary
                                          .withValues(alpha: 0.95),
                                      colorScheme.primary
                                          .withValues(alpha: 0.78),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: CustomPaint(
                                painter: CanvasGridPainter(
                                  lineColor: Colors.white
                                      .withValues(alpha: 0.12),
                                  accentColor: colorScheme.tertiary
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                            ),
                            ...widget.entities.map((entity) {
                              return EntityMarker(
                                entity: entity,
                                viewportSize: viewportSize,
                                virtualSize: virtualSize,
                                onTap: () => widget.onEdit(entity),
                                onPanUpdate: (delta) =>
                                    widget.onDrag(entity.id, delta, viewportSize),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: CanvasTag(
                      text: widget.filterActive
                          ? 'Vista filtrada'
                          : 'Tablero de ubicacion',
                    ),
                  ),
                  const Positioned(
                    bottom: 16,
                    right: 16,
                    child: CanvasTag(
                      text: 'Arrastra para mover - Toca para editar',
                      light: true,
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: _CanvasControls(
                      onZoomIn: () => _applyScale(1.2, focalPoint),
                      onZoomOut: () => _applyScale(1 / 1.2, focalPoint),
                      onReset: _resetView,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CanvasControls extends StatelessWidget {
  const _CanvasControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface.withValues(alpha: 0.85),
      elevation: 6,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              tooltip: 'Alejar',
              onPressed: onZoomOut,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Acercar',
              onPressed: onZoomIn,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Restablecer',
              onPressed: onReset,
            ),
          ],
        ),
      ),
    );
  }
}
