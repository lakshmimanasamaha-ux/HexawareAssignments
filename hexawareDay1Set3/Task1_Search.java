import java.util.ArrayList;
import java.util.Random;

public class Task1_Search {

    static int linearSearch(ArrayList<Integer> patients, int target) {
        for (int i = 0; i < patients.size(); i++) {
            if (patients.get(i) == target) {
                return i;
            }
        }
        return -1;
    }
    
    static int binarySearch(ArrayList<Integer> patients, int target) {
        int low = 0;
        int high = patients.size() - 1;

        while (low <= high) {
            int mid = (low + high) / 2;

            if (patients.get(mid) == target) {
                return mid;
            } else if (patients.get(mid) < target) {
                low = mid + 1;
            } else {
                high = mid - 1;
            }
        }
        return -1;
    }

    public static void main(String[] args) {
        ArrayList<Integer> patients = new ArrayList<>();

        for (int i = 1; i <= 20000; i++) {
            patients.add(10000 + i);
        }

        Random random = new Random(10);
        ArrayList<Integer> searchIds = new ArrayList<>();

        for (int i = 0; i < 1000; i++) {
            searchIds.add(10000 + random.nextInt(20000) + 1);
        }

        long start = System.nanoTime();
        for (int id : searchIds) {
            linearSearch(patients, id);
        }
        long linearTime = System.nanoTime() - start;

        start = System.nanoTime();
        for (int id : searchIds) {
            binarySearch(patients, id);
        }
        long binaryTime = System.nanoTime() - start;

        System.out.println("Patients: " + patients.size());
        System.out.println("Searches: " + searchIds.size());
        System.out.println("Linear Search time: " + linearTime / 1_000_000.0 + " ms");
        System.out.println("Binary Search time: " + binaryTime / 1_000_000.0 + " ms");
    }
}
