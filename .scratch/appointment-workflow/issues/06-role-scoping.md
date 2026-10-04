# 06: Role scoping

**What to build:** Owner and admin see all Appointments, can assign, and see the photographer filter chips and legend. Photographer and assistant see only their own Appointments (`member_id`), have no Needs Assignment column, no Assign button, no filter chips or legend, and can still advance selection, editing and review. The backend decides on permission errors; the UI hides what the role cannot do. Use the API filters if ticket 01 found them sufficient, otherwise filter client-side.

**Blocked by:** 01

**Status:** resolved

- [ ] Owner/admin see all Appointments, chips and legend
- [ ] Photographer/assistant see only their own Appointments
- [ ] Needs Assignment column, Assign actions, chips and legend hidden for photographer/assistant
- [ ] Advance buttons for selection, editing and review remain available to them
- [ ] Role-based visibility and scoping covered by tests

## Answer

Implemented on integration/appointment-workflow (tip d04444e).
