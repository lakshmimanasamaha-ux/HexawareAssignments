import java.util.HashMap;

public class Task2_HashTableAndHashMap {

    // A simple hash table that uses linked-list chaining.
    static class HashTable {
        static class Entry {
            String key;
            String value;
            Entry next;

            Entry(String key, String value) {
                this.key = key;
                this.value = value;
            }
        }

        Entry[] table;

        HashTable(int size) {
            table = new Entry[size];
        }

        int getIndex(String key) {
            return Math.floorMod(key.hashCode(), table.length);
        }

        // Insert a key-value pair. New entries are added at the beginning.
        void put(String key, String value) {
            int index = getIndex(key);
            Entry current = table[index];

            while (current != null) {
                if (current.key.equals(key)) {
                    current.value = value;
                    return;
                }
                current = current.next;
            }

            Entry newEntry = new Entry(key, value);
            newEntry.next = table[index];
            table[index] = newEntry;
        }

        // Search for a key in its bucket.
        String get(String key) {
            int index = getIndex(key);
            Entry current = table[index];

            while (current != null) {
                if (current.key.equals(key)) {
                    return current.value;
                }
                current = current.next;
            }
            return null;
        }
    }

    public static void main(String[] args) {
        System.out.println("HASH TABLE WITH CHAINING");

        // A small table makes it easy to demonstrate a collision.
        HashTable smallTable = new HashTable(5);
        String firstKey = "SKU-101";
        String secondKey = "SKU-106";

        System.out.println(firstKey + " index: " + smallTable.getIndex(firstKey));
        System.out.println(secondKey + " index: " + smallTable.getIndex(secondKey));

        smallTable.put(firstKey, "Wireless Mouse");
        smallTable.put(secondKey, "Keyboard");

        System.out.println("Both keys are stored in the same bucket (collision).");
        System.out.println("Value for " + firstKey + ": " + smallTable.get(firstKey));
        System.out.println("Value for " + secondKey + ": " + smallTable.get(secondKey));

        // Compare lookup time for 100,000 SKU records.
        final int COUNT = 100_000;
        HashTable customTable = new HashTable(200_003);
        HashMap<String, String> builtInMap = new HashMap<>();

        for (int i = 0; i < COUNT; i++) {
            String sku = "SKU-" + i;
            String product = "Product-" + i;
            customTable.put(sku, product);
            builtInMap.put(sku, product);
        }

        // Prepare the same search keys for both data structures.
        String[] searchKeys = new String[COUNT];
        for (int i = 0; i < COUNT; i++) {
            searchKeys[i] = "SKU-" + i;
        }

        // Small warm-up before measuring.
        for (int i = 0; i < 10_000; i++) {
            customTable.get(searchKeys[i]);
            builtInMap.get(searchKeys[i]);
        }

        long start = System.nanoTime();
        int customFound = 0;
        for (String key : searchKeys) {
            if (customTable.get(key) != null) {
                customFound++;
            }
        }
        long customTime = System.nanoTime() - start;

        start = System.nanoTime();
        int mapFound = 0;
        for (String key : searchKeys) {
            if (builtInMap.get(key) != null) {
                mapFound++;
            }
        }
        long mapTime = System.nanoTime() - start;

        System.out.println("\nLOOKUP COMPARISON FOR " + COUNT + " SKUs");
        System.out.println("Custom hash table: " + customFound
                + " records found, time = " + customTime + " ns");
        System.out.println("Java HashMap:      " + mapFound
                + " records found, time = " + mapTime + " ns");
        System.out.println("Note: timings vary by computer and program run.");
    }
}
