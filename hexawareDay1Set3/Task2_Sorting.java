import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

public class Task2_Sorting {

    static class Appointment {
        int id;
        int urgency;
        int arrivalTime;

        Appointment(int id, int urgency, int arrivalTime) {
            this.id = id;
            this.urgency = urgency;
            this.arrivalTime = arrivalTime;
        }

        public String toString() {
            return "Appointment " + id + " (Urgency=" + urgency
                    + ", Arrival=" + arrivalTime + ")";
        }
    }

    // Higher urgency first. If equal, earlier arrival first.
    static Comparator<Appointment> order = (a, b) -> {
        if (a.urgency != b.urgency) {
            return b.urgency - a.urgency;
        }
        return a.arrivalTime - b.arrivalTime;
    };

    static void selectionSort(ArrayList<Appointment> list) {
        for (int i = 0; i < list.size() - 1; i++) {
            int best = i;

            for (int j = i + 1; j < list.size(); j++) {
                if (order.compare(list.get(j), list.get(best)) < 0) {
                    best = j;
                }
            }

            Collections.swap(list, i, best);
        }
    }

    static void quickSort(ArrayList<Appointment> list, int low, int high) {
        if (low < high) {
            int pivot = partition(list, low, high);
            quickSort(list, low, pivot - 1);
            quickSort(list, pivot + 1, high);
        }
    }

    static int partition(ArrayList<Appointment> list, int low, int high) {
        Appointment pivot = list.get(high);
        int i = low - 1;

        for (int j = low; j < high; j++) {
            if (order.compare(list.get(j), pivot) <= 0) {
                i++;
                Collections.swap(list, i, j);
            }
        }

        Collections.swap(list, i + 1, high);
        return i + 1;
    }

    public static void main(String[] args) {
        ArrayList<Appointment> original = new ArrayList<>();

        original.add(new Appointment(1, 2, 930));
        original.add(new Appointment(2, 5, 900));
        original.add(new Appointment(3, 3, 845));
        original.add(new Appointment(4, 5, 830));
        original.add(new Appointment(5, 1, 1000));

        ArrayList<Appointment> selectionList = new ArrayList<>(original);
        ArrayList<Appointment> quickList = new ArrayList<>(original);

        selectionSort(selectionList);
        quickSort(quickList, 0, quickList.size() - 1);

        System.out.println("Selection Sort:");
        for (Appointment a : selectionList) {
            System.out.println(a);
        }

        System.out.println("\\nQuick Sort:");
        for (Appointment a : quickList) {
            System.out.println(a);
        }
    }
}
