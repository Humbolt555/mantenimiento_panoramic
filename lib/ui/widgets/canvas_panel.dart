import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/canvas_entity.dart';
import 'canvas_grid_painter.dart';
import 'canvas_tag.dart';
import 'entity_marker.dart';

class CanvasPanel extends StatelessWidget {
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
        const extraPadding = 0.25;
        const maxExtent = 2.5;
        var maxDx = 1.0;
        var maxDy = 1.0;
        for (final entity in entities) {
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

        return Center(
          child: SizedBox(
            width: canvasWidth,
            height: canvasHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: InteractiveViewer(
                constrained: true,
                panEnabled: canPan,
                scaleEnabled: true,
                minScale:1.0,
                maxScale: 4.0,
                boundaryMargin: const EdgeInsets.all(120),
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
                                colorScheme.primary.withValues(alpha: 0.95),
                                colorScheme.primary.withValues(alpha: 0.78),
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
                            lineColor: Colors.white.withValues(alpha: 0.12),
                            accentColor: colorScheme.tertiary.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                      ...entities.map((entity) {
                        return EntityMarker(
                          entity: entity,
                          viewportSize: viewportSize,
                          virtualSize: virtualSize,
                          onTap: () => onEdit(entity),
                          onPanUpdate: (delta) =>
                              onDrag(entity.id, delta, viewportSize),
                        );
                      }),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: CanvasTag(
                          text: filterActive
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
