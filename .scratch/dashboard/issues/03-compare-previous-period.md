# 03: Compare with the previous period

**What to build:** Each headline figure shows its change versus the previous period as a percentage badge, with a caption naming the previous range (for example "vs 1 Sep – 30 Sep"). Increases in income, booked revenue and appointments read as good (green) and decreases as bad (red); Commission payable changes are neutral. A null change percent (the previous period was zero) shows a dash. When the backend returns no comparison, no badges or caption appear.

**Blocked by:** 01: Dashboard shows this month's headline figures

**Status:** ready-for-agent

- [ ] Each of the four headline figures shows its change percent from `comparison`
- [ ] The caption shows the previous range from `comparison`
- [ ] Tone is green for increases and red for decreases on income, booked revenue and appointments; neutral for Commission payable
- [ ] A null percent for a figure shows a dash
- [ ] A null `comparison` hides all badges and the caption
- [ ] Notifier-level tests cover the change values, the tones, a null percent and a null comparison
