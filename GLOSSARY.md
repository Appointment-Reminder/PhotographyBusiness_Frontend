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

**Catalog**: The Packages, Package Categories, and Package Prices a Business offers, grouped as one area of the app.

**Team**: The Business Members of the Selected Business, as labelled in the app (not the login User).

**Analytics**: Interactive, live metrics about a Business's activity, such as Appointments per Appointment Status or load per Business Member. Not built yet.

**Report**: A period-based, exportable summary of a Business's activity, such as commissions owed per Business Member. Not built yet.

**Selected Business**: The one Business the user is currently working in; every view in the app shows data for it.

**Jotform Credential**: A Business's stored access to its Jotform account.

**Jotform Form**: A Jotform form imported for a Business, whose questions map onto Appointment fields.

**Jotform Assignment**: Links a Jotform Form to a Business Member and Package Category so submissions create Appointments for that member.

**Backend API contract**: The OpenAPI snapshot in `docs/api/`; the only description of the backend this app relies on.
