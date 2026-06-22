import 'package:flutter/material.dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/business_card.dart';
import 'package:photography_business_frontend/features/appointment/presentation/widgets/appointment_card.dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/member_list_item.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/package_card.dart';
import 'fixtures.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/app_nav_bar.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/auth_provders.dart';
import 'fake_auth.dart';
// ...keep existing imports

class GalleryEntry {
  final String name;
  final WidgetBuilder builder;
  final bool needsAuth;
  const GalleryEntry(this.name, this.builder, {this.needsAuth = false});
}

final entries = <GalleryEntry>[
  // ...keep existing entries (BusinessCard, AppointmentCard, etc.)
  GalleryEntry('BusinessCard', (_) => BusinessCard(
    business: Fixtures.business,
    onTap: () {},
  )),
  GalleryEntry('AppointmentCard', (_) => AppointmentCard(
    appointment: Fixtures.appointment,
    onTap: () {},
  )),
  GalleryEntry('MemberListItem', (_) => MemberListItem(
    member: Fixtures.member,
    canEdit: true,
    onEdit: () {},
    onRemove: () {},
  )),
  GalleryEntry('PackageCard', (_) => PackageCard(
    package: Fixtures.package,
    onTap: () {},
  )),
  GalleryEntry(
    'AppNavBar',
        (_) => Row(
      children: [
        const AppNavBar(),
        Expanded(child: Container(color: Colors.grey[100])),
      ],
    ),
    needsAuth: true,
  ),
];

class WidgetGalleryPage extends StatelessWidget {
  const WidgetGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Gallery')),
      body: ListView.separated(
        itemCount: entries.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final entry = entries[i];
          return ListTile(
            title: Text(entry.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              final page = Scaffold(
                appBar: AppBar(title: Text(entry.name)),
                body: entry.builder(context),
              );

              final wrapped = entry.needsAuth
                  ? ProviderScope(
                overrides: [
                  authNotifierProvider.overrideWith((ref) => FakeAuthNotifier()),
                ],
                child: page,
              )
                  : page;

              Navigator.push(context, MaterialPageRoute(builder: (_) => wrapped));
            },
          );
        },
      ),
    );
  }
}

