public class AddDemo {
    public static void main(String[] args) {
        int a = 5;
        int b = 10;
        int sum = add(a, b);
        System.out.println("The sum of " + a + " and " + b + " is: " + sum);
    }

    public static int add(int num1, int num2) {
        return num1 + num2;
    }
    
}
