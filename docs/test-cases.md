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

