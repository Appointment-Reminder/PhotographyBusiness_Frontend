# 05: Cancel and Refund drop zones

**What to build:** While a card is being dragged, "Cancel" and "Refund" drop zones appear. Dropping a card on one opens a confirmation dialog; on confirm the `canceled` or `refund` event fires and the card leaves the board. The zones are unavailable for cards already `canceled` or `refunded`. Cancel and refund are independent events.

**Blocked by:** 03

**Status:** resolved

- [ ] Drop zones appear only during a drag
- [ ] Each zone asks for confirmation before firing its event
- [ ] Zones unavailable for canceled and refunded cards
- [ ] Failure rolls back with an error snackbar
- [ ] Eligibility rules covered by tests

## Answer

Implemented on integration/appointment-workflow (tip d04444e).
