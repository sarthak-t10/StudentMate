package com.cgpa.calculator;

import java.util.ArrayList;
import java.util.List;

public class CGPACalculator {
    private List<Subject> subjects;

    public CGPACalculator() {
        this.subjects = new ArrayList<>();
    }

    public void addSubject(double grade, int credits) {
        if (grade < 0 || grade > 10) {
            throw new IllegalArgumentException("Grade must be between 0 and 10");
        }
        if (credits <= 0) {
            throw new IllegalArgumentException("Credits must be positive");
        }
        subjects.add(new Subject(grade, credits));
    }

    public double calculateCGPA() {
        if (subjects.isEmpty()) {
            return 0;
        }

        double totalGradePoints = 0;
        int totalCredits = 0;

        for (Subject subject : subjects) {
            totalGradePoints += subject.getGrade() * subject.getCredits();
            totalCredits += subject.getCredits();
        }

        return totalCredits > 0 ? totalGradePoints / totalCredits : 0;
    }

    public int getSubjectCount() {
        return subjects.size();
    }

    private static class Subject {
        private final double grade;
        private final int credits;

        public Subject(double grade, int credits) {
            this.grade = grade;
            this.credits = credits;
        }

        public double getGrade() {
            return grade;
        }

        public int getCredits() {
            return credits;
        }
    }
}
