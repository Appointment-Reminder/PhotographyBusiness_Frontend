# 02: Appointment events and Advance button

**What to build:** Every card has one Advance button that fires the next forward Appointment Event and moves the card one column right: Scheduled "Mark shot" (`photoshoot`), Pending Selection "Mark selected" (`selection`), Pending Editing "Mark edited" (`editing`), Pending Review "Mark reviewed" (`review`, the card then leaves the default board). Status changes only via `POST /appointments/business/{business_id}/appointments/{appointment_id}/{event}`; the UI never PATCHes `status`. Moves are optimistic and roll back with an error snackbar on failure. The Needs Assignment button is handled in ticket 04.

**Blocked by:** 01

**Status:** resolved

- [ ] Data layer (datasource, repository, use case, notifier action) can fire an Appointment Event
- [ ] Each Advance button fires the correct event for its column
- [ ] Card moves one column right optimistically; rolls back with an error snackbar on failure
- [ ] Card leaves the default board after review
- [ ] Backend permission errors surface as an error snackbar
- [ ] Event-to-column transition logic and rollback covered by tests

## Answer

Implemented on integration/appointment-workflow (tip d04444e).
