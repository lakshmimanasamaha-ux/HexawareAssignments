# Hexaware Set 3 – Hospital Appointment Desk

Each task is provided as a separate Java file.

## Files
- `Task1_Search.java` – Linear Search and Binary Search on 20,000 patient IDs; performs 1,000 look-ups.
- `Task2_Sorting.java` – Selection Sort and Quick Sort. Appointments are sorted by urgency (highest first), then arrival time (earliest first).
- `Task3_DuplicateBooking.java` – HashSet-based duplicate patient/slot detection.
- `Task4_QueueStack.java` – Queue (FIFO) and Stack (LIFO) implemented using linked-list nodes.
- `Task5_AppointmentScheduling.java` – Dynamic Programming for maximum non-overlapping appointments.
- `sorting_trace.md` – typed Selection Sort trace.

## Requirements
Java JDK 8 or later. No external libraries are needed.

## Compile and run
Run each command from this folder:

```bash
javac Task1_Search.java
java Task1_Search

javac Task2_Sorting.java
java Task2_Sorting

javac Task3_DuplicateBooking.java
java Task3_DuplicateBooking

javac Task4_QueueStack.java
java Task4_QueueStack

javac Task5_AppointmentScheduling.java
java Task5_AppointmentScheduling
```

## Complexity summary
| Task | Algorithm | Time complexity |
|---|---|---|
| 1 | Linear Search | O(n) |
| 1 | Binary Search | O(log n) |
| 2 | Selection Sort | O(n²) |
| 2 | Quick Sort | Average O(n log n), worst O(n²) |
| 3 | HashSet duplicate detection | Average O(n) overall |
| 4 | Queue operations | O(1) per operation |
| 4 | Stack operations | O(1) per operation |
| 5 | Dynamic Programming | O(n²) |

## Notes
- Binary Search requires sorted patient IDs.
- Both sorting algorithms use the same urgency and arrival-time comparison rule.
- A duplicate means the same patient ID and same appointment slot.
- Task 5 maximizes the number of non-overlapping appointments, with every appointment having equal value.
- Runtime measurements vary by computer and JVM.
