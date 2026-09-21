import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/jotform_question.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/submission_field.dart';
import 'question_selector.dart';

class _Badge {
  final String label;
  final Color bg, fg, border;
  const _Badge(this.label, this.bg, this.fg, this.border);
}

const _badges = {
  'DATE': _Badge('DATE', Color(0xFFEFF6FF), Color(0xFF2563EB), Color(0xFFDBEAFE)),
  'TEXT': _Badge('TEXT', Color(0xFFF4F4F5), Color(0xFF71717A), Color(0xFFE4E4E7)),
  'BOOL': _Badge('BOOL', Color(0xFFFFFBEB), Color(0xFFD97706), Color(0xFFFEF3C7)),
  'LIST': _Badge('LIST', Color(0xFFF5F3FF), Color(0xFF7C3AED), Color(0xFFEDE9FE)),
  'NUMBER': _Badge('NUM', Color(0xFFECFDF5), Color(0xFF059669), Color(0xFFD1FAE5)),
};

class MappingFieldRow extends StatelessWidget {
  final SubmissionField field;
  final List<JotformQuestion> questions;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const MappingFieldRow({
    super.key,
    required this.field,
    required this.questions,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final badge = _badges[field.type] ?? _badges['TEXT']!;
    final mapped = selected.isNotEmpty;
    final warn = field.required && !mapped;

    return Container(
      color: warn ? const Color(0x66FFFBEB) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(children: [
        Expanded(
          flex: 10,
          child: Row(children: [
            mapped
                ? const Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981))
                : Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: field.required ? const Color(0xFFFBBF24) : AppColors.border),
                    ),
                  ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(field.label,
                  style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 52,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 3),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: badge.bg,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: badge.border),
            ),
            child: Text(badge.label, style: AppTextStyles.mono10.copyWith(color: badge.fg)),
          ),
        ),
        SizedBox(
          width: 36,
          child: Center(
            child: field.required
                ? Text('✱',
                    style: AppTextStyles.mono10
                        .copyWith(color: const Color(0xFFF87171), fontWeight: FontWeight.bold))
                : null,
          ),
        ),
        Expanded(
          flex: 14,
          child: QuestionSelector(questions: questions, selected: selected, onChanged: onChanged),
        ),
      ]),
    );
  }
}
