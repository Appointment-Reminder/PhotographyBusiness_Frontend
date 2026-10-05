# 07: Rework the Dashboard to the Figma design

**What to build:** Rework the existing Dashboard page and view state to match `docs/figma/Dashboard` as described in the spec addendum: new card set (My earnings, Business earnings, Commission payable, Total income with Income source split, Booked revenue, Appointments made, Average appointment value), Daily/Weekly/Monthly chart toggle, members table with Effective rate, placeholders where the backend gap list applies.

**Blocked by:** none (backend gaps in `docs/backend-requests/dashboard.md` do not block)

**Status:** ready-for-agent

- [ ] My earnings shows the logged-in Member's commission, hidden when no Member row matches
- [ ] Business earnings is hidden when `owner_take` is null; remaining cards fill the row
- [ ] Total income shows Deposit / Shooting session / Add-ons with shares computed from the three slices
- [ ] Commission split bars take three numbers and show 0 in every slice for My earnings and Business earnings
- [ ] Average appointment value shows a neutral "$0 from last period" placeholder
- [ ] Chart toggle Daily/Weekly/Monthly defaults to the automatic bucket and resets on Timeframe change; changing it refetches with that `group_by`
- [ ] Members table shows initials avatar and Effective rate (dash at zero income); no Rate/View all from the design, no Next payout
- [ ] Photographer view built from their own row; no role branching
- [ ] Notifier-level tests cover splits, hidden cards, toggle refetch and Effective rate; layout verified by running the app
