import 'package:flutter/material.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';

class UserSelector extends StatelessWidget {
  final List<BusinessMember> members;
  final int? selectedUserId;
  final Function(int? userId) onUserSelected;
  final String? labelText;

  const UserSelector({
    super.key,
    required this.members,
    required this.selectedUserId,
    required this.onUserSelected,
    this.labelText = 'Assigned Photographer',
  });

  @override
  Widget build(BuildContext context) {
    // Filter only active members
    final activeMembers = members.where((m) => m.isActive).toList();

    if (activeMembers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No active team members in this business',
                style: TextStyle(color: Colors.orange[700]),
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<int>(
      value: selectedUserId,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.person),
      ),
      isExpanded: true,
      itemHeight: null,
      items: activeMembers.map((member) {
        return DropdownMenuItem(
          value: member.userId,
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: _getRoleColor(member.role),
                child: Text(
                  (member.userName ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                  (member.userName ?? 'Unknown').toUpperCase(),

                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                member.role.toLowerCase(),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onUserSelected,
      validator: (value) {
        if (value == null) {
          return 'Please select a photographer';
        }
        return null;
      },
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return Colors.purple;
      case 'admin':
        return Colors.blue;
      case 'photographer':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}