public class Task1_BinarySearchTree {

    // Each node stores one product category.
    static class Node {
        String data;
        Node left, right;

        Node(String data) {
            this.data = data;
        }
    }

    static Node root;

    // Insert a category in its correct position.
    static Node insert(Node current, String value) {
        if (current == null) {
            return new Node(value);
        }

        if (value.compareToIgnoreCase(current.data) < 0) {
            current.left = insert(current.left, value);
        } else if (value.compareToIgnoreCase(current.data) > 0) {
            current.right = insert(current.right, value);
        }
        return current;
    }

    // Search for a category.
    static boolean search(Node current, String value) {
        if (current == null) {
            return false;
        }

        int result = value.compareToIgnoreCase(current.data);

        if (result == 0) {
            return true;
        } else if (result < 0) {
            return search(current.left, value);
        } else {
            return search(current.right, value);
        }
    }

    // Left, Root, Right: gives categories in sorted order.
    static void inorder(Node current) {
        if (current != null) {
            inorder(current.left);
            System.out.print(current.data + " ");
            inorder(current.right);
        }
    }

    // Root, Left, Right.
    static void preorder(Node current) {
        if (current != null) {
            System.out.print(current.data + " ");
            preorder(current.left);
            preorder(current.right);
        }
    }

    // Left, Right, Root.
    static void postorder(Node current) {
        if (current != null) {
            postorder(current.left);
            postorder(current.right);
            System.out.print(current.data + " ");
        }
    }

    public static void main(String[] args) {
        String[] categories = {
            "Electronics", "Clothing", "Books", "Furniture", "Beauty",
            "Sports", "Toys", "Groceries", "Footwear", "Jewellery",
            "Kitchen", "Mobiles", "Laptops", "Stationery", "Watches"
        };

        for (String category : categories) {
            root = insert(root, category);
        }

        System.out.println("BINARY SEARCH TREE - PRODUCT CATEGORIES");
        System.out.println("Number of categories inserted: " + categories.length);

        System.out.print("\nInorder traversal: ");
        inorder(root);

        System.out.print("\nPreorder traversal: ");
        preorder(root);

        System.out.print("\nPostorder traversal: ");
        postorder(root);

        System.out.println("\n\nSearch for 'Mobiles': " + search(root, "Mobiles"));
        System.out.println("Search for 'Medicines': " + search(root, "Medicines"));
    }
}
