# 06: Alert chips

**What to build:** Two small chips on the Dashboard flag work to do: how many Unresolved Add-ons there are, and how many commissions are above the balance. Each shows only when its count is above zero. Tapping the Unresolved Add-ons chip takes the user to the Appointments section, where they can be resolved; it is filtered to Unresolved Add-ons only if an Appointments filter for them already exists (check first). The commissions chip is informational and not tappable.

**Blocked by:** 01: Dashboard shows this month's headline figures

**Status:** ready-for-agent

- [ ] The Unresolved Add-ons chip shows the count and is hidden at zero
- [ ] Tapping it navigates to the Appointments section (with the filter only if one already exists)
- [ ] The commissions-above-balance chip shows the count, is hidden at zero, and does nothing when tapped
- [ ] Notifier-level tests cover chips appearing and hiding by count
