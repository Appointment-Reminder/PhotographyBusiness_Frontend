import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';

class AddAccountForm extends StatefulWidget {
  /// Returns true on success (parent then closes the form).
  final Future<bool> Function(String label, String apiKey) onSubmit;
  final VoidCallback onCancel;

  const AddAccountForm({super.key, required this.onSubmit, required this.onCancel});

  @override
  State<AddAccountForm> createState() => _AddAccountFormState();
}

class _AddAccountFormState extends State<AddAccountForm> {
  final _label = TextEditingController();
  final _key = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _label.dispose();
    _key.dispose();
    super.dispose();
  }

  bool get _canSubmit => _label.text.trim().isNotEmpty && _key.text.trim().isNotEmpty && !_busy;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _busy = true);
    await widget.onSubmit(_label.text, _key.text);
    if (mounted) setState(() => _busy = false);
  }

  Widget _field(String label, TextEditingController c, String hint, {String? help}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTextStyles.monoMuted11),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          onChanged: (_) => setState(() {}),
          style: AppTextStyles.mono12,
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: AppTextStyles.monoMuted12,
            filled: true,
            fillColor: AppColors.sidebarBg,
          ),
        ),
        if (help != null) ...[
          const SizedBox(height: 6),
          Text(help, style: AppTextStyles.monoMuted10),
        ],
      ]);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.active,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Connect Jotform Account',
            style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _field('Account Label', _label, 'e.g. Main Studio, Second Location…'),
        const SizedBox(height: 12),
        _field('Jotform API Key', _key, 'API key',
            help: 'Found in Jotform → Account Settings → API'),
        const SizedBox(height: 16),
        Row(children: [
          OutlinedButton(onPressed: widget.onCancel, child: const Text('Cancel')),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _canSubmit ? _submit : null,
            child: Text(_busy ? 'Connecting…' : 'Connect Account'),
          ),
        ]),
      ]),
    );
  }
}
