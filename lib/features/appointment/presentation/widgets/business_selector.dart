import 'package:flutter/material.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business.dart';

class BusinessSelector extends StatelessWidget {
  final int? selectedBusinessId; // null means "All"
  final List<Business> businesses;
  final Function(int? businessId) onBusinessSelected;

  const BusinessSelector({
    super.key,
    required this.selectedBusinessId,
    required this.businesses,
    required this.onBusinessSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Business:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // "All" chip
                  _buildBusinessChip(
                    label: 'All',
                    isSelected: selectedBusinessId == null,
                    onTap: () => onBusinessSelected(null),
                  ),
                  const SizedBox(width: 8),
                  // Individual business chips
                  ...businesses.map((business) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildBusinessChip(
                      label: business.name,
                      isSelected: selectedBusinessId == business.id,
                      onTap: () => onBusinessSelected(business.id),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[700],
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue[700] : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
      ),
    );
  }
}