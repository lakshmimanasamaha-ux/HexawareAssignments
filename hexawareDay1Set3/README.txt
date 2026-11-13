HEX AWARE - SET 3: HOSPITAL APPOINTMENT DESK

Files:
1. Task1_Search.java - Linear Search and Binary Search
2. Task2_Sorting.java - Selection Sort and Quick Sort
3. Task3_DuplicateBooking.java - HashSet duplicate booking check
4. Task4_QueueStack.java - Queue for walk-ins and Stack for recent patients
5. Task5_AppointmentScheduling.java - Dynamic Programming appointment scheduling

How to compile and run:
Open a terminal inside this folder.

For each task, run:
javac Task1_Search.java
java Task1_Search

Replace Task1_Search with the required file name for other tasks.

Java collections used:
- ArrayList: stores patient and appointment records
- HashSet: detects duplicate bookings
- Queue with LinkedList: handles walk-in patients in FIFO order
- Stack: stores recently viewed patients in LIFO order

Notes:
- Binary Search requires the patient IDs to be sorted.
- Task 2 sorts by urgency (highest first), then arrival time (earliest first).
- Task 5 uses Dynamic Programming to find the maximum number of non-overlapping appointments.
