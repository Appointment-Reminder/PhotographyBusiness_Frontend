# 07: Assign by PATCH only (no `assign` event)

**What to build:** The backend moves an Appointment from `needs_assignment` to `pending` when `member_id` is PATCHed, so the UI must stop sending the `assign` event. Both the "Assign…" button and the Needs Assignment → Scheduled drag open the member picker and do a single `PATCH member_id`. The card takes its status from the PATCH response (no optimistic move); a PATCH that fails leaves the card untouched with an error snackbar. If the response still says `needs_assignment`, do nothing special and send no fallback event. "Assign to…" on assigned cards uses the same single method.

**Blocked by:** none (supersedes the PATCH-then-`assign` part of 04)

**Status:** ready-for-agent

- [ ] One notifier method PATCHes `member_id` and applies the returned `status` to the card; `assignAndSchedule` and `reassign` are merged
- [ ] "Assign…" and the Needs Assignment → Scheduled drop both call it; no `POST …/assign` is ever sent
- [ ] `AppointmentEvent.assign` removed; `eventForMove` no longer maps Needs Assignment → Scheduled to an event, and `_onDrop` routes that move straight to the picker
- [ ] The partial-failure `cardErrors` path for a failed `assign` after PATCH is removed (nothing left to fail)
- [ ] Tests updated: PATCH-only request, status taken from response, PATCH failure leaves the card in Needs Assignment, response still `needs_assignment` keeps the card there
- [ ] Verify `docs/api/openapi.json` / `docs/api/appointments.md` once the backend documents the PATCH side effect (`api-docs-sync`)
