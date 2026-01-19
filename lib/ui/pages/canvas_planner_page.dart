import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../bloc/canvas_entities_bloc.dart';
import '../../bloc/canvas_entities_event.dart';
import '../../bloc/canvas_entities_state.dart';
import '../../models/canvas_entity.dart';
import '../../models/entity_options.dart';
import '../widgets/canvas_panel.dart';
import '../widgets/entity_editor_sheet.dart';
import '../widgets/entity_panel.dart';
import '../widgets/glow_blob.dart';
import '../widgets/header_section.dart';
import 'settings_page.dart';

class CanvasPlannerPage extends StatefulWidget {
  const CanvasPlannerPage({super.key});

  @override
  State<CanvasPlannerPage> createState() => _CanvasPlannerPageState();
}

class _CanvasPlannerPageState extends State<CanvasPlannerPage> {
  final TextEditingController _filterController = TextEditingController();

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  Future<CanvasEntity?> _showEditor(
    CanvasEntity entity, {
    required List<String> statusOptions,
    required List<String> categoryOptions,
  }) {
    return showModalBottomSheet<CanvasEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EntityEditorSheet(
        entity: entity,
        statusOptions: statusOptions,
        categoryOptions: categoryOptions,
        onDelete: () => context
            .read<CanvasEntitiesBloc>()
            .add(CanvasEntityDeleted(entity.id)),
      ),
    );
  }

  void _handleEditorResult(CanvasEntity? updated) {
    if (!mounted || updated == null) {
      return;
    }
    context.read<CanvasEntitiesBloc>().add(CanvasEntityUpdated(updated));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CanvasEntitiesBloc, CanvasEntitiesState>(
      listenWhen: (previous, current) {
        return previous.pendingEditorEntity?.id !=
                current.pendingEditorEntity?.id &&
            current.pendingEditorEntity != null;
      },
      listener: (context, state) async {
        final entity = state.pendingEditorEntity;
        if (entity == null) {
          return;
        }
        final updated = await _showEditor(
          entity,
          statusOptions: state.statusOptions,
          categoryOptions: state.categoryOptions,
        );
        if (!context.mounted) {
          return;
        }
        if (updated != null) {
          context.read<CanvasEntitiesBloc>().add(CanvasEntityUpdated(updated));
        } else {
          context.read<CanvasEntitiesBloc>().add(const CanvasEditorDismissed());
        }
      },
      child: BlocBuilder<CanvasEntitiesBloc, CanvasEntitiesState>(
        builder: (context, state) {
          final colorScheme = Theme.of(context).colorScheme;

          return Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.surface,
                          const Color(0xFFF6E9D6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: -80,
                  left: -60,
                  child: GlowBlob(
                    size: 240,
                    color: Color(0xFFFFD8A8),
                  ),
                ),
                const Positioned(
                  bottom: -120,
                  right: -80,
                  child: GlowBlob(
                    size: 280,
                    color: Color(0xFFC6E6E2),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildContent(context, state),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, CanvasEntitiesState state) {
    if (state.status == CanvasEntitiesStatus.initial ||
        state.status == CanvasEntitiesStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == CanvasEntitiesStatus.failure) {
      return Center(
        child: Text(
          'No se pudieron cargar las entidades guardadas.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    final entities = state.filteredEntities;
    final totalCount = state.entities.length;
    final filteredCount = entities.length;

    final userEmail = FirebaseAuth.instance.currentUser?.email;
    final header = HeaderSection(
      onAdd: () =>
          context.read<CanvasEntitiesBloc>().add(const CanvasEntityAdded()),
      totalCount: totalCount,
      filteredCount: filteredCount,
      userEmail: userEmail,
      onSignOut: () {
        FirebaseAuth.instance.signOut();
      },
      onSettings: () async {
        final updated = await Navigator.of(context).push<EntityOptions>(
          MaterialPageRoute(
            builder: (_) => EntitySettingsPage(
              statusOptions: state.statusOptions,
              categoryOptions: state.categoryOptions,
            ),
          ),
        );
        if (!context.mounted || updated == null) {
          return;
        }
        context.read<CanvasEntitiesBloc>().add(
              CanvasOptionsUpdated(
                statusOptions: updated.statuses,
                categoryOptions: updated.categories,
              ),
            );
      },
    );
    final panel = EntityPanel(
      controller: _filterController,
      filterText: state.filterText,
      totalCount: totalCount,
      filteredCount: filteredCount,
      entities: entities,
      onFilterChanged: (value) =>
          context.read<CanvasEntitiesBloc>().add(CanvasFilterChanged(value)),
      onClearFilter: () {
        _filterController.clear();
        context.read<CanvasEntitiesBloc>().add(const CanvasFilterChanged(''));
      },
      onSelect: (entity) async {
        final updated = await _showEditor(
          entity,
          statusOptions: state.statusOptions,
          categoryOptions: state.categoryOptions,
        );
        _handleEditorResult(updated);
      },
    );
    final canvas = CanvasPanel(
      entities: entities,
      onEdit: (entity) async {
        final updated = await _showEditor(
          entity,
          statusOptions: state.statusOptions,
          categoryOptions: state.categoryOptions,
        );
        _handleEditorResult(updated);
      },
      onDrag: (id, delta, size) => context
          .read<CanvasEntitiesBloc>()
          .add(CanvasEntityPositionUpdated(
            id: id,
            delta: delta,
            canvasSize: size,
          )),
      filterActive: state.filterActive,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1000;

        if (isWide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 18),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(width: 300, child: panel),
                    const SizedBox(width: 20),
                    Expanded(child: canvas),
                  ],
                ),
              ),
            ],
          );
        }

        final panelHeight =
            (constraints.maxHeight * 0.55).clamp(280.0, 420.0).toDouble();
        final canvasHeight =
            (constraints.maxWidth / 1.6).clamp(260.0, 420.0).toDouble();

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            header,
            const SizedBox(height: 18),
            SizedBox(height: panelHeight, child: panel),
            const SizedBox(height: 16),
            SizedBox(height: canvasHeight, child: canvas),
          ],
        );
      },
    );
  }
}
