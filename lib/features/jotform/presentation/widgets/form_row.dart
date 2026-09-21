import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/jotform_form.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/submission_field.dart';
import '../providers/jotform_providers.dart';
import '../providers/mapping_utils.dart';
import 'mapping_panel.dart';

class FormRow extends ConsumerWidget {
  final int businessId;
  final JotformForm form;
  final List<SubmissionField> fields;
  final bool isConfiguring;
  final VoidCallback onToggle;

  const FormRow({
    super.key,
    required this.businessId,
    required this.form,
    required this.fields,
    required this.isConfiguring,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(
        jotformAccountsProvider(businessId).select((s) => s.mappingFor(form.id)));
    final p = computeProgress(groupMapping(items), fields);
    final barColor = p.isComplete
        ? const Color(0xFF34D399)
        : p.mapped > 0
            ? const Color(0xFFFBBF24)
            : AppColors.border;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        color: isConfiguring ? AppColors.sidebarBg : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(form.name,
                  style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text('${form.questions.length} questions', style: AppTextStyles.monoMuted11),
            ]),
          ),
          Container(
            width: 80,
            height: 6,
            decoration: BoxDecoration(
                color: const Color(0xFFE4E4E7), borderRadius: BorderRadius.circular(99)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: p.total == 0 ? 0 : p.mapped / p.total,
              child: Container(
                  decoration:
                      BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(99))),
            ),
          ),
          const SizedBox(width: 8),
          Text('${p.mapped}/${p.total}', style: AppTextStyles.monoMuted10),
          const SizedBox(width: 16),
          _StatusBadge(p),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onToggle,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isConfiguring ? AppColors.primaryText : AppColors.active,
                  borderRadius: BorderRadius.circular(6),
                  border: isConfiguring ? null : Border.all(color: AppColors.border),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.tune,
                      size: 12, color: isConfiguring ? AppColors.active : AppColors.mutedText),
                  const SizedBox(width: 6),
                  Text(isConfiguring ? 'Close' : 'Configure',
                      style: AppTextStyles.mono11.copyWith(
                          color: isConfiguring ? AppColors.active : AppColors.mutedText)),
                ]),
              ),
            ),
          ),
        ]),
      ),
      if (isConfiguring)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: MappingPanel(
              businessId: businessId, form: form, fields: fields, onClose: onToggle),
        ),
    ]);
  }
}

class _StatusBadge extends StatelessWidget {
  final MappingProgress p;
  const _StatusBadge(this.p);

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color bg, fg, border;
    if (p.isComplete && p.mapped > 0) {
      label = 'Configured';
      bg = const Color(0xFFECFDF5); fg = const Color(0xFF059669); border = const Color(0xFFD1FAE5);
    } else if (p.mapped > 0) {
      label = 'Partial';
      bg = const Color(0xFFFFFBEB); fg = const Color(0xFFD97706); border = const Color(0xFFFEF3C7);
    } else {
      label = 'Not set up';
      bg = AppColors.sidebarBg; fg = AppColors.mutedText; border = AppColors.border;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Text(label, style: AppTextStyles.mono10.copyWith(color: fg)),
    );
  }
}
