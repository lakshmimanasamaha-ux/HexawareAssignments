import java.util.*;

public class Task3_MicroserviceGraph {

    static class Graph {
        Map<String, List<String>> graph = new LinkedHashMap<>();

        void addService(String service) {
            graph.putIfAbsent(service, new ArrayList<>());
        }

        // Add an edge from prerequisite to the service that needs it.
        void addDependency(String prerequisite, String service) {
            addService(prerequisite);
            addService(service);
            graph.get(prerequisite).add(service);
        }

        // Breadth-first search: visits nearby services first.
        void bfs(String start) {
            Set<String> visited = new HashSet<>();
            Queue<String> queue = new LinkedList<>();

            visited.add(start);
            queue.add(start);

            System.out.print("BFS traversal: ");
            while (!queue.isEmpty()) {
                String current = queue.remove();
                System.out.print(current + " ");

                for (String next : graph.get(current)) {
                    if (!visited.contains(next)) {
                        visited.add(next);
                        queue.add(next);
                    }
                }
            }
            System.out.println();
        }

        // Depth-first search: explores one path before returning.
        void dfsHelper(String current, Set<String> visited) {
            visited.add(current);
            System.out.print(current + " ");

            for (String next : graph.get(current)) {
                if (!visited.contains(next)) {
                    dfsHelper(next, visited);
                }
            }
        }

        void dfs(String start) {
            System.out.print("DFS traversal: ");
            dfsHelper(start, new HashSet<>());
            System.out.println();
        }

        // Kahn's algorithm: returns a valid deployment order using BFS.
        List<String> topologicalSortBFS() {
            Map<String, Integer> indegree = new HashMap<>();

            for (String service : graph.keySet()) {
                indegree.put(service, 0);
            }

            for (String service : graph.keySet()) {
                for (String next : graph.get(service)) {
                    indegree.put(next, indegree.get(next) + 1);
                }
            }

            Queue<String> queue = new LinkedList<>();
            for (String service : graph.keySet()) {
                if (indegree.get(service) == 0) {
                    queue.add(service);
                }
            }

            List<String> order = new ArrayList<>();

            while (!queue.isEmpty()) {
                String current = queue.remove();
                order.add(current);

                for (String next : graph.get(current)) {
                    indegree.put(next, indegree.get(next) - 1);
                    if (indegree.get(next) == 0) {
                        queue.add(next);
                    }
                }
            }

            if (order.size() != graph.size()) {
                return new ArrayList<>(); // Empty means a cycle exists.
            }
            return order;
        }

        // DFS-based cycle detection.
        boolean hasCycle() {
            Map<String, Integer> state = new HashMap<>();
            // 0 = not visited, 1 = currently exploring, 2 = completed

            for (String service : graph.keySet()) {
                state.put(service, 0);
            }

            for (String service : graph.keySet()) {
                if (state.get(service) == 0 && cycleHelper(service, state)) {
                    return true;
                }
            }
            return false;
        }

        boolean cycleHelper(String current, Map<String, Integer> state) {
            state.put(current, 1);

            for (String next : graph.get(current)) {
                if (state.get(next) == 1) {
                    return true;
                }
                if (state.get(next) == 0 && cycleHelper(next, state)) {
                    return true;
                }
            }

            state.put(current, 2);
            return false;
        }
    }

    public static void main(String[] args) {
        Graph services = new Graph();

        // Meaning: Inventory must be deployed before Pricing;
        // Pricing must be deployed before Cart.
        services.addDependency("Inventory", "Pricing");
        services.addDependency("Pricing", "Cart");
        services.addDependency("Inventory", "Payment");
        services.addDependency("Payment", "Order");

        System.out.println("MICROSERVICE DEPENDENCY GRAPH");
        System.out.println("Dependency chain: Cart -> Pricing -> Inventory");
        services.bfs("Inventory");
        services.dfs("Inventory");

        List<String> order = services.topologicalSortBFS();
        if (order.isEmpty()) {
            System.out.println("Cannot deploy: circular dependency found.");
        } else {
            System.out.println("Valid deployment order (BFS): " + order);
            System.out.println("Circular dependency? " + services.hasCycle());
        }

        // Add a dependency that creates a cycle:
        // Cart -> Inventory, while Inventory -> Pricing -> Cart already exists.
        services.addDependency("Cart", "Inventory");

        System.out.println("\nAfter adding Cart -> Inventory:");
        System.out.println("Circular dependency? " + services.hasCycle());

        if (services.topologicalSortBFS().isEmpty()) {
            System.out.println("Deployment order cannot be created because a cycle exists.");
        }
    }
}
