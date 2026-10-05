# Backend requests: Dashboard

The Dashboard design (`docs/figma/Dashboard`) needs data the overview endpoint (`GET /business/{business_id}/overview`) does not return. Until each item ships, the app shows `0` or a dash and keeps the display logic ready.

## 1. Commission split by Income source

- **Problem:** `commission_earned` (Member row) and `owner_take` (`business`) are single totals. The "My earnings" and "Business earnings" cards show a Deposit / Shooting session / Add-ons bar and cannot fill it.
- **Proposal:** the same split as the income figures, for both: `commission_earned_deposit`, `commission_earned_session`, `commission_earned_addons` on each Member row; `owner_take_deposit`, `owner_take_session`, `owner_take_addons` on `business`. The three parts add up to the total.
- **Used by:** the split bar and three labelled amounts on "My earnings" and "Business earnings". Both show 0 in every slice until this ships.

## 2. Previous-period Average appointment value

- **Problem:** `comparison.previous` has no `average_appointment_value`, so the "from last period" change cannot be computed.
- **Proposal:** add `average_appointment_value` to `HeadlineRead` and `HeadlineChangeRead` (previous value and change percent).
- **Used by:** the Average appointment value tile. It shows a neutral "$0 from last period" placeholder until this ships.

## 3. Commission rate per Member

- **Problem:** the design has a Rate column per Member. The app only derives an Effective rate (`commission_earned / income`), which differs from a configured Member Commission when rates vary by Package or Add-on.
- **Proposal:** add a rate on each Member row, with the rule for Members who have several commission rates (for example a weighted average), or confirm that the Effective rate is the intended meaning.
- **Used by:** the Rate column of the members table (labelled "Effective rate" until then).

## 4. Logged-in User to Business Member

- **Problem:** "My earnings" must pick the logged-in User's row in `members`. The app has no confirmed link from `GET /users/me` to a Business Member id for the Selected Business.
- **Proposal:** return the caller's Business Member id (or a `is_me` flag on the Member row) in the overview, or expose it on the Business membership.
- **Used by:** choosing the "My earnings" figure. The card is hidden when no row matches.

## 5. Income split consistency

- **Question:** is `balance_income = package_balance + addon_income`, and `total_income = deposit_income + balance_income`?
- **Why:** the Total income breakdown computes each share from the three slice fields (`deposit_income`, `package_balance`, `addon_income`); a mismatch would make the shares disagree with the headline.
