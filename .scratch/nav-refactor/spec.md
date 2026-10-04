Status: needs-triage

# Navigation refactor: domain-grouped sidebar

## Problem

The left nav bar holds four route links (Business, packages, appointments, home) and is nearly useless. All real navigation lives in a 9-tab top bar on the Business page, together with the business picker. `/appointments` is not even a registered route.

## Design

### Shell
- One persistent shell: left sidebar + content area. Navigation is Riverpod state (selected section, selected sub-view), not named routes.
- Remove the `/businesses`, `/packages`, `/appointments` and `/home` named routes and the standalone `PackagesPage`. `/login`, `/register` stay.
- Reuse `TopNavBar` as the per-section secondary nav; the Business picker and "create business" leave it.

### Sidebar (top to bottom)
Dashboard, Appointments, Team, Catalog, Analytics, Report, Settings, spacer, Business picker, user card (logout).

| Section | Sub-views (secondary tabs) | Existing view |
|---|---|---|
| Dashboard | none | Overview placeholder |
| Appointments | Appointments, Calendar, Workflow | `AppointmentsPage`, `AppointmentCalendarPage`, `WorkflowPage` |
| Team | none | `TeamCommissionsView` (Member Commission stays here) |
| Catalog | none | `PackagesPricingView` |
| Analytics | none | "coming soon" placeholder |
| Report | none | "coming soon" placeholder |
| Settings | General (placeholder), Jotform, Jotform Integration | `JotformMatrixView`, `JotformIntegrationView` |

Single-view sections show no tab bar.

### Business picker
- Sits at the bottom of the sidebar, above the user card, as a dropdown showing the Selected Business name.
- "Create business" is an entry in the dropdown list (opens the existing create dialog).
- Selected Business is auto-selected (first) on load when none is chosen.
- Zero businesses: the shell shows one shared empty state ("Create or select a business") instead of the content. Remove the per-view `selectedBusiness == null` checks.

### Cross-links
`JotformMatrixView` currently sets `businessTabProvider = 'Jotform Integration'`; it must switch to the Settings section's Jotform Integration sub-view.

## Out of scope
- Role-based visibility of sidebar items (follow-up issue).
- Building Analytics and Report (placeholders only).
- Sidebar collapse / responsive behavior (fixed width).

## Domain language
Added to `GLOSSARY.md`: Catalog, Team, Analytics, Report, Selected Business. No ADR (easy to reverse).
