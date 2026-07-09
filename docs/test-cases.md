# Test Cases

| ID | Path | Expected result |
|---|---|---|
| T01 | First launch | Empty state is readable; no permission or network prompt appears |
| T02 | Add valid item | Item persists and appears in correct urgency section |
| T03 | Save without name | Save remains disabled |
| T04 | Edit date/location | Home regrouping updates immediately |
| T05 | Mark eaten | Item leaves Home and appears in History as eaten |
| T06 | Mark discarded | Confirmation appears; confirmed item moves to History |
| T07 | Delete item | Confirmation appears; item is removed permanently |
| T08 | OCR detects date | Suggested date is shown for user confirmation |
| T09 | OCR finds no date | Non-blocking error appears; manual date remains available |
| T10 | Enable reminder/allow | Daily notification is scheduled at selected time |
| T11 | Enable reminder/deny | Explanation appears and setting remains disabled |
| T12 | Change language | Entire visible UI updates and choice persists |
| T13 | System unsupported locale | English is used |
| T14 | Privacy/support rows | Correct pages open; raw address/email is not displayed |
| T15 | Device dark mode | App remains light and all text remains readable |
| T16 | Relaunch | Active items, history, settings, and language persist |
| T17 | Widget | Three nearest items match saved active data |
| T18 | Free user adds item 1–10 | Items save normally |
| T19 | Free user taps Add at 10 active items | Pro page opens; existing data remains usable |
| T20 | Free user taps date scan/reminder | Pro page opens without requesting unrelated permissions |
| T21 | Buy lifetime Pro | Apple sheet completes; verified entitlement unlocks all Pro features |
| T22 | Cancel purchase | Pro remains locked; no error is falsely shown |
| T23 | Pending purchase | Pending explanation appears; app remains usable |
| T24 | Restore existing purchase | Pro unlocks and success feedback appears |
| T25 | Restore with no purchase | “Nothing to restore” feedback appears |
| T26 | Refund/revoke transaction | Pro locks again; existing foods remain visible/editable |
| T27 | Product price | UI uses StoreKit localized `displayPrice`, not a hard-coded price |
