import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/NavBar/TopNavBar/NavBarIten.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/atoms/avatar_chip.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/atoms/configured_cell_icon.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/atoms/progress_bar.dart' show ProgressBar;
import 'package:photography_business_frontend/core/Presentation/widgets/atoms/unconfigured_cell_icon.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/atoms/webhook_url_row.dart' show WebhookUrlRow;
import 'package:photography_business_frontend/core/Presentation/widgets/category/category_badge.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/category/commission_type_toggle.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/check_circle.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/current_badge.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/empty_circle.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/section_label.dart';
import 'package:photography_business_frontend/dev/Fixtures.dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/jotform/field_mapping_row.dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/jotform/jotform_matrix_view.dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/jotform/matrix_cell.dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/jotform/matrix_column_header.dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/jotform/matrix_member_row..dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/jotform/webhook_config_panel.dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/jotform/webhook_matrix_card..dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/PackageAndPricingWidgets/molecule/category_row.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/PackageAndPricingWidgets/molecule/column_header.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/PackageAndPricingWidgets/molecule/package_row.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/PackageAndPricingWidgets/molecule/price_history_row.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/commission/commission_row.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/member/molecule/member_edit_form.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/member/molecule/member_row.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/team_commission_view.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/three_column_card.dart';


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


// widget_gallery.dart

class GallerySection {
  final String title;
  final List<GalleryEntry> entries;
  const GallerySection(this.title, this.entries);
}

final sections = <GallerySection>[
  GallerySection('Foundation', [
    GalleryEntry(
      'Fonts / smoke test',
          (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Inter 600 — Heading',         style: AppTextStyles.heading24),
            const SizedBox(height: 8),
            Text('Inter 400 — Body',            style: AppTextStyles.body16),
            const SizedBox(height: 8),
            Text('Inter 400 — Muted',           style: AppTextStyles.muted14),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text('JetBrains Mono 400',          style: AppTextStyles.mono12),
            const SizedBox(height: 8),
            Text('160 EUR · 01/2026 → present', style: AppTextStyles.mono12),
            const SizedBox(height: 8),
            Text('CATEGORY · PACKAGE',          style: AppTextStyles.monoMuted10),
          ],
        ),
      ),
    ),
  ]),
  GallerySection('Atoms', [
    GalleryEntry(
      'SectionLabel',
          (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SectionLabel('Photography Studio'),
            const SizedBox(height: 16),
            SectionLabel('Category'),
            const SizedBox(height: 16),
            SectionLabel('Pricing'),
          ],
        ),
      ),
    ),
    GalleryEntry(
      'CheckCircle + EmptyCircle',
          (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CheckCircle(),
            const SizedBox(width: 16),
            const EmptyCircle(),
          ],
        ),
      ),
    ),
    GalleryEntry(
      'CurrentBadge',
          (_) => const Padding(
        padding: EdgeInsets.all(24),
        child: CurrentBadge(),
      ),
    ),
    // All atoms together as they appear in context
    GalleryEntry(
      'Atoms / in context',
          (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SectionLabel('Pricing'),
            const SizedBox(height: 16),
            Row(
              children: [
                const CheckCircle(),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('01/2026 → present', style: AppTextStyles.mono12),
                    const SizedBox(height: 8),
                    const CurrentBadge(),
                  ],
                ),

              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const EmptyCircle(),
                const SizedBox(width: 8),
                Text('01/2025 → 12/2025', style: AppTextStyles.monoMuted12),
              ],
            ),
          ],
        ),
      ),
    ),
    GalleryEntry(
      'AvatarChip / sizes',
          (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AvatarChip(initials: 'AF'),
            const SizedBox(width: 12),
            AvatarChip(initials: 'JB', size: 40),
            const SizedBox(width: 12),
            AvatarChip(initials: 'CR', size: 48),
          ],
        ),
      ),
    ),

    GalleryEntry(
      'Cell icons / configured + unconfigured',
          (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ConfiguredCellIcon(),
            const SizedBox(width: 16),
            const UnconfiguredCellIcon(isHovered: false),
            const SizedBox(width: 16),
            const UnconfiguredCellIcon(isHovered: true),
          ],
        ),
      ),
    ),

    GalleryEntry(
      'ProgressBar',
          (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProgressBar(current: 0,  total: 25),
            const SizedBox(height: 16),
            ProgressBar(current: 8,  total: 25),
            const SizedBox(height: 16),
            ProgressBar(current: 25, total: 25),
          ],
        ),
      ),
    ),

    GalleryEntry(
      'WebhookUrlRow',
          (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 480,
          child: WebhookUrlRow(
            url: 'https://hooks.jotform.com/webhook/m1_c1_ab3f9x2k',
          ),
        ),
      ),
    ),
  ]),
  GallerySection('Molecules', [
    GalleryEntry(
      'ColumnHeader',
          (_) => const SizedBox(
        width: 300,
        child: ColumnHeader('Category'),
      ),
    ),
    GalleryEntry(
      'CategoryRow / states',
          (_) => SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CategoryRow(name: 'Tourist',  isSelected: false, onTap: () {}),
            CategoryRow(name: 'Wedding',  isSelected: true,  onTap: () {}),
            CategoryRow(name: 'Business', isSelected: false, onTap: () {}),
          ],
        ),
      ),
    ),
    GalleryEntry(
      'PackageRow / states',
          (_) => SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PackageRow(
              name: 'Package A',
              description: '1 hour city walk, 20 edited photos',
              currentPrice: '160 EUR',
              isSelected: false,
              onTap: () {},
            ),
            PackageRow(
              name: 'Package B',
              description: '2 hours, 2 locations, 40 edited photos',
              currentPrice: '260 EUR',
              isSelected: true,
              onTap: () {},
            ),
          ],
        ),
      ),
    ),
    GalleryEntry(
      'PriceHistoryRow / states',
          (_) => SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PriceHistoryRow(
              from: '01/2024', to: '12/2024',
              amount: '120', currency: 'EUR',
              isCurrent: false,
            ),
            PriceHistoryRow(
              from: '01/2025', to: '12/2025',
              amount: '140', currency: 'EUR',
              isCurrent: false,
            ),
            PriceHistoryRow(
              from: '01/2026', to: null,
              amount: '160', currency: 'EUR',
              isCurrent: true,
            ),
          ],
        ),
      ),
    ),
    GalleryEntry(
      'MemberRow / states',
          (_) => SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MemberRow(
              name: 'Sophie Martin',
              role: 'Senior Photographer',
              email: 'sophie@studio.com',
              isSelected: false,
              onTap: () {},
              onEditTap: () {},
            ),
            MemberRow(
              name: 'Lucas Fontaine',
              role: 'Photographer',
              email: 'lucas@studio.com',
              isSelected: true,
              onTap: () {},
              onEditTap: () {},
            ),
            MemberRow(
              name: 'Amélie Dubois',
              role: 'Junior Photographer',
              email: 'amelie@studio.com',
              isSelected: false,
              onTap: () {},
              onEditTap: () {},
            ),
          ],
        ),
      ),
    ),

    GalleryEntry(
      'MemberEditForm',
          (_) => SizedBox(
        width: 280,
        child: MemberEditForm(
          initialName: 'Sophie Martin',
          initialRole: 'Senior Photographer',
          initialEmail: 'sophie@studio.com',
          onSave: (name, role, email) {},
          onCancel: () {},
        ),
      ),
    ),

    GalleryEntry(
      'CommissionRow / states',
          (_) => SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommissionRow(
              packageName: 'Package A',
              categoryName: 'Tourist',
              categoryId: 0,
              value: '10',
              isPercent: true,
              onValueChanged: (_) {},
              onTypeChanged: (_) {},
              onRemove: () {},
            ),
            CommissionRow(
              packageName: 'Package B',
              categoryName: 'Wedding',
              categoryId: 1,
              value: '150',
              isPercent: false,
              onValueChanged: (_) {},
              onTypeChanged: (_) {},
              onRemove: () {},
            ),
            CommissionRow(
              packageName: 'Package C',
              categoryName: 'Business',
              categoryId: 2,
              value: '8',
              isPercent: true,
              onValueChanged: (_) {},
              onTypeChanged: (_) {},
              onRemove: () {},
            ),
          ],
        ),
      ),
    ),

    GalleryEntry(
      'CategoryBadge / all colors',
          (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            CategoryBadge(categoryName: 'Tourist',   categoryId: 0),
            CategoryBadge(categoryName: 'Wedding',   categoryId: 1),
            CategoryBadge(categoryName: 'Business',  categoryId: 2),
            CategoryBadge(categoryName: 'Portrait',  categoryId: 3),
            CategoryBadge(categoryName: 'Event',     categoryId: 4),
            CategoryBadge(categoryName: 'Product',   categoryId: 5),
            CategoryBadge(categoryName: 'Editorial', categoryId: 6),
            CategoryBadge(categoryName: 'Fashion',   categoryId: 7),
            CategoryBadge(categoryName: 'Sport',     categoryId: 8),
            CategoryBadge(categoryName: 'Aerial',    categoryId: 9),
          ],
        ),
      ),
    ),

    GalleryEntry(
      'CommissionTypeToggle / states',
          (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Percent active', style: AppTextStyles.muted12),
            const SizedBox(height: 8),
            CommissionTypeToggle(isPercent: true,  onChanged: (_) {}),
            const SizedBox(height: 16),
            Text('EUR active', style: AppTextStyles.muted12),
            const SizedBox(height: 8),
            CommissionTypeToggle(isPercent: false, onChanged: (_) {}),
          ],
        ),
      ),
    ),


    GalleryEntry(
      'MatrixCell / states',
          (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 80,
              child: MatrixCell(isConfigured: false, onTap: () {}),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 80,
              child: MatrixCell(isConfigured: true, onTap: () {}),
            ),
          ],
        ),
      ),
    ),

    GalleryEntry(
      'MatrixColumnHeader',
          (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MatrixColumnHeader(name: 'Wedding',   color: Color(0xFFF59E0B)),
            MatrixColumnHeader(name: 'Portrait',  color: Color(0xFF8B5CF6)),
            MatrixColumnHeader(name: 'Corporate', color: Color(0xFF3B82F6)),
          ],
        ),
      ),
    ),

    GalleryEntry(
      'FieldMappingRow',
          (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FieldMappingRow(
                jotformField: 'q1_name',
                targetField: 'client_name',
                jotformOptions: ['q1_name', 'q2_email', 'q3_phone', 'q4_date'],
                targetOptions: ['client_name', 'client_email', 'phone', 'shoot_date'],
                onJotformChanged: (_) {},
                onTargetChanged: (_) {},
                onRemove: () {},
              ),
              const SizedBox(height: 8),
              FieldMappingRow(
                jotformField: '',
                targetField: '',
                jotformOptions: ['q1_name', 'q2_email', 'q3_phone', 'q4_date'],
                targetOptions: ['client_name', 'client_email', 'phone', 'shoot_date'],
                onJotformChanged: (_) {},
                onTargetChanged: (_) {},
                onRemove: () {},
              ),
            ],
          ),
        ),
      ),
    ),

    GalleryEntry(
      'MatrixMemberRow / expanded',
          (_) => SizedBox(
        width: 700,
        child: MatrixMemberRow(
          memberId: 'm1',
          name: 'Aurelie Fontaine',
          email: 'aurelie@studio.fr',
          initials: 'AF',
          categories: const [
            MatrixCategoryData(id: 'c1', name: 'Wedding',   color: Color(0xFFF59E0B)),
            MatrixCategoryData(id: 'c2', name: 'Portrait',  color: Color(0xFF8B5CF6)),
            MatrixCategoryData(id: 'c3', name: 'Corporate', color: Color(0xFF3B82F6)),
          ],
          configuredCategoryIds: {'c1', 'c3'},
          isCollapsed: false,
          onToggleCollapse: () {},
          onCellTap: (_) {},
        ),
      ),
    ),

    GalleryEntry(
      'MatrixMemberRow / collapsed',
          (_) => SizedBox(
        width: 700,
        child: MatrixMemberRow(
          memberId: 'm1',
          name: 'Aurelie Fontaine',
          email: 'aurelie@studio.fr',
          initials: 'AF',
          categories: const [
            MatrixCategoryData(id: 'c1', name: 'Wedding',   color: Color(0xFFF59E0B)),
            MatrixCategoryData(id: 'c2', name: 'Portrait',  color: Color(0xFF8B5CF6)),
            MatrixCategoryData(id: 'c3', name: 'Corporate', color: Color(0xFF3B82F6)),
          ],
          configuredCategoryIds: {'c1', 'c3'},
          isCollapsed: true,
          onToggleCollapse: () {},
          onCellTap: (_) {},
        ),
      ),
    ),
  ]),
  GallerySection('Organisms', [
    // ThreeColumnCard, PackagePricingView go here
    GalleryEntry(
      'ThreeColumnCard',
          (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: ThreeColumnCard(
          categories: Fixtures.packageCategories,
        ),
      ),
    ),
    GalleryEntry(
      'WebhookConfigPanel',
          (_) => WebhookConfigPanel(
        memberName:    'Aurelie Fontaine',
        memberEmail:   'aurelie@studio.fr',
        categoryName:  'Wedding',
        categoryColor: const Color(0xFFF59E0B),
        webhookUrl:    'https://hooks.jotform.com/webhook/m1_c1_ab3f9x2k',
        jotformFields: Fixtures.jotformFields,
        targetFields:  Fixtures.targetFields,
        onSave:  (_) {},
        onClose: () {},
      ),
    ),

    GalleryEntry(
      'WebhookMatrixCard',
          (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: WebhookMatrixCard(
          members: const [
            MatrixMemberData(id: 'm1', name: 'Aurelie Fontaine', email: 'aurelie@studio.fr', initials: 'AF'),
            MatrixMemberData(id: 'm2', name: 'Jonas Berger',     email: 'jonas@studio.fr',   initials: 'JB'),
          ],
          categories: const [
            MatrixCategoryData(id: 'c1', name: 'Wedding',   color: Color(0xFFF59E0B)),
            MatrixCategoryData(id: 'c2', name: 'Portrait',  color: Color(0xFF8B5CF6)),
            MatrixCategoryData(id: 'c3', name: 'Corporate', color: Color(0xFF3B82F6)),
          ],
          configuredMap: {'m1': {'c1', 'c3'}},
          collapsedMemberIds: const {},
          onCellTap:        (_, __) {},
          onToggleCollapse: (_) {},
        ),
      ),
    ),
  ]),
  GallerySection('Screens',
    [GalleryEntry(
      'TeamCommissionsView',
          (_) => const SingleChildScrollView(
        child: TeamCommissionsView(businessId: 0,),
      ),
    ),
      GalleryEntry(
        'JotformMatrixView',
            (_) => const JotformMatrixView(businessId: 1,),
      ),
  ]),
  GallerySection('Nav', [
    GalleryEntry('NavTabItem / default',  (_) => NavTabItem(label: 'Pricing', isSelected: false, onTap: () {})),
    GalleryEntry('NavTabItem / selected', (_) => NavTabItem(label: 'Pricing', isSelected: true,  onTap: () {})),
    GalleryEntry('AppNavBar', (_) => Row( children: [ const AppNavBar(), Expanded(child: Container(color: AppColors.mainBg)),],), needsAuth: true,),
  ]),
];

class WidgetGalleryPage extends StatelessWidget {
  const WidgetGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        title: const Text('Widget Gallery'),
        backgroundColor: AppColors.active,
      ),
      body: ListView.builder(
        itemCount: sections.length,
        itemBuilder: (context, si) {
          final section = sections[si];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  section.title.toUpperCase(),
                  style: AppTextStyles.monoMuted10.copyWith(
                    letterSpacing: 2,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.active,
                  border: Border.symmetric(
                    horizontal: BorderSide(color: AppColors.border),
                  ),
                ),
                child: Column(
                  children: section.entries.mapIndexed((i, entry) => Column(
                    children: [
                      _GalleryTile(entry: entry),
                      if (i < section.entries.length - 1)
                        const Divider(height: 1, color: AppColors.border),
                    ],
                  )).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  final GalleryEntry entry;
  const _GalleryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final page = Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        title: Text(entry.name),
        backgroundColor: AppColors.active,
      ),
      body: Center(child: entry.builder(context)),
    );

    final wrapped = entry.needsAuth
        ? ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith((ref) => FakeAuthNotifier()),
      ],
      child: page,
    )
        : page;

    return Material(
      color: AppColors.active,
      child: ListTile(
        title: Text(entry.name, style: AppTextStyles.body14),
        trailing: const Icon(Icons.chevron_right, color: AppColors.mutedText),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => wrapped),
        ),
      ),
    );
  }
}

