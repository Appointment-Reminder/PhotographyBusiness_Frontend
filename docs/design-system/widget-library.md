# PhotographyHandler — Widget Library

Component inventory for Flutter implementation. Organized by atomic → composite widgets.

**Figma file:** [PhotographyHandler-Front](https://www.figma.com/design/9vhSO4cxgnm0u31jSCju9R/PhotographyHandler-Front)  
**Design System page:** `01 — Design System`  
**Snapshot:** `docs/figma-snapshots/2026-06-17/`

---

## Figma page layout (recommended sections)

On `01 — Design System`, group components in labeled sections (use Figma **Sections**):

| Section | Y-offset | Contents |
|---------|----------|----------|
| `Foundations` | 0 | Cover, color/spacing reference |
| `01 — Buttons` | 200 | Primary, Secondary, Destructive, Text |
| `02 — Badges` | 400 | Status, Role |
| `03 — Form inputs` | 600 | TextField, Select, DatePicker, JSON editor |
| `04 — Cards` | 900 | Stat, Appointment, Business, Package, Member, Review |
| `05 — Navigation` | 1400 | Nav item, Tab chip, Breadcrumb, Page header |
| `06 — Selectors` | 1700 | Business dropdown, User/photographer picker |
| `07 — Lists & rows` | 2000 | Commission row, Price history row, Matrix cell |
| `08 — Feedback` | 2300 | Empty state, Error state, Snackbar, Confirm dialog |
| `09 — Layout` | 2600 | Auth card, Sidebar shell, Modal shell |

---

## 01 — Buttons

| Figma component | Flutter target | Variants | Used on |
|---------------|----------------|----------|---------|
| `Button/Primary` | `core/widgets/app_button.dart` | default, loading, disabled | Login, Create business, Save |
| `Button/Secondary` | same | outline | Cancel, Back |
| `Button/Destructive` | same | `variant: destructive` | Delete appointment, Remove member |
| `Button/Text` | same | `variant: text` | Register link, + Add category |
| `FAB/Create` | themed `FloatingActionButton` | — | Appointments, Businesses |

**Props:** `label`, `onPressed`, `isLoading`, `icon?`

**Exists:** partial (raw `ElevatedButton` / `TextButton` in pages)  
**Action:** extract `AppButton` with design tokens

---

## 02 — Badges

| Figma component | Flutter target | Variants | API / data |
|---------------|----------------|----------|------------|
| `Badge/Pending` | `core/widgets/status_badge.dart` | pending | appointment status filter |
| `Badge/Confirmed` | same | confirmed | |
| `Badge/NeedsReview` | same | needsReview | `needs_review=true` |
| `Badge/Paid` | same | paid | payment panel |
| `RoleBadge/Owner` | `core/widgets/role_badge.dart` | owner | `BusinessMemberRead.role` |
| `RoleBadge/Admin` | same | admin | |
| `RoleBadge/Photographer` | same | photographer | |
| `Chip/Filter` | `core/widgets/filter_chip.dart` | selected, default | Appointments status bar |
| `Chip/Tab` | `core/widgets/tab_chip.dart` | active, inactive | Business settings tabs |

**Props:** `StatusBadge(status: AppointmentStatus)`  
**Exists:** none (inline text/colors today)  
**Action:** build `StatusBadge` + `RoleBadge`

---

## 03 — Form inputs

| Figma component | Flutter target | Variants | Used on |
|---------------|----------------|----------|---------|
| `Input/TextField` | `core/widgets/app_text_field.dart` | default, error, disabled | Login, Register, forms |
| `Input/Password` | same | `obscureText: true` | Login, Register |
| `Input/Select` | `core/widgets/app_dropdown.dart` | — | Role on invite, category |
| `Input/DateTime` | `core/widgets/app_date_field.dart` | date, dateTime | Appointment create/edit |
| `Input/CopyField` | `core/widgets/copy_field.dart` | read-only + copy btn | Webhook URL |
| `Input/JsonEditor` | `core/widgets/json_field_map_editor.dart` | v1: multiline JSON | Jotform field map |
| `Input/Percent` | `core/widgets/percent_field.dart` | 0–100 | Commission row |

**Props:** `label`, `hint`, `controller`, `validator`, `errorText`  
**Exists:** raw `TextFormField` with `OutlineInputBorder`  
**Action:** extract `AppTextField`; add `CopyField` + `PercentField` for config screens

---

## 04 — Cards

| Figma component | Flutter target | Data model | Used on |
|---------------|----------------|------------|---------|
| `Card/Stat` | `core/widgets/stat_card.dart` | `label`, `value`, `onTap?` | Dashboard KPIs |
| `Card/Appointment` | `features/appointment/.../appointment_card.dart` | `AppointmentRead` | Appointments list, Dashboard |
| `Card/AppointmentReview` | `features/appointment/.../review_appointment_card.dart` | + Jotform source | Review queue |
| `Card/Business` | `features/business/.../business_card.dart` | `BusinessRead` | Businesses list |
| `Card/Package` | `features/package/.../package_card.dart` | `PackageRead` + current price | Catalog, Packages list |
| `Card/Member` | `features/business/.../member_list_item.dart` | `BusinessMemberRead` | Team tab |
| `Card/PriceSummary` | `features/package/.../price_summary_card.dart` | `PackagePriceRead` | Package detail |
| `Card/FormCell` | `features/business/.../form_matrix_cell.dart` | configured / empty / incomplete | Forms matrix |

### Card anatomy (shared)

```
┌─────────────────────────────────────┐
│ [leading]  Title          [badge] │
│            subtitle line 1          │
│            subtitle line 2          │
│            [trailing actions]     │
└─────────────────────────────────────┘
```

**Base:** `core/widgets/app_card.dart` — white surface, `radius/md`, optional left accent border (appointments)

| Card | Leading | Title | Subtitle | Badge | Accent |
|------|---------|-------|----------|-------|--------|
| Stat | — | value (large) | label | — | — |
| Appointment | avatar (client initial) | client_name | date, email, phone | status | photographer color border |
| Business | avatar (business initial) | name | description | active/inactive | — |
| Package | — | name | category · price summary | active | — |
| Member | avatar (user) | user.name | user.email | role | active dot |
| Review | warning icon | client_name | submission id, package | needs review | warning border |

**Exists:** AppointmentCard, BusinessCard, PackageCard (basic), MemberListItem  
**Action:** unify padding/radius via `AppCard`; add Review + PriceSummary + FormCell

---

## 05 — Navigation

| Figma component | Flutter target | Used on |
|---------------|----------------|---------|
| `Nav/Sidebar` | `core/widgets/app_nav_bar.dart` | All authenticated screens |
| `Nav/SidebarItem` | extract from nav bar | active / inactive + badge count |
| `Nav/PageHeader` | `core/widgets/app_page_header.dart` | title + action slot |
| `Nav/Breadcrumb` | `core/widgets/breadcrumb.dart` | `Sunset Studios / Catalog` |
| `Nav/TabBar` | `core/widgets/segmented_tabs.dart` | Business settings, Package detail |

**Sidebar items:** Dashboard, Appointments, Review queue (badge), Businesses, Packages, Settings, Logout

**Exists:** `AppNavBar` (monolithic)  
**Action:** split `SidebarItem`; add `AppPageHeader` to fix double AppBar

---

## 06 — Selectors

| Figma component | Flutter target | API | Used on |
|---------------|----------------|-----|---------|
| `Selector/Business` | `features/appointment/.../business_selector.dart` | `GET /business/me` | Appointments, Dashboard, Packages |
| `Selector/Photographer` | `features/appointment/.../user_selector.dart` | business members | Create/edit appointment |
| `Selector/Category` | `features/package/.../category_selector.dart` | `GET .../categories` | Create package |
| `Selector/Package` | `features/package/.../package_selector.dart` | `GET .../packages` | Commissions by package |

**Exists:** BusinessSelector, UserSelector  
**Action:** add CategorySelector, PackageSelector; promote BusinessSelector to `core/widgets/`

---

## 07 — Lists & rows (non-card)

| Figma component | Flutter target | Used on |
|---------------|----------------|---------|
| `Row/PriceHistory` | `features/package/.../price_history_row.dart` | Package detail |
| `Row/Commission` | `features/business/.../commission_row.dart` | member name + % input |
| `Row/MatrixHeader` | `features/business/.../form_matrix_header.dart` | Forms tab |
| `Row/MatrixCell` | `features/business/.../form_matrix_cell.dart` | ✓ / — / ⚠ |

**Commission row props:** `memberName`, `percent`, `onChanged`, `effectiveFrom`

---

## 08 — Feedback & overlays

| Figma component | Flutter target | Used on |
|---------------|----------------|---------|
| `State/Empty` | `core/widgets/empty_state.dart` | All lists |
| `State/Error` | `core/widgets/error_state.dart` | API failures |
| `State/Loading` | `core/widgets/loading_skeleton.dart` | Lists (optional skeleton) |
| `Dialog/Confirm` | `core/widgets/confirm_dialog.dart` | Delete flows |
| `Dialog/InviteMember` | `features/business/.../invite_member_dialog.dart` | Team tab |
| `Dialog/AddPrice` | `features/package/.../add_price_dialog.dart` | Package detail |
| `Dialog/AddCategory` | `features/package/.../add_category_dialog.dart` | Catalog |
| `Snackbar/Success` | themed `SnackBar` | Save feedback |

**Empty state props:** `icon`, `title`, `message`, `actionLabel?`, `onAction?`

**Exists:** InviteMemberDialog; inline error/empty in pages  
**Action:** extract EmptyState, ErrorState, ConfirmDialog, AddPriceDialog

---

## 09 — Layout shells

| Figma frame | Flutter target | Notes |
|-------------|----------------|-------|
| `Layout/AuthCard` | login + register screens | centered card, no sidebar |
| `Layout/AppShell` | `core/layouts/main_layout.dart` | sidebar 250px + content |
| `Layout/Modal` | `showDialog` wrapper | max width 520 |
| `Layout/MasterDetail` | catalog tab | 280px left + flexible right |
| `Layout/Matrix` | forms tab | table-style grid |

**Exists:** MainLayout, AppNavBar  
**Action:** remove nested Scaffolds; shell owns single AppBar via PageHeader

---

## Implementation priority

### Phase A — Core primitives (unblocks all screens)

1. `app_theme.dart` + tokens  
2. `AppButton`, `AppTextField`, `AppCard`  
3. `StatusBadge`, `RoleBadge`, `FilterChip`  
4. `EmptyState`, `ErrorState`, `ConfirmDialog`  
5. `AppPageHeader`, `SidebarItem` (refactor nav)

### Phase B — Domain cards (refactor existing)

6. Refactor `AppointmentCard`, `BusinessCard`, `PackageCard` on `AppCard`  
7. `StatCard` (Dashboard)  
8. `MemberListItem` → `MemberCard`  
9. `ReviewAppointmentCard`

### Phase C — Config widgets (business owner flows)

10. `CopyField`, `JsonFieldMapEditor`  
11. `FormMatrix` + `FormMatrixCell`  
12. `CommissionRow` + `PercentField`  
13. `PriceSummaryCard`, `PriceHistoryRow`, `AddPriceDialog`  
14. `CategorySelector`, `SegmentedTabs`

---

## Flutter folder structure

```
lib/core/
  theme/
    app_colors.dart
    app_theme.dart
  presentation/
    layouts/
      main_layout.dart
      auth_layout.dart
    widgets/
      app_button.dart
      app_text_field.dart
      app_card.dart
      stat_card.dart
      status_badge.dart
      role_badge.dart
      filter_chip.dart
      tab_chip.dart
      app_page_header.dart
      breadcrumb.dart
      empty_state.dart
      error_state.dart
      confirm_dialog.dart
      copy_field.dart
      percent_field.dart
      business_context_selector.dart

lib/features/
  appointment/presentation/widgets/
    appointment_card.dart
    review_appointment_card.dart
    business_selector.dart      → move to core when stable
    user_selector.dart
  business/presentation/widgets/
    business_card.dart
    member_card.dart
    invite_member_dialog.dart
    form_matrix.dart
    form_matrix_cell.dart
    commission_row.dart
  package/presentation/widgets/
    package_card.dart
    price_summary_card.dart
    price_history_row.dart
    add_price_dialog.dart
    category_selector.dart
```

---

## Figma ↔ Flutter naming map

| Figma | Flutter class |
|-------|---------------|
| `Button/Primary` | `AppButton.primary` |
| `Badge/NeedsReview` | `StatusBadge.needsReview` |
| `Card/Appointment` | `AppointmentCard` |
| `Card/Stat` | `StatCard` |
| `Input/CopyField` | `CopyField` |
| `Dialog/AddPrice` | `AddPriceDialog` |
| `Row/Commission` | `CommissionRow` |

---

## Next step

When Figma MCP rate limit resets, run a pass on `01 — Design System` to:

1. Wrap existing components into **Sections** (01–09 above)  
2. Add missing components: `Input/*`, `Chip/*`, `Row/*`, `Dialog/*`, `State/*`  
3. Convert screens to **instances** of components (not raw frames)

Say **"organize Figma components"** to trigger that pass, or **"implement Phase A widgets"** to start Flutter code.
