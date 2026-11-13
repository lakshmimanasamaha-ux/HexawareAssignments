import java.util.ArrayList;
import java.util.Comparator;

public class Task5_AppointmentScheduling {

    static class Appointment {
        String name;
        int start;
        int end;

        Appointment(String name, int start, int end) {
            this.name = name;
            this.start = start;
            this.end = end;
        }

        public String toString() {
            return name + " (" + start + " - " + end + ")";
        }
    }

    public static void main(String[] args) {
        ArrayList<Appointment> appointments = new ArrayList<>();

        appointments.add(new Appointment("A", 1, 3));
        appointments.add(new Appointment("B", 2, 5));
        appointments.add(new Appointment("C", 4, 6));
        appointments.add(new Appointment("D", 6, 8));
        appointments.add(new Appointment("E", 5, 7));
        appointments.add(new Appointment("F", 8, 9));

        // Sort appointments by ending time.
        appointments.sort(Comparator.comparingInt(a -> a.end));

        int n = appointments.size();
        int[] dp = new int[n];

        for (int i = 0; i < n; i++) {
            int include = 1;

            // Find the last appointment that does not overlap.
            for (int j = i - 1; j >= 0; j--) {
                if (appointments.get(j).end <= appointments.get(i).start) {
                    include = 1 + dp[j];
                    break;
                }
            }

            int exclude = (i == 0) ? 0 : dp[i - 1];
            dp[i] = Math.max(include, exclude);
        }

        System.out.println("Maximum non-overlapping appointments: " + dp[n - 1]);
    }
}
