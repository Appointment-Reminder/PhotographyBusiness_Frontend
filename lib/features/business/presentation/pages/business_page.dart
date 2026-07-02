
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/layouts/main_layout.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/NavBar/TopNavBar/top_nav_bar.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/business_state.dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/business_selector.dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/jotform/jotform_matrix_view.dart';
import 'package:photography_business_frontend/features/package/presentation/pages/package_pricing_view.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/team_commission_view.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/three_column_card.dart';

import '../../../../dev/Fixtures.dart';

class BusinessPage extends ConsumerStatefulWidget {
  const BusinessPage({super.key});
  
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BusinessPageState();
}


class _BusinessPageState extends ConsumerState<BusinessPage>{
  Business? selectedBusiness;


  @override
  void initState() {
    super.initState();

    Future.microtask((){
      ref.read(businessNotifierProvider.notifier).loadMyBusinesses();
    });

  }

  @override
  Widget build(BuildContext context) {
    final businessState = ref.watch(businessNotifierProvider);
    final selectedBusiness = ref.watch(selectedBusinessProvider);
    final activeId = ref.watch(businessTabProvider);

    return MainLayout(
        title: 'Businesses',
        child: Scaffold(
          appBar: TopNavBar(
            brandName: selectedBusiness != null ? selectedBusiness.name : 'Studio',
            items: [
              TopNavBarItem(id: 'Overview', label: 'Overview'),
              TopNavBarItem(id: 'Teams & Commission', label: 'Teams & Commission'),
              TopNavBarItem(id: 'Packages & Pricing', label: 'Packages & Pricing'),
              TopNavBarItem(id: 'Jotform', label: 'Jotform'),
              TopNavBarItem(id: 'Settings', label: 'Settings'),
            ],
            activeId: activeId,
            onItemSelected: (id) {
              ref.read(businessTabProvider.notifier).state = id;
            },
            trailing: const BusinessSelector(),
          ),
          body: _buildBody(businessState, selectedBusiness, activeId),
        )
    );
  }

  Widget _buildBody(
      BusinessState state,
      Business? selectedBusiness,
      String? activeId,
      ){

    if(state is BusinessLoading){
      return const Center(child: CircularProgressIndicator());
    }

    if(state is BusinessError){
      return const Center(child: Icon(Icons.error_outline, color: Colors.red,));
    }

    switch(activeId) {
      case 'Overview':
        return Center(child: Text('Overview of Business: ${selectedBusiness?.name} in progress'));
      case 'Teams & Commission':
        if (selectedBusiness == null) return const Center(child: Text('Select a business'));
        return TeamCommissionsView(businessId: selectedBusiness.id);
      case 'Packages & Pricing':
        if (selectedBusiness == null) return const Center(child: Text('Select a business'));
        return PackagesPricingView(businessId: selectedBusiness.id);
      case 'Jotform':
        if(selectedBusiness == null)  return Center(child: Text('Select a business'),);
        return JotformMatrixView(businessId: selectedBusiness.id);
      case 'Settings':
        return Center(child: Text('Settings of : ${selectedBusiness?.name} Page in progress'));
    }


    return Center(
      child: Text(
        'Selected Business: ${selectedBusiness?.name} active id $activeId',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}

