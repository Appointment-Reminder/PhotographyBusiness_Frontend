import 'package:flutter/material.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package.dart';

class PackageCard extends StatelessWidget {
  final Package package;
  final VoidCallback onTap;

  const PackageCard({
    super.key,
    required this.package,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          Icons.inventory_2_outlined,
          color: package.isActive ? Colors.blue : Colors.grey,
        ),
        title: Text(package.name),
        subtitle: Text(
          package.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: package.isActive
            ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
            : const Icon(Icons.cancel, color: Colors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }
}
