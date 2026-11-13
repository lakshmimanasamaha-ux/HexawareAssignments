public class Task4_SlidingWindow {

    public static void main(String[] args) {
        final int HOURS = 24;
        final int MINUTES_PER_HOUR = 60;
        final int WINDOW_SIZE = 3 * MINUTES_PER_HOUR;

        int[] requests = new int[HOURS * MINUTES_PER_HOUR];

        // Sample requests per minute for all 1,440 minutes.
        // Replace this formula with actual request data when available.
        for (int minute = 0; minute < requests.length; minute++) {
            requests[minute] = 20 + (minute * 7 + minute / 13) % 80;
        }

        // Calculate the total for the first 3-hour window.
        int currentTotal = 0;
        for (int i = 0; i < WINDOW_SIZE; i++) {
            currentTotal += requests[i];
        }

        int maximumTotal = currentTotal;
        int bestStart = 0;

        // Slide the window by one minute at a time:
        // remove the outgoing value and add the incoming value.
        for (int i = WINDOW_SIZE; i < requests.length; i++) {
            currentTotal = currentTotal - requests[i - WINDOW_SIZE] + requests[i];

            if (currentTotal > maximumTotal) {
                maximumTotal = currentTotal;
                bestStart = i - WINDOW_SIZE + 1;
            }
        }

        int startHour = bestStart / MINUTES_PER_HOUR;
        int startMinute = bestStart % MINUTES_PER_HOUR;
        int endMinute = bestStart + WINDOW_SIZE;
        int endHour = endMinute / MINUTES_PER_HOUR;
        int endMinutePart = endMinute % MINUTES_PER_HOUR;

        System.out.println("SLIDING WINDOW - BUSIEST 3 HOURS");
        System.out.println("Total minutes of data: " + requests.length);
        System.out.println("Window size: " + WINDOW_SIZE + " minutes");
        System.out.printf("Busiest period: %02d:%02d to %02d:%02d%n",
                startHour, startMinute, endHour, endMinutePart);
        System.out.println("Total requests in this period: " + maximumTotal);
        System.out.printf("Average requests per minute: %.2f%n",
                (double) maximumTotal / WINDOW_SIZE);
    }
}
