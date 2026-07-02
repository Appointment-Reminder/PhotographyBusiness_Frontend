import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/core/presentation/widgets/atoms/progress_bar.dart';
import 'package:photography_business_frontend/core/utils/field_map_serializer.dart';
import 'package:photography_business_frontend/dev/fixtures.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/jotform_matrix_state.dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/jotform/webhook_config_panel.dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/jotform/webhook_matrix_card..dart';

import '../../../../../dev/main_dev.dart';
import 'matrix_member_row..dart';

class JotformMatrixView extends ConsumerStatefulWidget {
  final int businessId;

  const JotformMatrixView({
    super.key,
    required this.businessId,
  });

  @override
  ConsumerState<JotformMatrixView> createState() => _JotformMatrixViewState();
}

class _JotformMatrixViewState extends ConsumerState<JotformMatrixView> {

  // ── Local UI state (both modes) ───────────────────────────────
  final Set<String> _collapsedIds   = {};
  String? _activeMemberId;
  String? _activeCategoryId;

  // ── Dev mode fake data ────────────────────────────────────────
  final _fakeMembers = const [
    MatrixMemberData(id: 'm1', name: 'Aurelie Fontaine', email: 'aurelie@studio.fr', initials: 'AF'),
    MatrixMemberData(id: 'm2', name: 'Jonas Berger',     email: 'jonas@studio.fr',   initials: 'JB'),
    MatrixMemberData(id: 'm3', name: 'Camille Rousseau', email: 'camille@studio.fr', initials: 'CR'),
    MatrixMemberData(id: 'm4', name: 'Diego Marín',      email: 'diego@studio.fr',   initials: 'DM'),
    MatrixMemberData(id: 'm5', name: 'Yuki Tanaka',      email: 'yuki@studio.fr',    initials: 'YT'),
  ];

  final _fakeCategories = const [
    MatrixCategoryData(id: 'c1', name: 'Wedding',   color: Color(0xFFF59E0B)),
    MatrixCategoryData(id: 'c2', name: 'Portrait',  color: Color(0xFF8B5CF6)),
    MatrixCategoryData(id: 'c3', name: 'Corporate', color: Color(0xFF3B82F6)),
    MatrixCategoryData(id: 'c4', name: 'Editorial', color: Color(0xFF10B981)),
    MatrixCategoryData(id: 'c5', name: 'Event',     color: Color(0xFFF43F5E)),
  ];

  // In dev mode we track configs locally
  final Map<String, Set<String>>           _devConfiguredMap = {};
  final Map<String, Map<String, WebhookConfig>> _devConfigs  = {};

  // ── Lifecycle ─────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    Future.microtask(() =>
        ref.read(jotformMatrixNotifierProvider.notifier).loadForBusiness(widget.businessId));

  }

  // ── Converters: domain → display ──────────────────────────────
  List<MatrixMemberData> _toMatrixMembers(JotformMatrixState s) {
    return s.members.map((m) => MatrixMemberData(
      id:       m.id.toString(),
      name:     m.userName  ?? 'Unknown',
      email:    m.userEmail ?? '',
      initials: _initials(m.userName ?? 'U'),
    )).toList();
  }

  List<MatrixCategoryData> _toMatrixCategories(JotformMatrixState s) {
    return s.categories.map((c) => MatrixCategoryData(
      id:    c.id.toString(),
      name:  c.name,
      color: _paletteColor(c.id),
    )).toList();
  }

  // ── Helpers ───────────────────────────────────────────────────
  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, min(2, name.length)).toUpperCase();
  }

  static const _palette = [
    Color(0xFFF59E0B), Color(0xFF8B5CF6), Color(0xFF3B82F6),
    Color(0xFF10B981), Color(0xFFF43F5E), Color(0xFF06B6D4),
    Color(0xFFEF4444), Color(0xFF84CC16), Color(0xFFF97316),
    Color(0xFF6366F1),
  ];

  Color _paletteColor(int id) => _palette[id % _palette.length];

  /// Real webhook URL from form entity
  String _realWebhookUrl(int memberId, int categoryId) {
    final form = ref.read(jotformMatrixNotifierProvider).findForm(memberId, categoryId);
    if (form != null) {
      return 'https://hooks.jotform.com/webhook/${form.webhookToken}';
    }
    // form not created yet — URL will be assigned after creation
    return 'Will be generated on save';
  }

  /// Fake webhook URL for dev mode
  String _fakeWebhookUrl(String memberId, String categoryId) =>
      'https://hooks.jotform.com/webhook/${memberId}_${categoryId}_fixture';

  /// Get existing WebhookConfig from a form entity for pre-filling the panel
  WebhookConfig? _existingConfig(String memberId, String categoryId) {
    final form = ref.read(jotformMatrixNotifierProvider)
        .findForm(int.parse(memberId), int.parse(categoryId));
    if (form == null) return null;
    return WebhookConfig(
      webhookUrl: 'https://hooks.jotform.com/webhook/${form.webhookToken}',
      fieldMappings: FieldMapSerializer.deserialize(form.jotformFieldMap),
    );
  }

  // ── Actions ───────────────────────────────────────────────────
  void _openCell(String memberId, String categoryId) => setState(() {
    _activeMemberId   = memberId;
    _activeCategoryId = categoryId;
  });

  void _closePanel() => setState(() {
    _activeMemberId   = null;
    _activeCategoryId = null;
  });

  void _toggleCollapse(String memberId) => setState(() {
    if (_collapsedIds.contains(memberId)) {
      _collapsedIds.remove(memberId);
    } else {
      _collapsedIds.add(memberId);
    }
  });

  Future<void> _saveConfig(
      String memberId,
      String categoryId,
      WebhookConfig config,
      ) async {

    // Real: call API via consolidated notifier
    await ref.read(jotformMatrixNotifierProvider.notifier).saveForm(
      businessId:      widget.businessId,
      memberId:        int.parse(memberId),
      categoryId:      int.parse(categoryId),
      jotformFieldMap: FieldMapSerializer.serialize(config.fieldMappings),
    );
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {


    final state = ref.watch(jotformMatrixNotifierProvider);

    if (state.isLoading && state.members.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return _buildError(
        state.error!,
            () => ref.read(jotformMatrixNotifierProvider.notifier).loadForBusiness(widget.businessId),
      );
    }

    if (state.members.isEmpty || state.categories.isEmpty) {
      return const Center(child: Text('No team members or categories yet'));
    }

    return _buildContent(
      members:       _toMatrixMembers(state),
      categories:    _toMatrixCategories(state),
      configuredMap: state.configuredMap,
    );
  }

  Widget _buildContent({
    required List<MatrixMemberData> members,
    required List<MatrixCategoryData> categories,
    required Map<String, Set<String>> configuredMap,
  }) {
    final totalCount      = members.length * categories.length;
    final configuredCount = configuredMap.values
        .fold(0, (sum, set) => sum + set.length);
    final showModal = _activeMemberId != null && _activeCategoryId != null;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageHeader(configuredCount, totalCount),
              const SizedBox(height: 16),
              _buildLegend(),
              const SizedBox(height: 16),
              WebhookMatrixCard(
                members:            members,
                categories:         categories,
                configuredMap:      configuredMap,
                collapsedMemberIds: _collapsedIds,
                onCellTap:          _openCell,
                onToggleCollapse:   _toggleCollapse,
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Each cell represents one Jotform webhook · '
                      '${totalCount - configuredCount} remaining to configure',
                  style: AppTextStyles.monoMuted11,
                ),
              ),
            ],
          ),
        ),

        // Modal
        if (showModal)
          Positioned.fill(
            child: WebhookConfigPanel(
              memberName:    members.firstWhere((m) => m.id == _activeMemberId).name,
              memberEmail:   members.firstWhere((m) => m.id == _activeMemberId).email,
              categoryName:  categories.firstWhere((c) => c.id == _activeCategoryId).name,
              categoryColor: categories.firstWhere((c) => c.id == _activeCategoryId).color,
              webhookUrl: _realWebhookUrl(
                int.parse(_activeMemberId!),
                int.parse(_activeCategoryId!),
              ),
              jotformFields:  Fixtures.jotformFields,
              targetFields:   Fixtures.targetFields,
              existingConfig: _existingConfig(_activeMemberId!, _activeCategoryId!),
              onSave: (config) => _saveConfig(
                _activeMemberId!,
                _activeCategoryId!,
                config,
              ),
              onClose: _closePanel,
            ),
          ),
      ],
    );
  }

  Widget _buildPageHeader(int configured, int total) {
    return Row(
      children: [
        const Icon(Icons.settings, size: 18, color: AppColors.primaryText),
        const SizedBox(width: 10),
        Text('Jotform Webhook Matrix', style: AppTextStyles.heading16),
        const Spacer(),
        ProgressBar(current: configured, total: total),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _LegendItem(color: const Color(0xFF22C55E), filled: true,  label: 'Configured'),
        const SizedBox(width: 20),
        _LegendItem(color: AppColors.mutedText,     filled: false, label: 'Not configured'),
        const Spacer(),
        Text('Click any cell to configure its webhook', style: AppTextStyles.muted12),
      ],
    );
  }

  Widget _buildError(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.mutedText),
          const SizedBox(height: 12),
          Text(message, style: AppTextStyles.muted14),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryText,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Retry', style: AppTextStyles.body14.copyWith(color: AppColors.active)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Legend item ───────────────────────────────────────────────────────────────

class _LegendItem extends StatelessWidget {
  final Color color;
  final bool filled;
  final String label;

  const _LegendItem({
    required this.color,
    required this.filled,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: filled ? color : Colors.transparent,
            shape: BoxShape.circle,
            border: filled
                ? null
                : Border.all(color: color, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.muted12),
      ],
    );
  }
}