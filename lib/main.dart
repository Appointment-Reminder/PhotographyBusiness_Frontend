import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/presentation/pages/business_lis_page.dart';
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

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photography Business',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(), // You'll create this
        '/register': (context) => const RegisterScreen(),
        '/businesses': (context) => const BusinessesListPage(),
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