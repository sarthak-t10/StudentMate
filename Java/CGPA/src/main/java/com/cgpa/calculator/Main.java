package com.cgpa.calculator;

import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        CGPACalculator calculator = new CGPACalculator();

        System.out.println("=== CGPA Calculator ===");
        System.out.println("Enter the number of subjects: ");
        int numSubjects = scanner.nextInt();

        double[] grades = new double[numSubjects];
        int[] credits = new int[numSubjects];

        for (int i = 0; i < numSubjects; i++) {
            System.out.println("\nSubject " + (i + 1) + ":");
            System.out.print("Enter grade (0-10): ");
            grades[i] = scanner.nextDouble();

            System.out.print("Enter credits: ");
            credits[i] = scanner.nextInt();

            calculator.addSubject(grades[i], credits[i]);
        }

        double cgpa = calculator.calculateCGPA();
        System.out.println("\n=== Results ===");
        System.out.printf("Your CGPA: %.2f\n", cgpa);

        scanner.close();
    }
}
