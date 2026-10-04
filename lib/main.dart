import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_theme.dart';
import 'package:photography_business_frontend/core/Presentation/layouts/app_shell.dart';
import 'package:photography_business_frontend/features/user_create/presentation/pages/registerScreen.dart';
import 'package:photography_business_frontend/features/user_create/presentation/pages/splashScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        '/home': (context) => const AppShell(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}


