# 01: Workflow page with read-only board

**What to build:** A "Workflow" page, reachable from the same navigation as the appointment list and calendar, showing a Business's open Appointments as a Kanban board. One column per Appointment Status: Needs Assignment (also holds `new`), Scheduled (`pending`), Pending Selection, Pending Editing, Pending Review. Each column header shows label, description and count; a stats strip and an empty placeholder follow the Figma. The Scheduled column is not in the Figma: build it with the same styling as the other columns. Cards show client name, date, package badge (real package name, truncated, "—" when no package) and photographer avatar and colour bar (initials and stable colour derived from member id, grey when unassigned). A "Show closed" toggle reveals `completed`; `canceled` and `refunded` are never columns. The status-to-column mapping lives in one place in the domain layer. Reuses the existing appointment data layer. Also confirm whether the appointments endpoint's `status` and `member_id` filters suffice for the photographer view (feeds ticket 06).

**Blocked by:** None (can start immediately)

**Status:** resolved

- [ ] Workflow page reachable from the shared navigation
- [ ] Five columns in order, with header label, description and count
- [ ] Single domain-layer mapping from status strings to columns, including `new` in Needs Assignment
- [ ] Cards show client name, date, package badge and photographer avatar/colour per spec
- [ ] "Show closed" toggle reveals completed Appointments
- [ ] Stats strip and empty placeholder follow the Figma
- [ ] Mapping and card-data derivation covered by tests
- [ ] Finding on API filter sufficiency recorded in the ticket

## Comments

**API filter sufficiency (ticket 01 finding)** — Per `docs/api/appointments.md`, `GET /appointments/business/{business_id}` takes only `business_id` (path) and an optional `status` (query, single value, untyped `object`). There is **no `member_id` query parameter**; the description only says "for the currently loggedin user for business", so whether the backend scopes results by role is not documented. `status` filters one status at a time, so it cannot fetch the board's five columns in one call. Conclusion: the filters do not suffice for the photographer view. Ticket 01 fetches all business appointments (no `status`) and groups client-side. For ticket 06 (photographer/assistant scoping), filter client-side by `memberId` (the card's member id vs the current user's BusinessMember id), and treat any backend-side scoping as unverified until tested with a photographer account. `GET /appointments/me` (also `status` only) is an alternative worth checking, since it is user-scoped.

## Answer

Implemented on integration/appointment-workflow (tip d04444e).
