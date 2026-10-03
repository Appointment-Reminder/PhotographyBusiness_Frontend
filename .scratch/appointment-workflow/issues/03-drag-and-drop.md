# 03: Drag and drop between columns

**What to build:** Dragging a card to another column fires the one Appointment Event for that (source, target) pair. Valid: each adjacent forward move, and Pending Editing → Pending Selection (`remove_selection`). Invalid, rejected with a snackbar and no request: skipping columns, dragging into Needs Assignment, Pending Review → Pending Editing. Moves are optimistic with rollback and error snackbar, reusing ticket 02. Needs Assignment → Scheduled drops use the assign flow from ticket 04; wire that path in whichever of 03/04 lands second.

**Blocked by:** 02

**Status:** resolved

- [ ] Valid drops fire the correct event and move the card
- [ ] Invalid drops show a snackbar and send no request
- [ ] Optimistic move with rollback on failure
- [ ] Needs Assignment → Scheduled drop triggers the assign flow (once ticket 04 exists)
- [ ] (source, target) → event mapping covered by tests

## Answer

Implemented on integration/appointment-workflow (tip d04444e).
