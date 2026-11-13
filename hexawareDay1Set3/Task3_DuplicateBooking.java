import java.util.HashSet;

public class Task3_DuplicateBooking {

    public static void main(String[] args) {
        HashSet<String> bookings = new HashSet<>();

        addBooking(bookings, "P101", "2026-11-12", "09:00");
        addBooking(bookings, "P102", "2026-11-12", "09:00");
        addBooking(bookings, "P101", "2026-11-12", "09:00");
        addBooking(bookings, "P101", "2026-11-12", "10:00");

        System.out.println("Total accepted bookings: " + bookings.size());
    }

    static void addBooking(HashSet<String> bookings,
                           String patientId, String date, String time) {

        String booking = patientId + "-" + date + "-" + time;

        if (bookings.add(booking)) {
            System.out.println("Booking accepted: " + booking);
        } else {
            System.out.println("Duplicate booking rejected: " + booking);
        }
    }
}
