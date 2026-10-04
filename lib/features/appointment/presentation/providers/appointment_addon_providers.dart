import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/addon/presentation/providers/addon_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/member_providers.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/auth_provders.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/state/auth_state.dart';
import '../../domain/workflow/workflow_viewer.dart';

/// Whether the signed-in user manages the business (owner or admin). Add-on
/// editing and the Add-on catalogue are owner and admin only.
final isBusinessManagerProvider = Provider.family<bool, int>((ref, businessId) {
  final auth = ref.watch(authNotifierProvider);
  return WorkflowViewer.resolve(
    userId: auth is AuthAuthenticated ? auth.user.id : null,
    businessOwnerId: ref.watch(selectedBusinessProvider)?.ownerId,
    members: ref.watch(businessMembersProvider(businessId)).members,
  ).canSeeAll;
});

/// Add-on names by id, from the catalog. Empty until the catalog is loaded,
/// and for users who cannot read it; callers then fall back to the raw label.
final addonNamesProvider = Provider<Map<int, String>>((ref) {
  return {for (final a in ref.watch(addonCatalogProvider).addons) a.id: a.name};
});
