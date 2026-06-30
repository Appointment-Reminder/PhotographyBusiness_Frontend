import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/atoms/webhook_url_row.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/core/presentation/widgets/section_label.dart';
import 'field_mapping_row.dart';

class FieldMapping {
  String jotformField;
  String targetField;

  FieldMapping({required this.jotformField, required this.targetField});

  FieldMapping copyWith({String? jotformField, String? targetField}) => FieldMapping(
    jotformField: jotformField ?? this.jotformField,
    targetField:  targetField  ?? this.targetField,
  );
}

class WebhookConfig {
  final String webhookUrl;
  final List<FieldMapping> fieldMappings;

  const WebhookConfig({
    required this.webhookUrl,
    required this.fieldMappings,
  });
}

class WebhookConfigPanel extends StatefulWidget {
  final String memberName;
  final String memberEmail;
  final String categoryName;
  final Color categoryColor;
  final WebhookConfig? existingConfig;
  final String webhookUrl;
  final List<String> jotformFields;
  final List<String> targetFields;
  final void Function(WebhookConfig config) onSave;
  final VoidCallback onClose;

  const WebhookConfigPanel({
    super.key,
    required this.memberName,
    required this.memberEmail,
    required this.categoryName,
    required this.categoryColor,
    required this.webhookUrl,
    required this.jotformFields,
    required this.targetFields,
    required this.onSave,
    required this.onClose,
    this.existingConfig,
  });

  @override
  State<WebhookConfigPanel> createState() => _WebhookConfigPanelState();
}

class _WebhookConfigPanelState extends State<WebhookConfigPanel> {
  late List<FieldMapping> _mappings;

  @override
  void initState() {
    super.initState();
    _mappings = widget.existingConfig?.fieldMappings.map((m) => FieldMapping(
      jotformField: m.jotformField,
      targetField:  m.targetField,
    )).toList() ?? [
      FieldMapping(jotformField: '', targetField: ''),
    ];
  }

  void _addMapping() => setState(() =>
      _mappings.add(FieldMapping(jotformField: '', targetField: '')),
  );

  void _removeMapping(int i) => setState(() => _mappings.removeAt(i));

  void _updateJotform(int i, String value) => setState(() =>
  _mappings[i] = _mappings[i].copyWith(jotformField: value),
  );

  void _updateTarget(int i, String value) => setState(() =>
  _mappings[i] = _mappings[i].copyWith(targetField: value),
  );

  void _save() {
    widget.onSave(WebhookConfig(
      webhookUrl:    widget.webhookUrl,
      fieldMappings: List.from(_mappings),
    ));
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose, // tap backdrop to close
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // absorb taps inside panel
            child: Container(
              width: 520,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.active,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 40,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWebhookSection(),
                          const SizedBox(height: 24),
                          _buildMappingsSection(),
                        ],
                      ),
                    ),
                  ),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: widget.categoryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    widget.categoryName,
                    style: AppTextStyles.mono11.copyWith(
                      color: widget.categoryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.memberName,
                  style: AppTextStyles.heading16,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.memberEmail,
                  style: AppTextStyles.muted12,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: widget.onClose,
            child: const Icon(
              Icons.close,
              size: 18,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebhookSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Webhook URL'),
        const SizedBox(height: 8),
        WebhookUrlRow(url: widget.webhookUrl),
      ],
    );
  }

  Widget _buildMappingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: SectionLabel('Field Mappings')),
            GestureDetector(
              onTap: _addMapping,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 12, color: AppColors.primaryText),
                  const SizedBox(width: 4),
                  Text(
                    'Add row',
                    style: AppTextStyles.mono11.copyWith(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Column labels
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: Text('Jotform field', style: AppTextStyles.monoMuted11),
              ),
              const SizedBox(width: 28), // arrow space
              Expanded(
                child: Text('Target field', style: AppTextStyles.monoMuted11),
              ),
              const SizedBox(width: 28), // delete space
            ],
          ),
        ),

        if (_mappings.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'No mappings yet — add a row to start.',
                style: AppTextStyles.muted12,
              ),
            ),
          )
        else
          Column(
            children: _mappings.asMap().entries.map((entry) {
              final i = entry.key;
              final m = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FieldMappingRow(
                  jotformField:      m.jotformField,
                  targetField:       m.targetField,
                  jotformOptions:    widget.jotformFields,
                  targetOptions:     widget.targetFields,
                  onJotformChanged:  (v) => _updateJotform(i, v),
                  onTargetChanged:   (v) => _updateTarget(i, v),
                  onRemove:          () => _removeMapping(i),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Cancel
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Cancel',
                style: AppTextStyles.body14.copyWith(
                  color: AppColors.mutedText,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Save
          GestureDetector(
            onTap: _save,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryText,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Save configuration',
                style: AppTextStyles.body14.copyWith(
                  color: AppColors.active,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}