import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/atoms/webhook_url_row.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/section_label.dart';
import 'package:photography_business_frontend/core/network/dio_provider.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/jotform_form.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/submission_field.dart';
import '../providers/jotform_providers.dart';
import '../providers/mapping_utils.dart';
import '../providers/state/mapping_draft_state.dart';
import 'mapping_field_row.dart';

class MappingPanel extends ConsumerWidget {
  final int businessId;
  final JotformForm form;
  final List<SubmissionField> fields;
  final VoidCallback onClose;

  const MappingPanel({
    super.key,
    required this.businessId,
    required this.form,
    required this.fields,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = MappingKey(businessId, form.id);
    final s = ref.watch(mappingDraftProvider(key));
    final draft = ref.read(mappingDraftProvider(key).notifier);
    final progress = computeProgress(s.draft, fields);
    final baseUrl = ref.read(dioProvider).options.baseUrl;

    ref.listen<MappingDraftState>(mappingDraftProvider(key), (prev, next) {
      if (next.saved && !(prev?.saved ?? false)) onClose();
    });

    return Container(
      decoration: BoxDecoration(
        color: AppColors.active,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Header
        Container(
          color: AppColors.sidebarBg,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            spacing: 16,
            children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.tune, size: 14, color: AppColors.mutedText),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Field Mapping',
                      style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w600)),
                  Text(form.name, style: AppTextStyles.monoMuted11),
                ]),
              ]),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: '${progress.mapped}',
                      style: AppTextStyles.mono11.copyWith(fontWeight: FontWeight.w600)),
                  TextSpan(text: '/${progress.total} mapped', style: AppTextStyles.monoMuted11),
                  if (progress.requiredMissing > 0)
                    TextSpan(
                        text: '  ·  ${progress.requiredMissing} required missing',
                        style: AppTextStyles.mono11.copyWith(color: const Color(0xFFF59E0B))),
                ])),
                const SizedBox(width: 16),
                _Btn(
                  label: 'Refresh questions',
                  onTap: () => ref
                      .read(jotformAccountsProvider(businessId).notifier)
                      .refreshQuestions(form.id),
                ),
                const SizedBox(width: 8),
                _Btn(
                  label: 'Cancel',
                  onTap: () {
                    draft.reset();
                    onClose();
                  },
                ),
                const SizedBox(width: 8),
                _Btn(
                  label: s.isSaving ? 'Saving…' : 'Save Mapping',
                  primary: true,
                  onTap: s.isSaving ? null : draft.save,
                ),
              ]),
            ],
          ),
        ),

        // Webhook URL
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionLabel('Webhook URL'),
            const SizedBox(height: 8),
            WebhookUrlRow(url: '$baseUrl/webhooks/jotform/${form.webhookToken}'),
          ]),
        ),
        const Divider(height: 1),

        // Column labels
        Container(
          color: AppColors.sidebarBg.withOpacity(0.6),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(children: [
            const Expanded(flex: 10, child: SectionLabel('Submission Field')),
            const SizedBox(width: 12),
            const SizedBox(width: 52, child: SectionLabel('Type')),
            const SizedBox(width: 36, child: SectionLabel('Req')),
            const Expanded(flex: 14, child: SectionLabel('Form Questions')),
          ]),
        ),
        const Divider(height: 1),

        // Rows
        for (var i = 0; i < fields.length; i++) ...[
          MappingFieldRow(
            field: fields[i],
            questions: form.questions,
            selected: s.draft[fields[i].key] ?? const [],
            onChanged: (ids) => draft.setQuestions(fields[i].key, ids),
          ),
          if (i < fields.length - 1) const Divider(height: 1),
        ],

        if (s.error != null)
          Container(
            color: const Color(0xFFFEF2F2),
            padding: const EdgeInsets.all(12),
            child: Text(s.error!, style: AppTextStyles.mono11.copyWith(color: Colors.red)),
          ),
      ]),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool primary;
  const _Btn({required this.label, required this.onTap, this.primary = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Opacity(
            opacity: onTap == null ? 0.5 : 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: primary ? AppColors.primaryText : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: primary ? null : Border.all(color: AppColors.border),
              ),
              child: Text(label,
                  style: AppTextStyles.mono11.copyWith(
                      color: primary ? AppColors.active : AppColors.mutedText)),
            ),
          ),
        ),
      );
}
