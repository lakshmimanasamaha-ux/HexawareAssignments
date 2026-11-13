import java.util.LinkedList;
import java.util.Queue;
import java.util.Stack;

public class Task4_QueueStack {

    public static void main(String[] args) {

        // Queue follows FIFO: First In, First Out.
        Queue<String> walkInPatients = new LinkedList<>();

        walkInPatients.add("Patient A");
        walkInPatients.add("Patient B");
        walkInPatients.add("Patient C");

        System.out.println("Next walk-in patient: " + walkInPatients.poll());
        System.out.println("Waiting patients: " + walkInPatients);

        // Stack follows LIFO: Last In, First Out.
        Stack<String> recentPatients = new Stack<>();

        recentPatients.push("Patient A");
        recentPatients.push("Patient B");
        recentPatients.push("Patient C");

        System.out.println("Most recently viewed patient: " + recentPatients.peek());
        System.out.println("Removed recent patient: " + recentPatients.pop());
        System.out.println("Remaining history: " + recentPatients);
    }
}
