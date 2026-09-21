import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/jotform_form.dart';

/// Pops with the chosen JotformForm.id (or null on cancel).
class AssignFormDialog extends StatefulWidget {
  final String memberName;
  final String categoryName;
  final List<JotformForm> forms;
  final int? currentFormId;

  const AssignFormDialog({
    super.key,
    required this.memberName,
    required this.categoryName,
    required this.forms,
    this.currentFormId,
  });

  @override
  State<AssignFormDialog> createState() => _AssignFormDialogState();
}

class _AssignFormDialogState extends State<AssignFormDialog> {
  late int? _selected = widget.currentFormId;

  @override
  Widget build(BuildContext context) {
    final changed = _selected != null && _selected != widget.currentFormId;
    return Dialog(
      backgroundColor: AppColors.active,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Assign Jotform', style: AppTextStyles.heading16),
          const SizedBox(height: 4),
          Text('${widget.memberName} · ${widget.categoryName}', style: AppTextStyles.muted12),
          const SizedBox(height: 20),
          DropdownButtonFormField<int>(
            value: _selected,
            isExpanded: true,
            hint: Text('-- select a form --', style: AppTextStyles.monoMuted12),
            style: AppTextStyles.mono12.copyWith(color: AppColors.primaryText),
            items: [
              for (final f in widget.forms)
                DropdownMenuItem(value: f.id, child: Text(f.name, overflow: TextOverflow.ellipsis)),
            ],
            onChanged: (v) => setState(() => _selected = v),
          ),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: changed ? () => Navigator.pop(context, _selected) : null,
              child: const Text('Assign'),
            ),
          ]),
        ]),
      ),
    );
  }
}
