public class Task5_TwoPointers {

    public static void main(String[] args) {
        // The values must be sorted for the two-pointer method.
        int[] orderValues = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100};
        int giftCardValue = 100;

        int left = 0;
        int right = orderValues.length - 1;
        boolean pairFound = false;

        System.out.println("TWO POINTERS - GIFT CARD PAIRS");
        System.out.println("Target value: " + giftCardValue);

        while (left < right) {
            int sum = orderValues[left] + orderValues[right];

            if (sum == giftCardValue) {
                System.out.println(orderValues[left] + " + "
                        + orderValues[right] + " = " + giftCardValue);
                pairFound = true;

                // Move both pointers and skip duplicate values.
                int leftValue = orderValues[left];
                int rightValue = orderValues[right];

                while (left < right && orderValues[left] == leftValue) {
                    left++;
                }
                while (left < right && orderValues[right] == rightValue) {
                    right--;
                }
            } else if (sum < giftCardValue) {
                left++;  // Need a bigger sum.
            } else {
                right--; // Need a smaller sum.
            }
        }

        if (!pairFound) {
            System.out.println("No matching pair found.");
        }
    }
}
