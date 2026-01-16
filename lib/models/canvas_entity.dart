import 'dart:ui';

class CanvasEntity {
  const CanvasEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.owner,
    required this.notes,
    required this.position,
    required this.color,
  });

  final String id;
  final String name;
  final String type;
  final String status;
  final String owner;
  final String notes;
  final Offset position;
  final Color color;

  CanvasEntity copyWith({
    String? name,
    String? type,
    String? status,
    String? owner,
    String? notes,
    Offset? position,
    Color? color,
  }) {
    return CanvasEntity(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      owner: owner ?? this.owner,
      notes: notes ?? this.notes,
      position: position ?? this.position,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'status': status,
      'owner': owner,
      'notes': notes,
      'position': {
        'dx': position.dx,
        'dy': position.dy,
      },
      'color': color.value,
    };
  }

  factory CanvasEntity.fromJson(Map<String, dynamic> json) {
    final position = json['position'] as Map<String, dynamic>;
    return CanvasEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      owner: json['owner'] as String,
      notes: json['notes'] as String,
      position: Offset(
        (position['dx'] as num).toDouble(),
        (position['dy'] as num).toDouble(),
      ),
      color: Color((json['color'] as num).toInt()),
    );
  }
}
