import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/app_nav_bar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String title;

  const MainLayout({
    Key? key,
    required this.child,
    this.title = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title.isNotEmpty
          ? AppBar(
        title: Text(title),
        automaticallyImplyLeading: false, // Remove back button
      )
          : null,
      body: Row(
        children: [
          const AppNavBar(),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}