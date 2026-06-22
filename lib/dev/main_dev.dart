import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_theme.dart';
import 'package:photography_business_frontend/dev/widget_gallery.dart';


void main() {
  runApp(
      MaterialApp(
        theme: AppTheme.light,
        home: const WidgetGalleryPage(),
  ));
}