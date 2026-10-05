# 02: Choose a Timeframe

**What to build:** A timeframe bar on the Dashboard with the presets This month (default), Last month, Last 30 days and This year, plus a Custom date range picker that allows future dates. The bar shows the resolved range (for example "1 Oct – 31 Oct 2026"). Changing the Timeframe refetches the overview, and the previous figures stay visible while the new ones load. The chosen Timeframe is kept in memory only: it survives switching the Selected Business and resets to This month on app restart. The `group_by` bucket is chosen from the range length with no user toggle: up to 31 days → day, up to about 120 days → week, longer → month.

**Blocked by:** 01: Dashboard shows this month's headline figures

**Status:** ready-for-agent

- [ ] Each preset resolves to the correct inclusive range; Custom uses the picked dates, including future ones
- [ ] The resolved range is displayed in the bar
- [ ] A change of Timeframe sends a new request with the matching `from`, `to` and bucket
- [ ] Ranges of 31 days or less send `day`, medium ranges `week`, long ranges `month`
- [ ] Previous figures stay visible while a refetch is in flight (no flash to empty)
- [ ] The Timeframe is kept when the Selected Business changes and is not persisted across restarts
- [ ] Notifier-level tests with a fake repository cover preset resolution, the bucket thresholds, refetch on change and Timeframe kept across a Business switch
