// lib/features/user_create/presentation/pages/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/auth_provders.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/state/auth_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Check auth status when screen loads
    Future.microtask(() {
      ref.read(authNotifierProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Listen for auth state changes and navigate accordingly
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is AuthAuthenticated) {
        // User is logged in, go to home
        Navigator.pushReplacementNamed(context, '/home');
      } else if (next is AuthUnauthenticated || next is AuthError) {
        // No saved session or error, go to login
        Navigator.pushReplacementNamed(context, '/login');
      }
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your app logo here
            const Icon(
              Icons.camera_alt,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'Photography Business',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            if (authState is AuthLoading)
              const CircularProgressIndicator()
            else if (authState is AuthError)
              Text(
                'Error: ${authState.message}',
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}