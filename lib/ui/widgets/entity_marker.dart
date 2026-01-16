import 'package:flutter/material.dart';

import '../../models/canvas_entity.dart';

class EntityMarker extends StatelessWidget {
  const EntityMarker({
    super.key,
    required this.entity,
    required this.viewportSize,
    required this.virtualSize,
    required this.onTap,
    required this.onPanUpdate,
  });

  final CanvasEntity entity;
  final Size viewportSize;
  final Size virtualSize;
  final VoidCallback onTap;
  final ValueChanged<Offset> onPanUpdate;

  @override
  Widget build(BuildContext context) {
    const markerWidth = 150.0;
    const markerHeight = 70.0;
    final left = (entity.position.dx * viewportSize.width) - markerWidth / 2;
    final top = (entity.position.dy * viewportSize.height) - markerHeight / 2;
    final clampedLeft =
        left.clamp(8.0, virtualSize.width - markerWidth - 8.0);
    final clampedTop =
        top.clamp(8.0, virtualSize.height - markerHeight - 8.0);

    return Positioned(
      left: clampedLeft,
      top: clampedTop,
      child: GestureDetector(
        onTap: onTap,
        onPanUpdate: (details) => onPanUpdate(details.delta),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: markerWidth,
          height: markerHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                entity.color.withValues(alpha: 0.98),
                entity.color.withValues(alpha: 0.68),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                color: entity.color.withValues(alpha: 0.4),
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entity.name,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${entity.type} - ${entity.status}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
