Status: ready-for-agent

# Dashboard: financial overview of the Selected Business over a Timeframe

## Problem Statement

The Dashboard section of the app is an empty placeholder ("Dashboard of <business> in progress"). A Business owner or admin has no place to see how the Selected Business is doing financially: how much came in, how much is booked, what commission is payable, and how that compares with the previous period. A photographer has no place to see their own results. The backend now exposes an overview endpoint that answers all of this for a chosen range of days, but nothing in the app asks for it.

## Solution

The Dashboard section shows the financial overview of the Selected Business for a Timeframe the user picks. It opens on the current month. The user changes the Timeframe with presets (This month, Last month, Last 30 days, This year) or a custom date range, and the page asks the backend for that range and redraws: headline figures compared with the previous period, an income-over-time chart, and the results of each Business Member. What the user sees follows what the backend returns for their Business Role; the app does not branch on role.

## User Stories

1. As a Business owner, I want the Dashboard to open on the current month, so that I immediately see how this month is going.
2. As a Business owner, I want to see Total income for the Timeframe, so that I know how much money actually came in.
3. As a Business owner, I want to see Booked revenue for the Timeframe, so that I know the value of what was sold, not only what was paid.
4. As a Business owner, I want to see the number of Appointments made, so that I know how busy the Business was.
5. As a Business owner, I want to see Commission payable, so that I know what the Business owes its Members.
6. As a Business owner, I want each headline figure to show its change versus the previous period, so that I can tell whether the Business is growing.
7. As a Business owner, I want the comparison to name the previous range (for example "vs 1 Sep – 30 Sep"), so that I know what I am being compared with.
8. As a Business owner, I want a missing change percent (the previous period was zero) to show as a dash, so that I am not shown a misleading number.
9. As a Business owner, I want increases in income, booked revenue and appointments shown as good and decreases as bad, so that I can read the trend at a glance.
10. As a Business owner, I want Commission payable changes shown neutrally, so that a rise is not wrongly presented as good or bad.
11. As a Business owner, I want a chart of income over time split into deposit and balance, so that I can see when money came in and in what form.
12. As a Business owner, I want the chart to group by day for short ranges, by week for medium ranges and by month for long ranges, so that it stays readable without me choosing.
13. As a Business owner, I want to see each Business Member's income, appointments and commission earned in a table, so that I can compare their results.
14. As a Business owner, I want to pick This month, Last month, Last 30 days or This year in one tap, so that common ranges are fast.
15. As a Business owner, I want to pick a custom start and end date, so that I can look at any period.
16. As a Business owner, I want to be able to pick dates in the future, so that a range like "this year" is not blocked.
17. As a Business owner, I want the Dashboard to show the resolved range (for example "1 Oct – 31 Oct 2026"), so that I know exactly what I am looking at.
18. As a Business owner, I want "This month" to run from the 1st to the last day of the month, so that it matches the calendar month.
19. As a Business owner, I want my chosen Timeframe to stay when I switch the Selected Business, so that I can compare Businesses over the same period.
20. As a Business owner, I want the Dashboard to reload when I switch the Selected Business, so that I never see another Business's numbers.
21. As a Business owner, I want the Dashboard to reload when I change the Timeframe, so that the figures always match the range shown.
22. As a Business owner, I want the previous figures to stay visible while new ones load, so that the page does not flash empty on every change.
23. As a Business owner, I want a clear loading state on first load, so that I know the page is working.
24. As a Business owner, I want an error message with a retry button when the overview cannot be loaded, so that I can recover without leaving the page.
25. As a Business owner, I want a "No activity in this period" note in place of the chart when nothing happened, so that an empty range is clear and not mistaken for a bug.
26. As a Business owner, I want the figures to read zero, not disappear, in an empty period, so that the layout stays stable.
27. As a Business owner, I want a chip telling me how many Unresolved Add-ons there are, so that I know there is cleanup to do.
28. As a Business owner, I want tapping the Unresolved Add-ons chip to take me to Appointments, so that I can resolve them.
29. As a Business owner, I want a chip telling me how many commissions are above the balance, so that I notice a payout problem.
30. As a Business owner, I want those chips hidden when the count is zero, so that the page is not cluttered.
31. As a Business owner, I want the Dashboard timeframe to reset to "This month" when I restart the app, so that it always opens on the current period.
32. As a photographer, I want the Dashboard to show only my own results, so that I see what I earned without seeing other Members.
33. As a photographer, I want headline figures built from my own results (Income, Booked revenue, Appointments, Commission earned), so that the page is useful even though I have no Business-wide figures.
34. As a photographer, I want no members table when it would only list me, so that the page is not redundant.
35. As a photographer, I want no change percentages when none are provided, so that I am not shown empty badges.
36. As a photographer, I want to keep my Selected Business like any other user, so that the Dashboard shows the Business I am working in.
37. As an admin, I want the same view as an owner, except for owner-only figures, so that I see everything I am allowed to.
38. As a user with several Businesses, I want the Dashboard to always reflect the Selected Business, so that figures are never mixed.
39. As a user on a small window, I want the KPI row and members table to remain usable, so that the page is not broken when narrow.
40. As a user, I want amounts formatted the same way as everywhere else in the app, so that numbers look consistent.

## Implementation Decisions

- **Glossary:** Dashboard and Timeframe are defined in `GLOSSARY.md`. Dashboard is financial and time-based; Analytics is non-financial data and Report is a PDF builder; both are out of scope here.
- **Endpoint:** one call, `GET /business/{business_id}/overview`, with `from` and `to` (plain dates, `yyyy-MM-dd`, Paris time, both inclusive, sent without any timezone conversion) and `group_by`. `member_id` is not used. Contract: `docs/api/business-overview.md`.
- **Response shape:** `business` (headline figures), `members` (one row per Member), `comparison` (previous range, previous headline, change percent per figure) and `series` (income per bucket). `business`, `comparison` and `series` can each be null; `series` is only returned when `group_by` is sent, so the app always sends it. Percent changes can individually be null.
- **Timeframe:** a value with a start date and an end date, plus the preset it came from. Presets: This month (default; first to last day of the current month, not ending on today), Last month, Last 30 days, This year, Custom. Custom is chosen with a date range picker; future dates are allowed. The Timeframe is held in memory only: it survives switching the Selected Business and resets on restart.
- **Bucket choice:** derived from the Timeframe length, with no user toggle: up to 31 days → day, up to about 120 days → week, longer → month. This month therefore groups by day.
- **Data flow:** an overview repository fetches by Business id, Timeframe and bucket. A state holder owns the Timeframe. An auto-disposing provider keyed on (Selected Business, Timeframe) fetches the overview, so changing either refetches. The page shows loading, error with retry, and keeps the previous data visible while refetching. No cache beyond the provider's lifetime. The layout follows the existing data / domain / presentation split and the existing Riverpod conventions of the Appointment and Add-on features.
- **Dashboard view state:** the presentation layer turns the raw overview into a view state the page can render without further logic: the KPI list (label, value, change, change tone), the chart points (deposit and balance per bucket), the members rows, the alert chips and an "is empty" flag. This is where the role-agnostic fallback lives.
- **KPI row:** when `business` is present: Total income, Booked revenue, Appointments made, Commission payable, each with its change percent and the previous-range caption. Green for increases and red for decreases on income, booked revenue and appointments; neutral for Commission payable. A null percent shows a dash.
- **Fallback when `business` is null (photographer):** build the KPI row from the single Member row: Income, Booked revenue, Appointments, Commission earned. Hide change badges when `comparison` is null. Hide the members table when it has one row. Do not branch on Business Role anywhere; hide whatever comes back null or empty.
- **Chart:** stacked bar chart of deposit and balance income per bucket, using the `fl_chart` package (new dependency). When the period has no activity, replace it with a "No activity in this period" note while the KPIs show zeros.
- **Members table:** name, income, appointments made, commission earned. Amounts use the existing amount formatter.
- **Alert chips:** Unresolved Add-ons (navigates to the Appointments section; filtered only if an Appointments filter for Unresolved Add-ons already exists) and commissions above balance (informational, not tappable). Each is hidden at zero.
- **Money format:** reuse the existing amount formatter. The overview carries no currency, so the Dashboard shows amounts without per-figure currency unless the surrounding app already appends one; do not invent per-Business currency.
- **Navigation:** the Dashboard section's placeholder content in the app shell is replaced by the Dashboard page. No new routes.
- **Out-of-contract data:** the Dashboard relies only on `docs/api/business-overview.md`, never on backend internals.

## Testing Decisions

- **Good test:** drives the feature through its public behavior (set a Timeframe or switch the Selected Business, then assert what was requested from the backend and what the view state says), not through private helpers, widget internals or provider wiring.
- **One seam:** the Dashboard notifier / provider with a fake overview repository, the highest point that exercises everything user-visible. The Timeframe-to-request mapping, the bucket choice, the fallback and the empty state are all verified through this seam: the fake records the arguments it was called with, and the resulting view state is asserted.
- **Behaviours to cover:**
  - the default Timeframe is the current month, first to last day, and the first request carries those dates and `group_by` day;
  - each preset resolves to the right range, and Custom uses the chosen dates;
  - a range of 31 days or less asks for day buckets, a medium range for week, a long range for month;
  - changing the Timeframe refetches; switching the Selected Business refetches with the same Timeframe;
  - previous data stays available while a refetch is in flight;
  - a failure produces an error state and a retry refetches;
  - a full response produces the four KPIs with change percents and tones, including a null percent and Commission payable being neutral;
  - a null `business` falls back to the Member row KPIs, with no change badges when `comparison` is null, and no members table for one row;
  - a response with no activity produces the empty state with zeros;
  - alert chips appear only when their count is above zero.
- **Prior art:** `test/features/addon/addon_catalog_notifier_test.dart` and the Appointment list notifier tests (fake repository implementing the domain interface, recording calls, returning `Right` / `Left`); `test/core/money_format_test.dart` for formatter-level tests.
- **Not tested:** the chart rendering and widget layout (no golden or pixel tests); verified by running the app.

## Out of Scope

- The `member_id` filter and any per-Member drill-down.
- Revenue by package, revenue by category, top add-ons and referral sources.
- Outstanding balance, average appointment value, cancellation rate, add-on attach rate, package balance, add-on income and owner take as displayed figures.
- A Day / Week / Month toggle on the chart.
- Persisting the Timeframe across restarts.
- Exporting or printing (that is Report) and non-financial metrics (that is Analytics).
- Per-Business currency.
- Any backend change.

## Further Notes

- The Selected Business is remembered by the app already; the Dashboard only reads it.
- Branching: implement on a new `feature/dashboard` branch created before any code; never push; no co-author line in commits.
- Check before building that the Appointments section has no existing Unresolved Add-ons filter, and follow the Appointment and Add-on providers' conventions for the family provider.

## Addendum: Figma redesign (docs/figma/Dashboard)

Supersedes the earlier decisions where it conflicts. Out-of-scope items below that this brings in: owner share, shooting and add-ons income, average appointment value, the chart bucket toggle. The backend delivered everything the design needed; field names follow `docs/api/business-overview.md` (see the contract migration addendum below).

- **Approach:** rework the existing Dashboard page and view state; keep the data and domain layers and the notifier tests.
- **Cards:** My earnings (from the logged-in Member's row, found through `my_member_id`; hidden when no row matches), Business earnings / Owner take (owner only, hidden when `owner_share_total` is null), Commission payable, Total income, Booked revenue, Appointments made, Appointments booked, Average appointment value. Each has its change versus the previous period where the API provides one.
- **Splits:** Total income splits Deposit / Shooting session / Add-ons from `deposit_income`, `shooting_income`, `addons_income`, with shares computed against the sum of the three. My earnings splits the own row's `photographer_share_deposit/shooting/addons`, Business earnings splits `owner_share_deposit/shooting/addons`. A split that differs from its card's total is flagged to the user on that card, not silently adjusted. The bar logic takes three numbers.
- **Dropped from the design:** Next payout footer, the Average booking value sparkline, "View all" on the members table.
- **Average appointment value:** replaces "Average booking value". The change is the amount gained or lost versus `comparison.previous.average_appointment_value` ("Up $X from last period"), good when up and bad when down; no change without a comparison.
- **Members table:** name with initials avatar, income (`total_income`), appointments made, commission earned (`photographer_share_total`) and Commission rate (`photographer_share_rate`, a dash when null). The row with a null `member_id` is shown last as "Unassigned", without avatar or rate, and does not count toward showing the table.
- **Chart toggle:** Daily | Weekly | Monthly, defaulting to the automatic bucket and overriding it; resets when the Timeframe changes.
- **Photographer / admin:** hide whatever is null, no role branching. A photographer sees My earnings, Booked revenue, Appointments made, Appointments booked and Average appointment value from their own row. An admin lacks only Business earnings, and the other cards fill the row.
- **Alert chips:** Unresolved Add-ons only navigates to Appointments (no Unresolved Add-ons filter exists there).

## Addendum: overview contract migration

The backend simplified the overview response. Field mapping: `commission_payable` is `business.photographer_share_total`; `owner_take` is `business.owner_share_total`; `package_balance` is `shooting_income`; `addon_income` is `addons_income`; Member `income` is `total_income`; Member `commission_earned` is `photographer_share_total`; series `balance_income` is `shooting_income` + `addons_income`.

- **Appointments booked:** a card of its own right after Appointments made, with a percent change (good when up) from `appointments_booked`. It deviates from the Figma, which has no such card. A photographer's fallback reads the own row; the card hides when there is no row. `appointments_booked` counts as activity, so a booked-but-unpaid period is not "No activity".
- **Logged-in Member:** `my_member_id` from the response replaces the separate Members lookup.
- **Still out of scope:** `outstanding_balance`, `cancellation_rate`, `addon_attach_rate`, `top_addons`, `revenue_by_package`, `revenue_by_category`, `referral_sources`, `shot_revenue`, the `member_id` filter.
