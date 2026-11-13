# Selection Sort Trace – Hospital Appointment Desk

## Sorting rule
1. Higher urgency first: 4, 3, 2, 1.
2. For equal urgency, earlier arrival time first.

## Input
| Appointment | Urgency | Arrival |
|---|---:|---|
| 1 | 2 | 10:00 |
| 2 | 4 | 09:30 |
| 3 | 3 | 09:45 |
| 4 | 2 | 09:15 |
| 5 | 4 | 10:15 |
| 6 | 1 | 09:05 |

## Pass-by-pass trace
| Pass | Selected appointment | Reason |
|---:|---|---|
| 1 | 2 | Urgency 4 and earlier than appointment 5 |
| 2 | 5 | Remaining highest urgency is 4 |
| 3 | 3 | Next urgency is 3 |
| 4 | 4 | Urgency 2; earlier than appointment 1 |
| 5 | 1 | Remaining urgency 2 |
| 6 | 6 | Urgency 1 |

## Array after each pass (appointment IDs)
- Initial: `[1, 2, 3, 4, 5, 6]`
- Pass 1: `[2, 1, 3, 4, 5, 6]`
- Pass 2: `[2, 5, 3, 4, 1, 6]`
- Pass 3: `[2, 5, 3, 4, 1, 6]`
- Pass 4: `[2, 5, 3, 4, 1, 6]`
- Pass 5: `[2, 5, 3, 4, 1, 6]`
- Pass 6: `[2, 5, 3, 4, 1, 6]`

## Final order
`2 -> 5 -> 3 -> 4 -> 1 -> 6`

There are 2 actual swaps in this sample. Selection Sort has O(n²) time complexity.
