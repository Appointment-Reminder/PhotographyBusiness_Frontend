# 08: Adopt the simplified overview contract

**What to build:** Move the Dashboard to the simplified `GET /business/{business_id}/overview` response (`docs/api/business-overview.md`): renamed fields, real commission and owner splits, the backend commission rate, `my_member_id`, the previous average appointment value, the unassigned Member row and a new Appointments booked card.

**Blocked by:** none

**Status:** done

- [x] The mapper reads the new field names (`photographer_share_*`, `owner_share_*`, `shooting_income`, `addons_income`, `total_income`) and `my_member_id`
- [x] My earnings and Business earnings bars are filled from the backend splits; any split that does not add up to its card total is flagged on that card
- [x] Appointments booked card with percent change, after Appointments made; photographer fallback from the own row; counts as activity
- [x] Average appointment value shows the amount gained or lost versus the previous period, none without a comparison
- [x] Members table uses `photographer_share_rate` ("Commission rate", dash when null); the null-member row is "Unassigned", last, and does not count toward showing the table
- [x] `myMemberIdProvider` removed; "me" comes from the overview
- [x] `docs/backend-requests/dashboard.md` removed (all requests delivered)
- [x] Notifier-level tests updated and extended
