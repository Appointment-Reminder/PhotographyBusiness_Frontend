# 07: Rework the Dashboard to the Figma design

**What to build:** Rework the existing Dashboard page and view state to match `docs/figma/Dashboard` as described in the spec addendum: new card set (My earnings, Business earnings, Commission payable, Total income with Income source split, Booked revenue, Appointments made, Average appointment value), Daily/Weekly/Monthly chart toggle, members table with Commission rate. The backend gaps were closed by the contract migration (issue 08).

**Blocked by:** none

**Status:** ready-for-agent

- [ ] My earnings shows the logged-in Member's commission, hidden when no Member row matches
- [ ] Business earnings is hidden when `owner_share_total` is null; remaining cards fill the row
- [ ] Total income shows Deposit / Shooting session / Add-ons with shares computed from the three slices
- [ ] Commission split bars take three numbers; filled from the backend split for My earnings and Business earnings (issue 08)
- [ ] Average appointment value shows the amount change from last period (issue 08)
- [ ] Chart toggle Daily/Weekly/Monthly defaults to the automatic bucket and resets on Timeframe change; changing it refetches with that `group_by`
- [ ] Members table shows initials avatar and Commission rate (dash when null); no Rate/View all from the design, no Next payout
- [ ] Photographer view built from their own row; no role branching
- [ ] Notifier-level tests cover splits, hidden cards, toggle refetch and Commission rate; layout verified by running the app
