import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_text_styles.dart';

class FieldMappingRow extends StatelessWidget {
  final String jotformField;
  final String targetField;
  final List<String> jotformOptions;
  final List<String> targetOptions;
  final ValueChanged<String> onJotformChanged;
  final ValueChanged<String> onTargetChanged;
  final VoidCallback onRemove;

  const FieldMappingRow({
    super.key,
    required this.jotformField,
    required this.targetField,
    required this.jotformOptions,
    required this.targetOptions,
    required this.onJotformChanged,
    required this.onTargetChanged,
    required this.onRemove,
  });

  InputDecoration _dropdownDecoration() => InputDecoration(
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.primaryText, width: 1.5),
    ),
    filled: true,
    fillColor: AppColors.sidebarBg,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Jotform field dropdown
        Expanded(
          child: DropdownButtonFormField<String>(
            value: jotformField.isEmpty ? null : jotformField,
            decoration: _dropdownDecoration(),
            style: AppTextStyles.mono11.copyWith(color: AppColors.primaryText),
            hint: Text('-- select --', style: AppTextStyles.monoMuted11),
            items: jotformOptions.map((f) => DropdownMenuItem(
              value: f,
              child: Text(f, style: AppTextStyles.mono11),
            )).toList(),
            onChanged: (v) { if (v != null) onJotformChanged(v); },
          ),
        ),

        // Arrow
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('→', style: AppTextStyles.monoMuted12),
        ),

        // Target field dropdown
        Expanded(
          child: DropdownButtonFormField<String>(
            value: targetField.isEmpty ? null : targetField,
            decoration: _dropdownDecoration(),
            style: AppTextStyles.mono11.copyWith(color: AppColors.primaryText),
            hint: Text('-- select --', style: AppTextStyles.monoMuted11),
            items: targetOptions.map((f) => DropdownMenuItem(
              value: f,
              child: Text(f, style: AppTextStyles.mono11),
            )).toList(),
            onChanged: (v) { if (v != null) onTargetChanged(v); },
          ),
        ),

        // Delete
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onRemove,
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.delete_outline, size: 14, color: AppColors.mutedText),
          ),
        ),
      ],
    );
  }
}