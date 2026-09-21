import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import '../providers/jotform_providers.dart';
import '../providers/mapping_utils.dart';
import '../providers/state/jotform_accounts_state.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/submission_field.dart';
import '../widgets/account_card.dart';
import '../widgets/add_account_form.dart';

class JotformIntegrationView extends ConsumerStatefulWidget {
  final int businessId;
  const JotformIntegrationView({super.key, required this.businessId});

  @override
  ConsumerState<JotformIntegrationView> createState() => _JotformIntegrationViewState();
}

class _JotformIntegrationViewState extends ConsumerState<JotformIntegrationView> {
  bool _adding = false;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(jotformAccountsProvider(widget.businessId));
    final fieldsAsync = ref.watch(targetFieldsProvider);

    if (s.isLoading && s.credentials.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return fieldsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(e.toString().replaceFirst('Exception: ', ''), style: AppTextStyles.muted14),
          const SizedBox(height: 12),
          ElevatedButton(
              onPressed: () => ref.invalidate(targetFieldsProvider), child: const Text('Retry')),
        ]),
      ),
      data: (fields) => _content(s, fields),
    );
  }

  Widget _content(JotformAccountsState s, List<SubmissionField> fields) {
    final notifier = ref.read(jotformAccountsProvider(widget.businessId).notifier);
    final allForms = s.formsByCredential.values.expand((l) => l).toList();
    final configured = allForms
        .where((f) => computeProgress(groupMapping(s.mappingFor(f.id)), fields).isComplete)
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Jotform Integration', style: AppTextStyles.heading24),
                  const SizedBox(height: 4),
                  Text('Connect accounts · fetch forms · map submission fields',
                      style: AppTextStyles.monoMuted11),
                ]),
              ),
              if (allForms.isNotEmpty) ...[
                Text('$configured/${allForms.length} forms configured',
                    style: AppTextStyles.monoMuted11),
                const SizedBox(width: 16),
              ],
              if (!_adding)
                ElevatedButton.icon(
                  onPressed: () => setState(() => _adding = true),
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add Account'),
                ),
            ]),
            const SizedBox(height: 24),

            if (s.error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Text(s.error!, style: AppTextStyles.mono11.copyWith(color: Colors.red)),
              ),

            for (final c in s.credentials) ...[
              AccountCard(businessId: widget.businessId, credential: c, fields: fields),
              const SizedBox(height: 16),
            ],

            if (_adding)
              AddAccountForm(
                onCancel: () => setState(() => _adding = false),
                onSubmit: (label, key) async {
                  final ok = await notifier.addCredential(label, key);
                  if (ok && mounted) setState(() => _adding = false);
                  return ok;
                },
              ),

            if (s.credentials.isEmpty && !_adding)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 80),
                child: Column(children: [
                  const Icon(Icons.key, size: 28, color: AppColors.mutedText),
                  const SizedBox(height: 12),
                  Text('No accounts connected',
                      style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Add a Jotform API key to get started.', style: AppTextStyles.monoMuted11),
                ]),
              ),
          ]),
        ),
      ),
    );
  }
}
