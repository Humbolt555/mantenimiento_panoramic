import 'package:flutter/material.dart';

import 'info_chip.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({
    super.key,
    required this.onAdd,
    required this.totalCount,
    required this.filteredCount,
  });

  final VoidCallback onAdd;
  final int totalCount;
  final int filteredCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mantenimiento Panoramic',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Arrastra tarjetas para ubicar entidades. Toca un marcador para editar.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InfoChip(
                    label: 'Total: $totalCount',
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    textColor: colorScheme.primary,
                  ),
                  InfoChip(
                    label: 'Visibles: $filteredCount',
                    color: colorScheme.secondary.withValues(alpha: 0.2),
                    textColor: colorScheme.secondary,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: onAdd,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Agregar entidad'),
        ),
      ],
    );
  }
}
