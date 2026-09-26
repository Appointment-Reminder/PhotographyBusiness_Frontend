import 'dart:math';
import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/jotform_question.dart';

import '../../domain/entities/question_selection.dart';

/// Multi-select dropdown with search. Selection order = mapping priority.
/// Each selection carries an optional subkey when the underlying question
/// is composite (e.g. a "full name" question split into first/last).
class QuestionSelector extends StatefulWidget {
  final List<JotformQuestion> questions;
  final List<QuestionSelection> selected;
  final ValueChanged<List<QuestionSelection>> onChanged;

  const QuestionSelector({
    super.key,
    required this.questions,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<QuestionSelector> createState() => _QuestionSelectorState();
}

class _QuestionSelectorState extends State<QuestionSelector> {
  final _link = LayerLink();
  final _search = ValueNotifier<String>('');
  OverlayEntry? _entry;

  @override
  void didUpdateWidget(covariant QuestionSelector old) {
    super.didUpdateWidget(old);
    WidgetsBinding.instance.addPostFrameCallback((_) => _entry?.markNeedsBuild());
  }

  @override
  void dispose() {
    _removeEntry();
    _search.dispose();
    super.dispose();
  }

  void _removeEntry() {
    if (_entry?.mounted ?? false) _entry!.remove();
    _entry = null;
  }

  void _close() {
    _removeEntry();
    if (mounted) setState(() {});
  }

  void _open() {
    final box = context.findRenderObject() as RenderBox;
    final width = max(box.size.width, 240.0);
    final height = box.size.height;
    _search.value = '';
    _entry = OverlayEntry(
      builder: (_) => Stack(children: [
        Positioned.fill(
          child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: _close),
        ),
        CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          offset: Offset(0, height + 4),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: width, child: _menu()),
          ),
        ),
      ]),
    );
    Overlay.of(context).insert(_entry!);
    setState(() {});
  }

  bool _isSelected(String qid) => widget.selected.any((s) => s.qid == qid);

  void _toggle(JotformQuestion q) {
    if (_isSelected(q.id)) {
      widget.onChanged(widget.selected.where((s) => s.qid != q.id).toList());
    } else {
      widget.onChanged([
        ...widget.selected,
        QuestionSelection(q.id, subkey: q.subkeys.isNotEmpty ? q.subkeys.first : null),
      ]);
    }
  }

  void _remove(String qid) =>
      widget.onChanged(widget.selected.where((s) => s.qid != qid).toList());

  void _setSubkey(String qid, String subkey) => widget.onChanged([
    for (final s in widget.selected) s.qid == qid ? s.copyWithSubkey(subkey) : s,
  ]);

  Widget _menu() {
    return Material(
      elevation: 6,
      color: AppColors.active,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 280),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                autofocus: true,
                onChanged: (v) => _search.value = v,
                style: AppTextStyles.mono12,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search…',
                  hintStyle: AppTextStyles.monoMuted12,
                  prefixIcon: const Icon(Icons.search, size: 14, color: AppColors.mutedText),
                  prefixIconConstraints: const BoxConstraints(minWidth: 32),
                  filled: true,
                  fillColor: AppColors.sidebarBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ValueListenableBuilder<String>(
                valueListenable: _search,
                builder: (_, q, __) {
                  final list = widget.questions
                      .where((x) => x.name.toLowerCase().contains(q.toLowerCase()))
                      .toList();
                  if (list.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('No results', style: AppTextStyles.monoMuted12),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final question = list[i];
                      final checked = _isSelected(question.id);
                      return InkWell(
                        onTap: () => _toggle(question),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: checked ? AppColors.primaryText : AppColors.active,
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                    color: checked ? AppColors.primaryText : AppColors.border),
                              ),
                              child: checked
                                  ? const Icon(Icons.check, size: 10, color: AppColors.active)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(question.name,
                                  style: AppTextStyles.mono12, overflow: TextOverflow.ellipsis),
                            ),
                            if (question.subkeys.isNotEmpty)
                              Text('${question.subkeys.length} subkeys',
                                  style: AppTextStyles.monoMuted10),
                          ]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(JotformQuestion question, QuestionSelection selection) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(question.name, style: AppTextStyles.mono10),
        // Subkey picker — only shown when the question has more than one subkey.
        if (question.subkeys.length > 1) ...[
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () async {
              final picked = await showMenu<String>(
                context: context,
                position: const RelativeRect.fromLTRB(0, 0, 0, 0),
                items: [
                  for (final sk in question.subkeys)
                    PopupMenuItem(value: sk, child: Text(sk, style: AppTextStyles.mono11)),
                ],
              );
              if (picked != null) _setSubkey(question.id, picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.active,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(selection.subkey ?? question.subkeys.first,
                    style: AppTextStyles.mono10.copyWith(color: AppColors.primaryText)),
                const Icon(Icons.arrow_drop_down, size: 12, color: AppColors.mutedText),
              ]),
            ),
          ),
        ],
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => _remove(question.id),
          child: const Icon(Icons.close, size: 10, color: AppColors.mutedText),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final byId = {for (final q in widget.questions) q.id: q};
    final isOpen = _entry != null;

    return CompositedTransformTarget(
      link: _link,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: isOpen ? _close : _open,
        child: Container(
          constraints: const BoxConstraints(minHeight: 34),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.active,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isOpen ? AppColors.primaryText.withOpacity(0.5) : AppColors.border,
            ),
          ),
          child: Row(children: [
            Expanded(
              child: widget.selected.isEmpty
                  ? Text('Select questions…', style: AppTextStyles.monoMuted12)
                  : Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (final selection in widget.selected)
                    if (byId[selection.qid] != null)
                      _chip(byId[selection.qid]!, selection),
                ],
              ),
            ),
            Icon(isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 14, color: AppColors.mutedText),
          ]),
        ),
      ),
    );
  }
}