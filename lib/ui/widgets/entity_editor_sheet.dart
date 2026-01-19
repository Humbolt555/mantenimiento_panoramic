import 'package:flutter/material.dart';

import '../../models/canvas_entity.dart';

class EntityEditorSheet extends StatefulWidget {
  const EntityEditorSheet({
    super.key,
    required this.entity,
    required this.statusOptions,
    required this.categoryOptions,
    required this.onDelete,
  });

  final CanvasEntity entity;
  final List<String> statusOptions;
  final List<String> categoryOptions;
  final VoidCallback onDelete;

  @override
  State<EntityEditorSheet> createState() => _EntityEditorSheetState();
}

class _EntityEditorSheetState extends State<EntityEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ownerController;
  late final TextEditingController _notesController;
  late String? _selectedCategory;
  late String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.entity.name);
    _ownerController = TextEditingController(text: widget.entity.owner);
    _notesController = TextEditingController(text: widget.entity.notes);
    _selectedCategory = widget.entity.type;
    _selectedStatus = widget.entity.status;
    if ((_selectedCategory == null || _selectedCategory!.trim().isEmpty) &&
        widget.categoryOptions.isNotEmpty) {
      _selectedCategory = widget.categoryOptions.first;
    }
    if ((_selectedStatus == null || _selectedStatus!.trim().isEmpty) &&
        widget.statusOptions.isNotEmpty) {
      _selectedStatus = widget.statusOptions.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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
        type: _selectedCategory?.trim() ?? '',
        status: _selectedStatus?.trim() ?? '',
        owner: _ownerController.text.trim(),
        notes: _notesController.text.trim(),
      ),
    );
  }

  List<String> _optionsWithCurrent(List<String> options, String? currentValue) {
    final normalized = options.map((value) => value.trim()).where((value) {
      return value.isNotEmpty;
    }).toList();
    final current = currentValue?.trim();
    if (current != null &&
        current.isNotEmpty &&
        !normalized.any((item) => item.toLowerCase() == current.toLowerCase())) {
      normalized.insert(0, current);
    }
    return normalized;
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
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _optionsWithCurrent(
                  widget.categoryOptions,
                  _selectedCategory,
                ).contains(_selectedCategory)
                    ? _selectedCategory
                    : null,
                items: _optionsWithCurrent(
                  widget.categoryOptions,
                  _selectedCategory,
                ).map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Categoria'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Selecciona una categoria.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _optionsWithCurrent(
                  widget.statusOptions,
                  _selectedStatus,
                ).contains(_selectedStatus)
                    ? _selectedStatus
                    : null,
                items: _optionsWithCurrent(
                  widget.statusOptions,
                  _selectedStatus,
                ).map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Estado'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Selecciona un estado.';
                  }
                  return null;
                },
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
