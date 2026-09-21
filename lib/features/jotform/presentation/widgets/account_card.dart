import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/jotform_credential.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/submission_field.dart';
import '../providers/jotform_providers.dart';
import '../providers/mapping_utils.dart';
import 'form_row.dart';

class AccountCard extends ConsumerStatefulWidget {
  final int businessId;
  final JotformCredential credential;
  final List<SubmissionField> fields;

  const AccountCard({
    super.key,
    required this.businessId,
    required this.credential,
    required this.fields,
  });

  @override
  ConsumerState<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends ConsumerState<AccountCard> {
  bool _showKey = false;
  int? _configuringId;

  String get _masked {
    final k = widget.credential.apiKey;
    return k.length > 10 ? '${k.substring(0, 6)}••••••••••••${k.substring(k.length - 4)}' : '••••••••';
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Remove account?'),
        content: Text('"${widget.credential.label}" and its forms will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Remove')),
        ],
      ),
    );
    if (ok == true) {
      ref.read(jotformAccountsProvider(widget.businessId).notifier)
          .removeCredential(widget.credential.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.credential;
    final s = ref.watch(jotformAccountsProvider(widget.businessId));
    final notifier = ref.read(jotformAccountsProvider(widget.businessId).notifier);
    final forms = s.formsFor(c.id);
    final fetching = s.fetchingIds.contains(c.id);
    final configured = forms
        .where((f) => computeProgress(groupMapping(s.mappingFor(f.id)), widget.fields).isComplete)
        .length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.active,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.sidebarBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.key, size: 14, color: AppColors.mutedText),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.label, style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: () => setState(() => _showKey = !_showKey),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_showKey ? Icons.visibility_off : Icons.visibility,
                          size: 11, color: AppColors.mutedText),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(_showKey ? c.apiKey : _masked,
                            style: AppTextStyles.monoMuted11, overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                  ),
                ),
              ]),
            ),
            GestureDetector(
              onTap: fetching ? null : () => notifier.refetch(c.id),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Opacity(
                  opacity: fetching ? 0.4 : 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      fetching
                          ? const SizedBox(
                              width: 11,
                              height: 11,
                              child: CircularProgressIndicator(strokeWidth: 1.5))
                          : const Icon(Icons.refresh, size: 12, color: AppColors.mutedText),
                      const SizedBox(width: 6),
                      Text(fetching ? 'Fetching…' : 'Refetch Forms',
                          style: AppTextStyles.mono11.copyWith(color: AppColors.mutedText)),
                    ]),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Remove account',
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.mutedText),
            ),
          ]),
        ),
        const Divider(height: 1),

        // Forms
        if (fetching)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
                child: Text('Fetching forms from Jotform…', style: AppTextStyles.monoMuted12)),
          )
        else if (forms.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
                child: Text('No forms found. Try refetching.', style: AppTextStyles.monoMuted12)),
          )
        else
          for (var i = 0; i < forms.length; i++) ...[
            FormRow(
              businessId: widget.businessId,
              form: forms[i],
              fields: widget.fields,
              isConfiguring: _configuringId == forms[i].id,
              onToggle: () => setState(() =>
                  _configuringId = _configuringId == forms[i].id ? null : forms[i].id),
            ),
            if (i < forms.length - 1) const Divider(height: 1),
          ],

        // Footer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: const BoxDecoration(
            color: AppColors.sidebarBg,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Text(
            '${forms.length} form${forms.length == 1 ? '' : 's'} · $configured fully configured',
            style: AppTextStyles.monoMuted11,
          ),
        ),
      ]),
    );
  }
}
