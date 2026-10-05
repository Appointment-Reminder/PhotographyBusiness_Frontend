# Dashboard: information to design

This brief is for the designer. Amounts are in the app's usual money format, and the API returns no currency. The page covers one Business and one Timeframe (a date range, opening on the current month).

## 1. The two answers at the top

| Figure | Meaning | Who sees it |
|---|---|---|
| **My earnings** | What I personally earned in commission over the Timeframe. | Everyone, including photographers |
| **Business earnings (Owner take)** | What the Business keeps after paying its Members. | Owner only |

Next to these, show **Commission payable**: the total the Business owes all its Members. Each figure shows its change versus the previous period (for example "vs 1 Sep – 30 Sep"). A dash replaces the change when the previous period was zero.

## 2. Where the money comes from: Deposit, Shooting session, Add-ons

Show **Total income** as one headline number. Directly under it, show a breakdown that adds up to the total:

| Slice | Meaning |
|---|---|
| **Deposit** | Deposits received. |
| **Shooting session** | The balance paid on the Package (the session itself). |
| **Add-ons** | Money received for Add-ons. |

The designer should show these as three labelled amounts, ideally with a proportional bar or share, so the split is readable at a glance.

## 3. Split of my earnings and the Business's earnings

The same Deposit / Shooting session / Add-ons split should be shown for both "My earnings" and "Business earnings". The designer should reserve space for it.

## 4. Supporting content

- **Booked revenue**: the value of what was sold, not only what was paid.
- **Appointments made**: a count, with its change versus the previous period.
- **Income over time**: a stacked bar chart of Deposit and Balance per day, week or month. The grouping is automatic. An empty period shows "No activity in this period" and zeros.
- **Members table**: name, income, appointments and commission earned for each Member. Photographers don't see it, because it would only list themselves.
- **Alert chips**: "N Unresolved Add-ons" (tappable, goes to Appointments) and "N commissions above balance" (information only). Both are hidden at zero.
- **States**: first load, error with a Retry button, and a refetch that keeps the old numbers visible.
- **Timeframe picker**: This month, Last month, Last 30 days, This year, or a custom range. It shows the resolved range (for example "1 Oct – 31 Oct 2026") and allows future dates.
- **Photographer view**: the page shows their own Income, Booked revenue, Appointments and Commission earned. There are no Business-wide figures and no change badges.

## 5. What the API provides today (for the dev side)

| Need | Available? |
|---|---|
| Total income, deposit income, balance income, add-on income, package balance | Yes. I assume `balance_income` = `package_balance` + `addon_income`, which needs checking. |
| Business earnings (`owner_take`), owner only | Yes, and the previous period's value too. |
| My total commission (`commission_earned` on my Member row) | Yes, as one total only. |
| **My commission split by Deposit / Shooting session / Add-ons** | **No.** Only the total is returned. |
| **Business earnings split by Deposit / Shooting session / Add-ons** | **No.** Only the total is returned. |
| Chart split by Add-ons | No. The series only has deposit and balance. |

Two things need a decision before the designer finalises sections 1 and 3:

1. **Backend change:** the API would need to return commission and owner take split by Deposit, Shooting session and Add-ons. Without that, section 3 can't be built.
2. **Scope change:** `addon_income`, `package_balance` and `owner_take` are listed as out of scope in `.scratch/dashboard/spec.md`. This brief brings them in, so the spec needs updating.
