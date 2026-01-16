import 'package:flutter/material.dart';

import '../../models/canvas_entity.dart';
import 'entity_card.dart';

class EntityPanel extends StatelessWidget {
  const EntityPanel({
    super.key,
    required this.controller,
    required this.filterText,
    required this.totalCount,
    required this.filteredCount,
    required this.entities,
    required this.onFilterChanged,
    required this.onClearFilter,
    required this.onSelect,
  });

  final TextEditingController controller;
  final String filterText;
  final int totalCount;
  final int filteredCount;
  final List<CanvasEntity> entities;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onClearFilter;
  final ValueChanged<CanvasEntity> onSelect;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            blurRadius: 30,
            color: colorScheme.primary.withValues(alpha: 0.08),
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panel de entidades',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Filtra la lista para enfocarte en activos criticos.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            onChanged: onFilterChanged,
            decoration: InputDecoration(
              hintText: 'Buscar nombre, tipo, responsable, estado o descripcion',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: filterText.isEmpty
                  ? null
                  : IconButton(
                      onPressed: onClearFilter,
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Mostrando $filteredCount de $totalCount entidades',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: entities.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final entity = entities[index];
                return EntityCard(
                  entity: entity,
                  onTap: () => onSelect(entity),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
