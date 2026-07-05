import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:photography_business_frontend/features/user_create/presentation/providers/auth_provders.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/state/auth_state.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/business_params.dart';

void main() {
  test('manual backend smoke test', () async {
    // shared_preferences mock avoids platform channels entirely —
    // this whole file runs in the pure Dart VM, no emulator needed.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ]);
    addTearDown(container.dispose);

    // 1. login through the notifier (see gotcha above)
    await container.read(authNotifierProvider.notifier).login(
      'test@test.com',
      'testtest',
    );
    final authState = container.read(authNotifierProvider);
    expect(authState, isA<AuthAuthenticated>());
    print('✅ logged in as ${(authState as AuthAuthenticated).user.email}');

    // 2. create a business
    final businessResult = await container.read(createBusinessUserProvider)(
      const CreateBusinessParams(name: 'Debug Studio'),
    );
    final business = businessResult.fold(
          (failure) => fail('create business failed: ${failure.message}'),
          (b) => b,
    );
    print('✅ created business id=${business.id}');

    // 3. invite a member


    // 4. chain commission/form usecases the same way once you have a packageId

    // cleanup so reruns don't pile up junk businesses
    await container.read(deleteBusinessUserProvider)(DeleteBusinessParams(business.id));
    print('🧹 cleaned up business id=${business.id}');
  }, timeout: const Timeout(Duration(seconds: 30)));
}