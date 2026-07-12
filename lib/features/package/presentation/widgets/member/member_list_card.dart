import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/PackageAndPricingWidgets/molecule/column_header.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/member/molecule/member_edit_form.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/member/molecule/member_row.dart';

import '../../../../../core/Presentation/widgets/section_label.dart';

class MemberData {
  final String id;
  String name;
  String role;
  String email;

  MemberData({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
  });
}

class MemberListCard extends StatefulWidget {
  final List<MemberData> members;
  final String selectedId;
  final String? editingId;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onEditTap;
  final void Function(String id, String name, String role, String email) onSave;
  final VoidCallback onCancelEdit;
  final double maxHeight;

  /// If null, the invite button/panel is hidden.
  final Future<void> Function(String email, String role)? onInvite;
  final List<String> inviteRoles;

  const MemberListCard({
    super.key,
    required this.members,
    required this.selectedId,
    required this.editingId,
    required this.onSelect,
    required this.onEditTap,
    required this.onSave,
    required this.onCancelEdit,
    this.maxHeight = 480,
    this.onInvite,
    this.inviteRoles = const ['photographer', 'assistant', 'admin'],
  });

  @override
  State<MemberListCard> createState() => _MemberListCardState();
}

class _MemberListCardState extends State<MemberListCard> {
  bool _showInvite = false;
  bool _sending = false;
  bool _sent = false;

  final _emailCtrl = TextEditingController();
  late String _selectedRole = widget.inviteRoles.first;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendInvite() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || widget.onInvite == null || _sending) return;

    setState(() => _sending = true);
    try {
      await widget.onInvite!(email, _selectedRole);
      setState(() {
        _sending = false;
        _sent = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() {
        _sent = false;
        _showInvite = false;
        _emailCtrl.clear();
        _selectedRole = widget.inviteRoles.first;
      });
    } catch (_) {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _cancelInvite() {
    setState(() {
      _showInvite = false;
      _emailCtrl.clear();
      _selectedRole = widget.inviteRoles.first;
    });
  }

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
    hintText: hint,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    filled: true,
    fillColor: AppColors.active,
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
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      constraints: BoxConstraints(maxHeight: widget.maxHeight),
      decoration: BoxDecoration(
        color: AppColors.active,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.members.length,
              itemBuilder: (context, i) {
                final m = widget.members[i];
                if (widget.editingId == m.id) {
                  return MemberEditForm(
                    initialName: m.name,
                    initialRole: m.role,
                    initialEmail: m.email,
                    onSave: (name, role, email) => widget.onSave(m.id, name, role, email),
                    onCancel: widget.onCancelEdit,
                  );
                }
                return MemberRow(
                  name: m.name,
                  role: m.role,
                  email: m.email,
                  isSelected: m.id == widget.selectedId,
                  onTap: () => widget.onSelect(m.id),
                  onEditTap: () => widget.onEditTap(m.id),
                );
              },
            ),
          ),
          if (_showInvite) _buildInvitePanel(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Expanded(child: SectionLabel('Members')),
          if (widget.onInvite != null && !_showInvite)
            GestureDetector(
              onTap: () => setState(() => _showInvite = true),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 12, color: AppColors.primaryText),
                  const SizedBox(width: 4),
                  Text(
                    'Invite',
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
    );
  }

  Widget _buildInvitePanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mail_outline, size: 13, color: AppColors.mutedText),
              const SizedBox(width: 6),
              Text('Invite a member', style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),

          Text('EMAIL ADDRESS', style: AppTextStyles.monoMuted10.copyWith(letterSpacing: 1.2)),
          const SizedBox(height: 4),
          TextField(
            controller: _emailCtrl,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            style: AppTextStyles.mono12,
            decoration: _fieldDecoration('name@studio.com'),
            onSubmitted: (_) => _sendInvite(),
          ),
          const SizedBox(height: 8),

          Text('ROLE', style: AppTextStyles.monoMuted10.copyWith(letterSpacing: 1.2)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            style: AppTextStyles.mono12.copyWith(color: AppColors.primaryText),
            decoration: _fieldDecoration(''),
            items: widget.inviteRoles
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) { if (v != null) setState(() => _selectedRole = v); },
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: (_emailCtrl.text.trim().isEmpty || _sending || _sent) ? null : _sendInvite,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _sent ? const Color(0xFF10B981) : AppColors.primaryText,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_sent ? Icons.check : Icons.send, size: 12, color: AppColors.active),
                        const SizedBox(width: 6),
                        Text(
                          _sending ? 'Sending…' : (_sent ? 'Sent!' : 'Send invite'),
                          style: AppTextStyles.mono12.copyWith(color: AppColors.active, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _cancelInvite,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.close, size: 14, color: AppColors.mutedText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}