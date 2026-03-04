package com.cgpa.calculator;

import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

public class CGPACalculatorTest {

    private CGPACalculator calculator;

    @Before
    public void setUp() {
        calculator = new CGPACalculator();
    }

    @Test
    public void testAddSubject() {
        calculator.addSubject(8.5, 3);
        assertEquals(1, calculator.getSubjectCount());
    }

    @Test
    public void testCalculateCGPA() {
        calculator.addSubject(8.0, 3);
        calculator.addSubject(9.0, 4);
        calculator.addSubject(7.5, 2);

        double expectedCGPA = (8.0 * 3 + 9.0 * 4 + 7.5 * 2) / (3 + 4 + 2);
        assertEquals(expectedCGPA, calculator.calculateCGPA(), 0.01);
    }

    @Test
    public void testCalculateCGPAEmptyList() {
        assertEquals(0, calculator.calculateCGPA(), 0.01);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testInvalidGrade() {
        calculator.addSubject(11.0, 3); // Grade > 10
    }

    @Test(expected = IllegalArgumentException.class)
    public void testNegativeGrade() {
        calculator.addSubject(-1.0, 3); // Grade < 0
    }

    @Test(expected = IllegalArgumentException.class)
    public void testInvalidCredits() {
        calculator.addSubject(8.0, 0); // Credits <= 0
    }
}
