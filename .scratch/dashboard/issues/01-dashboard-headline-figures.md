# 01: Dashboard shows this month's headline figures

**What to build:** The Dashboard section stops being a placeholder. It opens on the current month (first to last day, not ending today) and asks the backend for the Selected Business's overview for that Timeframe, always sending a `group_by` (day for this month). It shows the four headline figures (Total income, Booked revenue, Appointments made, Commission payable) using the existing amount formatter, with loading, error-with-retry and zero states. Switching the Selected Business reloads the figures. This ticket creates the overview repository, the Timeframe value, the provider keyed on (Selected Business, Timeframe) and the Dashboard view state, following the data / domain / presentation layout of the Appointment and Add-on features. See `spec.md` and `docs/api/business-overview.md`.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

- [ ] Work is on a new `feature/dashboard` branch created before any code; nothing pushed, no co-author line
- [ ] The Dashboard section renders the Dashboard page instead of the "in progress" placeholder
- [ ] The first request carries `from` = first day and `to` = last day of the current month as plain `yyyy-MM-dd`, and `group_by` = day
- [ ] The four headline figures display from `business`; amounts use the existing formatter
- [ ] Loading state on first load; error message with a retry that refetches
- [ ] Switching the Selected Business refetches for the new Business with the same Timeframe
- [ ] A response with no activity shows zeros
- [ ] Notifier-level tests with a fake repository cover the default request, the refetch on Business switch, the error and retry, and the zero state (prior art: `addon_catalog_notifier_test.dart`)
