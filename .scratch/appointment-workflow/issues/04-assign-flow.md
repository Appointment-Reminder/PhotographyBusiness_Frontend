# 04: Assign flow with member picker

**What to build:** On Needs Assignment cards the Advance button reads "Assign…" and opens a member picker; choosing a member does `PATCH member_id`, then fires `assign`, and the card moves to Scheduled. If `assign` fails after the PATCH, the card stays in place and shows an error. Already-assigned cards have an "Assign to…" action that only PATCHes `member_id` (no event). A Needs Assignment → Scheduled drag (ticket 03) uses this same flow; wire it in whichever ticket lands second.

**Blocked by:** 02

**Status:** resolved

- [ ] "Assign…" opens the picker and runs PATCH then `assign`
- [ ] Card moves to Scheduled on success; stays with an error if `assign` fails after PATCH
- [ ] "Assign to…" on assigned cards only PATCHes `member_id`
- [ ] Drag from Needs Assignment to Scheduled opens the picker and runs the same flow
- [ ] Partial-failure sequence covered by tests

## Answer

Implemented on integration/appointment-workflow (tip d04444e).
