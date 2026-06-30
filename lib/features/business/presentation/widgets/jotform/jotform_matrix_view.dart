import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/atoms/progress_bar.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/dev/Fixtures.dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/jotform/matrix_member_row..dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/jotform/webhook_config_panel.dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/jotform/webhook_matrix_card..dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const _jotformFields = [
  'q1_name', 'q2_email', 'q3_phone',
  'q4_date', 'q5_location', 'q6_budget', 'q7_notes',
];

const _targetFields = [
  'client_name', 'client_email', 'phone',
  'shoot_date', 'location', 'budget', 'notes', 'reference_id',
];

// ─── View ─────────────────────────────────────────────────────────────────────

class JotformMatrixView extends StatefulWidget {
  const JotformMatrixView({super.key});

  @override
  State<JotformMatrixView> createState() => _JotformMatrixViewState();
}

class _JotformMatrixViewState extends State<JotformMatrixView> {
  final _members = const [
    MatrixMemberData(id: 'm1', name: 'Aurelie Fontaine', email: 'aurelie@studio.fr', initials: 'AF'),
    MatrixMemberData(id: 'm2', name: 'Jonas Berger',     email: 'jonas@studio.fr',   initials: 'JB'),
    MatrixMemberData(id: 'm3', name: 'Camille Rousseau', email: 'camille@studio.fr', initials: 'CR'),
    MatrixMemberData(id: 'm4', name: 'Diego Marín',      email: 'diego@studio.fr',   initials: 'DM'),
    MatrixMemberData(id: 'm5', name: 'Yuki Tanaka',      email: 'yuki@studio.fr',    initials: 'YT'),
  ];

  final _categories = const [
    MatrixCategoryData(id: 'c1', name: 'Wedding',   color: Color(0xFFF59E0B)),
    MatrixCategoryData(id: 'c2', name: 'Portrait',  color: Color(0xFF8B5CF6)),
    MatrixCategoryData(id: 'c3', name: 'Corporate', color: Color(0xFF3B82F6)),
    MatrixCategoryData(id: 'c4', name: 'Editorial', color: Color(0xFF10B981)),
    MatrixCategoryData(id: 'c5', name: 'Event',     color: Color(0xFFF43F5E)),
  ];

  // memberId → Set<categoryId>
  final Map<String, Set<String>> _configuredMap = {};

  // memberId → categoryId → WebhookConfig
  final Map<String, Map<String, WebhookConfig>> _configs = {};

  final Set<String> _collapsedIds = {};

  // Active cell for modal
  String? _activeMemberId;
  String? _activeCategoryId;

  int get _configuredCount =>
      _configuredMap.values.fold(0, (sum, set) => sum + set.length);

  int get _totalCount => _members.length * _categories.length;

  String _webhookUrl(String memberId, String categoryId) =>
      'https://hooks.jotform.com/webhook/${memberId}_${categoryId}_fixture';

  void _openCell(String memberId, String categoryId) {
    setState(() {
      _activeMemberId   = memberId;
      _activeCategoryId = categoryId;
    });
  }

  void _closePanel() {
    setState(() {
      _activeMemberId   = null;
      _activeCategoryId = null;
    });
  }

  void _saveConfig(String memberId, String categoryId, WebhookConfig config) {
    setState(() {
      _configuredMap
          .putIfAbsent(memberId, () => <String>{})
          .add(categoryId);

      final memberConfigs = _configs[memberId] ?? <String, WebhookConfig>{};
      memberConfigs[categoryId] = config;
      _configs[memberId] = memberConfigs;
    });
  }

  void _toggleCollapse(String memberId) {
    setState(() {
      if (_collapsedIds.contains(memberId)) {
        _collapsedIds.remove(memberId);
      } else {
        _collapsedIds.add(memberId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final showModal = _activeMemberId != null && _activeCategoryId != null;

    return Stack(
      children: [
        // ── Main content ────────────────────────────────────────
        SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageHeader(),
              const SizedBox(height: 16),
              _buildLegend(),
              const SizedBox(height: 16),
              WebhookMatrixCard(
                members:           _members,
                categories:        _categories,
                configuredMap:     _configuredMap,
                collapsedMemberIds: _collapsedIds,
                onCellTap:         _openCell,
                onToggleCollapse:  _toggleCollapse,
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Each cell represents one Jotform webhook · '
                      '${_totalCount - _configuredCount} remaining to configure',
                  style: AppTextStyles.monoMuted11,
                ),
              ),
            ],
          ),
        ),

        // ── Modal overlay ───────────────────────────────────────
        if (showModal)
          Positioned.fill(
            child: WebhookConfigPanel(
              memberName:    _members.firstWhere((m) => m.id == _activeMemberId).name,
              memberEmail:   _members.firstWhere((m) => m.id == _activeMemberId).email,
              categoryName:  _categories.firstWhere((c) => c.id == _activeCategoryId).name,
              categoryColor: _categories.firstWhere((c) => c.id == _activeCategoryId).color,
              webhookUrl:    _webhookUrl(_activeMemberId!, _activeCategoryId!),
              jotformFields: Fixtures.jotformFields,
              targetFields:  Fixtures.targetFields,
              existingConfig: _configs[_activeMemberId]?[_activeCategoryId],
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

  Widget _buildPageHeader() {
    return Row(
      children: [
        const Icon(Icons.settings, size: 18, color: AppColors.primaryText),
        const SizedBox(width: 10),
        Text(
          'Jotform Webhook Matrix',
          style: AppTextStyles.heading16,
        ),
        const Spacer(),
        ProgressBar(current: _configuredCount, total: _totalCount),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _LegendItem(
          color: const Color(0xFF22C55E),
          filled: true,
          label: 'Configured',
        ),
        const SizedBox(width: 20),
        _LegendItem(
          color: AppColors.mutedText,
          filled: false,
          label: 'Not configured',
        ),
        const Spacer(),
        Text(
          'Click any cell to configure its webhook',
          style: AppTextStyles.muted12,
        ),
      ],
    );
  }
}

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
                : Border.all(
              color: color,
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.muted12),
      ],
    );
  }
}