# 04: Income-over-time chart

**What to build:** The Dashboard shows a stacked bar chart of income over time, deposit and balance per bucket, from the overview's series. It adds the `fl_chart` package. A period with no activity replaces the chart with a "No activity in this period" note while the headline figures read zero. The chart draws whichever bucket (day, week or month) the request used, so it needs no change when the Timeframe picker lands.

**Blocked by:** 01: Dashboard shows this month's headline figures

**Status:** ready-for-agent

- [ ] `fl_chart` is added and the chart renders deposit and balance stacked per bucket from `series`
- [ ] Each bar is labelled with its bucket start date appropriately for the bucket size
- [ ] An empty period shows "No activity in this period" in place of the chart; KPIs remain as zeros
- [ ] A null `series` is handled without error (treated as no chart data)
- [ ] The chart data in the view state is covered by notifier-level tests (points, empty flag, null series); chart rendering itself is verified by running the app
