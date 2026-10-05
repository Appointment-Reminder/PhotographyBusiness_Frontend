# Glossary

**Business**: A photography business; the top-level tenant that owns members, packages, forms and appointments.

**Business Member**: A User's membership in a Business, carrying a Business Role.

**Business Role**: A Member's permission level in a Business: owner, admin, photographer or assistant.

**Appointment**: A client's booked photo session with a Business, with date, location, duration, pricing and a status.

**Appointment Status**: Where an Appointment stands in its lifecycle: new, needs assignment, pending (assigned, awaiting the photoshoot), pending selection, pending editing, pending review, completed, canceled or refunded.

**Appointment Event**: A named step that moves an Appointment from one Appointment Status to the next (photoshoot, selection, editing, review, cancel, refund, and the "remove" steps that go back). A status is never set directly; only events change it, except that assigning a Business Member to an Appointment needing assignment moves it to pending by itself.

**Workflow Board**: A Kanban view of a Business's open Appointments, one column per Appointment Status from needs assignment to pending review, where moving a card between columns fires the matching Appointment Event (or, out of needs assignment, assigns a Business Member).

**Package**: A service offered by a Business, grouped in a Package Category.

**Package Category**: A grouping of Packages within a Business.

**Package Price**: A price for a Package that applies from an effective date; the current one is used at booking.

**Member Commission**: The amount or percentage a Business Member earns on a Package, effective from a date.

**Add-on**: An optional extra a Business sells on top of an Appointment's Package (e.g. extra hour, drone footage). It can carry a duration and a quantity, and is deactivated rather than deleted.

**Add-on Price**: A price for an Add-on that applies from an effective date; the current one is used when the Add-on is added to an Appointment.

**Add-on Commission**: The amount or percentage a Business Member earns on an Add-on, effective from a date; a Member with none earns a flat 0.

**Appointment Add-on**: An Add-on attached to an Appointment with a quantity, whose price, duration and commission are frozen at the moment it is added.

**Unresolved Add-on**: A label on an Appointment (from a Jotform submission) that matches no Add-on; it stays flagged until resolved by picking an Add-on.

**Catalog**: The Packages, Package Categories, Package Prices and Add-ons a Business offers, grouped as one area of the app.

**Team**: The Business Members of the Selected Business, as labelled in the app (not the login User), with the Member Commissions and Add-on Commissions each one earns.

**Dashboard**: The financial view of the Selected Business over a chosen timeframe: income, booked revenue and commission payable, compared with the previous period, plus the results of each Business Member. A Business Member without full access sees only their own results.

**Timeframe**: The inclusive range of days a Dashboard covers; it opens on the current month.

**My earnings**: The commission the logged-in Business Member earned over the Timeframe, shown to every Member who has a result row.

**Business earnings (Owner take)**: What the Business keeps after paying its Members over the Timeframe; visible to the owner only.

**Commission payable**: The total commission the Business owes all its Members over the Timeframe.

**Income source**: One of the three parts money is received as: Deposit, Shooting session (the balance paid on the Package) or Add-ons.

**Average appointment value**: Booked revenue divided by the Appointments made over the Timeframe.

**Effective rate**: A Member's commission earned divided by their income over the Timeframe; not the configured Member Commission.

**Analytics**: Interactive, live, non-financial metrics about a Business's activity, such as Appointments per Appointment Status or load per Business Member. Not built yet.

**Report**: A PDF built from a Business's activity over a period, such as commissions owed per Business Member. Not built yet.

**Selected Business**: The one Business the user is currently working in; every view in the app shows data for it.

**Jotform Credential**: A Business's stored access to its Jotform account.

**Jotform Form**: A Jotform form imported for a Business, whose questions map onto Appointment fields.

**Jotform Assignment**: Links a Jotform Form to a Business Member and Package Category so submissions create Appointments for that member.

**Backend API contract**: The OpenAPI snapshot in `docs/api/`; the only description of the backend this app relies on.
