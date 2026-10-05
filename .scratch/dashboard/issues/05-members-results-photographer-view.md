# 05: Members' results, and the photographer view

**What to build:** The Dashboard shows a table of each Business Member's results (name, income, appointments made, commission earned), hidden when it has a single row. When the backend returns no Business-wide figures (a photographer sees only their own row), the headline figures are built from that Member's own row instead: Income, Booked revenue, Appointments, Commission earned, with no change badges. The app never branches on Business Role; it hides whatever comes back null or empty. The Selected Business works as for any other user.

**Blocked by:** 01: Dashboard shows this month's headline figures

**Status:** ready-for-agent

- [ ] The members table lists name, income, appointments made and commission earned, with amounts in the existing formatter
- [ ] The table is hidden when `members` has one row (or none)
- [ ] When `business` is null, the headline figures come from the single Member row with the labels Income, Booked revenue, Appointments, Commission earned
- [ ] In that fallback, no change badges or comparison caption are shown when `comparison` is null
- [ ] No code branches on Business Role
- [ ] Notifier-level tests cover the full response, the null-`business` fallback and the single-row table hiding
