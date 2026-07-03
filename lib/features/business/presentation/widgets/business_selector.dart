
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';


class BusinessSelector extends ConsumerWidget {


  const BusinessSelector({super.key});

  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(businessListNotifierProvider);
    
    if(state.isLoading){
      return const SizedBox.shrink();
    }
    
    return DropdownButton<Business>(
        value: ref.watch(selectedBusinessProvider),
        items: state.businesses.map((business) {
          return DropdownMenuItem(
            value: business,
              child: Text(business.name),
          );
        }).toList(), 
        onChanged: (business) {
          if (business == null) return;
          ref.read(selectedBusinessProvider.notifier).state = business;
        }
        );
  }
}