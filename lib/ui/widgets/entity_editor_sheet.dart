import 'package:flutter/material.dart';

import '../../models/canvas_entity.dart';

class EntityEditorSheet extends StatefulWidget {
  const EntityEditorSheet({
    super.key,
    required this.entity,
    required this.onDelete,
  });

  final CanvasEntity entity;
  final VoidCallback onDelete;

  @override
  State<EntityEditorSheet> createState() => _EntityEditorSheetState();
}

class _EntityEditorSheetState extends State<EntityEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _typeController;
  late final TextEditingController _statusController;
  late final TextEditingController _ownerController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.entity.name);
    _typeController = TextEditingController(text: widget.entity.type);
    _statusController = TextEditingController(text: widget.entity.status);
    _ownerController = TextEditingController(text: widget.entity.owner);
    _notesController = TextEditingController(text: widget.entity.notes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _statusController.dispose();
    _ownerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.pop(
      context,
      widget.entity.copyWith(
        name: _nameController.text.trim(),
        type: _typeController.text.trim(),
        status: _statusController.text.trim(),
        owner: _ownerController.text.trim(),
        notes: _notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: widget.entity.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Editar entidad',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'El nombre es obligatorio'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _typeController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _statusController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Estado'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ownerController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Responsable'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Descripcion'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Guardar cambios'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    widget.onDelete();
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Eliminar entidad'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
