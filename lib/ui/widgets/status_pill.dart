import 'package:flutter/material.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final normalized = status.toLowerCase();
    Color pillColor;
    if (normalized.contains('alerta') || normalized.contains('problema')) {
      pillColor = const Color(0xFFE05F5C);
    } else if (normalized.contains('planificada') ||
        normalized.contains('planificado')) {
      pillColor = const Color(0xFFF2A541);
    } else {
      pillColor = const Color(0xFF5E8B7E);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: pillColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: pillColor.withValues(alpha: 0.6)),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
