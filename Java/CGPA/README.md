# CGPA Calculator

A simple Java application to calculate CGPA (Cumulative Grade Point Average) based on subject grades and credits.

## Features

- Add multiple subjects with grades and credits
- Calculate weighted CGPA
- Input validation for grades (0-10) and credits (positive values)
- Unit tests using JUnit

## Project Structure

```
cgpa-calculator/
├── src/
│   ├── main/java/com/cgpa/calculator/
│   │   ├── Main.java                 # Entry point
│   │   └── CGPACalculator.java        # Core calculator logic
│   └── test/java/com/cgpa/calculator/
│       └── CGPACalculatorTest.java    # Unit tests
├── pom.xml                            # Maven configuration
└── README.md                          # This file
```

## Building the Project

### Using Maven
```bash
mvn clean install
```

### Compile Only
```bash
mvn compile
```

### Run Tests
```bash
mvn test
```

## Running the Application

### Using Maven
```bash
mvn exec:java -Dexec.mainClass="com.cgpa.calculator.Main"
```

### Using Java Directly (after compilation)
```bash
java -cp target/cgpa-calculator-1.0.0.jar com.cgpa.calculator.Main
```

## How It Works

1. The application prompts for the number of subjects
2. For each subject, enter the grade (0-10) and credits
3. The CGPA is calculated using the formula:
   ```
   CGPA = (Σ Grade × Credits) / Σ Credits
   ```

## Example

```
=== CGPA Calculator ===
Enter the number of subjects: 
3

Subject 1:
Enter grade (0-10): 8.5
Enter credits: 3

Subject 2:
Enter grade (0-10): 9.0
Enter credits: 4

Subject 3:
Enter grade (0-10): 7.5
Enter credits: 2

=== Results ===
Your CGPA: 8.43
```

## Requirements

- Java 25 or higher
- Maven 3.6.0 or higher

## License

MIT License
