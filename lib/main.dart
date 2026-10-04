import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_theme.dart';
import 'package:photography_business_frontend/features/appointment/presentation/pages/appointments_page.dart';
import 'package:photography_business_frontend/features/business/presentation/pages/business_page.dart';
import 'package:photography_business_frontend/features/package/presentation/pages/packages_page.dart';
import 'package:photography_business_frontend/features/user_create/presentation/pages/registerScreen.dart';
import 'package:photography_business_frontend/features/user_create/presentation/pages/splashScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/Presentation/layouts/main_layout.dart';
import 'core/Presentation/widgets/app_nav_bar.dart';
import 'features/user_create/presentation/pages/loginScreen.dart';
import 'features/user_create/presentation/providers/auth_provders.dart';
import 'features/user_create/presentation/providers/state/auth_state.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(SessionRoot(sharedPreferences: sharedPreferences));
}

/// Recreates the ProviderScope on logout so no user-scoped state survives.
class SessionRoot extends StatefulWidget {
  final SharedPreferences sharedPreferences;
  const SessionRoot({super.key, required this.sharedPreferences});

  @override
  State<SessionRoot> createState() => _SessionRootState();
}

class _SessionRootState extends State<SessionRoot> {
  int _session = 0;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      key: ValueKey(_session),
      overrides: [
        sharedPreferencesProvider.overrideWithValue(widget.sharedPreferences),
      ],
      child: _LogoutWatcher(onLogout: () => setState(() => _session++)),
    );
  }
}

class _LogoutWatcher extends ConsumerWidget {
  final VoidCallback onLogout;
  const _LogoutWatcher({required this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (prev is AuthAuthenticated && next is AuthUnauthenticated) onLogout();
    });
    return const MyApp();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photography Business',
      theme: AppTheme.light,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(), // You'll create this
        '/register': (context) => const RegisterScreen(),
        '/businesses': (context) => const BusinessPage(),
        '/packages': (context) => const PackagesPage(),
      },
    );
  }
}


class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      title: 'Home',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Welcome to Photography Business',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}