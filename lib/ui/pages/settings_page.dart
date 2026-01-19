import 'package:flutter/material.dart';

import '../../models/entity_options.dart';

class EntitySettingsPage extends StatefulWidget {
  const EntitySettingsPage({
    super.key,
    required this.statusOptions,
    required this.categoryOptions,
  });

  final List<String> statusOptions;
  final List<String> categoryOptions;

  @override
  State<EntitySettingsPage> createState() => _EntitySettingsPageState();
}

class _EntitySettingsPageState extends State<EntitySettingsPage> {
  late List<String> _statuses;
  late List<String> _categories;
  final _statusController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _statuses = List<String>.from(widget.statusOptions);
    _categories = List<String>.from(widget.categoryOptions);
  }

  @override
  void dispose() {
    _statusController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _addOption({
    required TextEditingController controller,
    required List<String> target,
    required String duplicateMessage,
  }) {
    final value = controller.text.trim();
    if (value.isEmpty) {
      return;
    }
    final exists =
        target.any((item) => item.toLowerCase() == value.toLowerCase());
    if (exists) {
      _showMessage(duplicateMessage);
      return;
    }
    setState(() {
      target.add(value);
      controller.clear();
    });
  }

  void _removeOption(List<String> target, String value) {
    setState(() {
      target.removeWhere((item) => item == value);
    });
  }

  void _save() {
    if (_statuses.isEmpty) {
      _showMessage('Agrega al menos un estado.');
      return;
    }
    if (_categories.isEmpty) {
      _showMessage('Agrega al menos una categoria.');
      return;
    }
    Navigator.of(context).pop(
      EntityOptions(
        statuses: _statuses,
        categories: _categories,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuracion de entidades'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Personaliza los valores disponibles al crear o editar entidades.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 16),
            _OptionsSection(
              title: 'Estados',
              hintText: 'Nuevo estado',
              controller: _statusController,
              options: _statuses,
              onAdd: () => _addOption(
                controller: _statusController,
                target: _statuses,
                duplicateMessage: 'Ese estado ya existe.',
              ),
              onRemove: (value) => _removeOption(_statuses, value),
            ),
            const SizedBox(height: 20),
            _OptionsSection(
              title: 'Categorias',
              hintText: 'Nueva categoria',
              controller: _categoryController,
              options: _categories,
              onAdd: () => _addOption(
                controller: _categoryController,
                target: _categories,
                duplicateMessage: 'Esa categoria ya existe.',
              ),
              onRemove: (value) => _removeOption(_categories, value),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Guardar configuracion'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionsSection extends StatelessWidget {
  const _OptionsSection({
    required this.title,
    required this.hintText,
    required this.controller,
    required this.options,
    required this.onAdd,
    required this.onRemove,
  });

  final String title;
  final String hintText;
  final TextEditingController controller;
  final List<String> options;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options
                .map(
                  (option) => InputChip(
                    label: Text(option),
                    onDeleted: () => onRemove(option),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: hintText,
                  ),
                  onSubmitted: (_) => onAdd(),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: onAdd,
                child: const Text('Agregar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
