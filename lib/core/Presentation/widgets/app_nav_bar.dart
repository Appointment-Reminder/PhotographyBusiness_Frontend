import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/auth_provders.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/state/auth_state.dart';

class AppNavBar extends ConsumerWidget{
  const AppNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref){
    final authState = ref.watch(authNotifierProvider);

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          if(authState is AuthAuthenticated)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.blue,
                        child: Text(
                          authState.user.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16,),
                      Text(
                        authState.user.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4,),
                      Text(
                        authState.user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.business),
                  title: const Text('Businesses'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/businesses'); // Use pushReplacementNamed
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('Appointment'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Appointments are coming soon')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/home'); // Use pushReplacementNamed
                  },
                ),

              ],
            ),





          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                //add navigation here later
              ],
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: (){
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings - Coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red,),
            title:  const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              ref.read(authNotifierProvider.notifier).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          const SizedBox(height: 16,),
        ],
      ),
    );
  }
}