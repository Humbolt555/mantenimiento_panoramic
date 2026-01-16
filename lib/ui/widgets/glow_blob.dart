import 'package:flutter/material.dart';

class GlowBlob extends StatelessWidget {
  const GlowBlob({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.7),
        boxShadow: [
          BoxShadow(
            blurRadius: 80,
            color: color.withValues(alpha: 0.45),
          ),
        ],
      ),
    );
  }
}
