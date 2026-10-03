# Appointment Workflow Board

Status: ready-for-agent

Design reference: `docs/figma/AppointmentStatus/` (app.tsx, index.css). Terms: see `GLOSSARY.md` (Appointment Status, Appointment Event, Workflow Board). API: `docs/api/appointments.md`, `docs/api/business-members.md`.

## Goal

A Kanban "Workflow" page where a Business sees its open Appointments by Appointment Status and advances them quickly, agile-style. Desktop and web first.

## Rules

- **Events only, except assignment.** Status changes by `POST /appointments/business/{business_id}/appointments/{appointment_id}/{event}`. The UI never PATCHes `status`. The one exception: assigning a member (`PATCH member_id`) moves `needs_assignment` to `pending` on the backend, so the UI sends no `assign` event. The backend is the source of truth for legality and permissions.
- **Placement.** New page "Workflow", reachable from the same navigation as the appointment list and calendar. Reuses the existing `appointment` feature data layer.

## Columns (left to right)

| Column | Status | Notes |
|---|---|---|
| Needs Assignment | `needs_assignment` (also `new`, defensive) | Hidden for photographer/assistant |
| Scheduled | `pending` | Not in the Figma; the designer must add it |
| Pending Selection | `pending_selection` | |
| Pending Editing | `pending_editing` | |
| Pending Review | `pending_review` | |

Header: label, description, count (as Figma). Stats strip, card layout, date format and "empty" placeholder follow Figma.

`completed` is hidden by default; a "Show closed" toggle reveals it. `canceled` and `refunded` are not columns.

## Backend transitions (contract)

| From | Event | To |
|---|---|---|
| new | create | needs_assignment |
| needs_assignment | assign (backend-internal; triggered by `PATCH member_id`, never sent by the UI) | pending |
| pending | photoshoot | pending_selection |
| pending_selection | selection | pending_editing |
| pending_editing | editing | pending_review |
| pending_review | review | completed |
| pending_editing | remove_selection | pending_selection |
| pending_review | remove_editing | pending_review (backend self-loop, a bug) |
| new, pending, pending_selection, pending_editing, pending_review, needs_assignment, completed | canceled | canceled |
| same set as canceled | refund | refunded |

`unassigned` has no transition. Cancel and refund are independent; neither is legal from `canceled` or `refunded`.

## Drag and drop

- A drop fires the one event for the (source column, target column) pair.
- Valid: each adjacent forward move in the table above, and Pending Editing → Pending Selection (`remove_selection`).
- Invalid, rejected with a snackbar and no request: skipping columns, dragging into Needs Assignment, Pending Review → Pending Editing (no working backend event).
- Needs Assignment → Scheduled opens the member picker, then `PATCH member_id` only. The backend moves the status to `pending` as part of that PATCH; no `assign` event is sent. The card takes the status from the PATCH response (no optimistic move). If the response still says `needs_assignment`, the card stays there with no fallback event.
- Moves are optimistic; roll back with an error snackbar on failure.
- While dragging, "Cancel" and "Refund" drop zones appear, each with a confirmation dialog, and are unavailable for `canceled` and `refunded` cards.

## Advance button (every card)

One button per card fires the next forward event and moves the card one column right:

| Card in | Button | Event |
|---|---|---|
| Needs Assignment | Assign… (opens picker) | `PATCH member_id` only (backend sets `pending`) |
| Scheduled | Mark shot | `photoshoot` |
| Pending Selection | Mark selected | `selection` |
| Pending Editing | Mark edited | `editing` |
| Pending Review | Mark reviewed | `review` (card leaves the default board) |

Replaces Figma's hover-only "mark done" (which deleted the card on every status).

Reassigning an already-assigned card ("Assign to…") is the same single PATCH of `member_id`; no event.

## Roles

- Owner, admin: see all Appointments, can assign, see photographer filter chips and the legend.
- Photographer, assistant: see only their own (`member_id`), cannot assign (no Assign button, no Needs Assignment column), cannot see filter chips or legend; can advance selection, editing and review.
- The backend decides on permission errors; the UI hides what the role cannot do.

## Card data

- Client name; date.
- Package badge: real package name from the Business's packages, truncated; "—" when `package_id` is null.
- Photographer avatar and colour bar: initials and colour derived in the frontend, stable colour from a fixed palette by member id; grey for unassigned.

## Out of scope

- Backend fixes (`remove_editing` self-loop, `unassigned` transition). Tracked nowhere by decision.
- Mobile-specific drag behaviour.
- Writing an ADR (decided: not warranted).

## Open for implementer

- Exact status-string to column mapping lives in one place in the domain layer.
- Confirm the `GET /appointments/business/{business_id}` `status` filter and `member_id` scoping suffice for the photographer view; otherwise filter client-side.
