import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/layouts/main_layout.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/business_member_state.dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/invite_member_dialog.dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/member_list_item.dart';

class BusinessMembersPage extends ConsumerStatefulWidget {
  final int businessId;
  final String businessName;

  const BusinessMembersPage({
    super.key,
    required this.businessId,
    required this.businessName,
  });

  @override
  ConsumerState<BusinessMembersPage> createState() => _BusinessMembersPageState();
}

class _BusinessMembersPageState extends ConsumerState<BusinessMembersPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(businessMemberNotifierProvider.notifier).loadMembers(widget.businessId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final memberState = ref.watch(businessMemberNotifierProvider);

    ref.listen<BusinessMemberState>(businessMemberNotifierProvider, (previous, next) {
      if (next is MemberError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }
    });

    return MainLayout(
      title: '${widget.businessName} - Team',
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.businessName} - Team'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(businessMemberNotifierProvider.notifier).loadMembers(widget.businessId);
              },
            ),
          ],
        ),
        body: _buildBody(memberState),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => InviteMemberDialog(
                onInvite: (email, role) {
                  ref.read(businessMemberNotifierProvider.notifier).inviteNewMember(
                    widget.businessId,
                    email,
                    role,
                  );
                },
              ),
            );
          },
          child: const Icon(Icons.person_add),
        ),
      ),
    );
  }

  Widget _buildBody(BusinessMemberState state) {
    if (state is MemberLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is MemberError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(businessMemberNotifierProvider.notifier).loadMembers(widget.businessId);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is MembersLoaded) {
      if (state.members.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No team members yet',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Invite your first team member',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          ref.read(businessMemberNotifierProvider.notifier).loadMembers(widget.businessId);
        },
        child: ListView.builder(
          itemCount: state.members.length,
          itemBuilder: (context, index) {
            final member = state.members[index];
            // TODO: Determine canEdit based on current user's role
            final canEdit = true; // For now, allow all edits

            return MemberListItem(
              member: member,
              canEdit: canEdit,
              onEdit: () => _showEditMemberDialog(member),
              onRemove: () => _showRemoveConfirmation(member),
            );
          },
        ),
      );
    }

    return const Center(child: Text('Unknown state'));
  }

  void _showEditMemberDialog(member) {
    String selectedRole = member.role;
    bool isActive = member.isActive;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit ${member.userName ?? "Member"}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'photographer', child: Text('Photographer')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedRole = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active'),
                value: isActive,
                onChanged: (value) {
                  setState(() {
                    isActive = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(businessMemberNotifierProvider.notifier).updateRole(
                  widget.businessId,
                  member.id,
                  selectedRole,
                  isActive,
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveConfirmation(member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text(
          'Are you sure you want to remove ${member.userName ?? member.userEmail} from this business?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(businessMemberNotifierProvider.notifier).removeMemberFromBusiness(
                widget.businessId,
                member.id,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}