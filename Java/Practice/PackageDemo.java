import java.util.Scanner;
import CIE.*;
import SEE.*;

class PackageDemo
{
    public static void main(String args[])
    {
        Scanner sc = new Scanner(System.in);
        System.out.println("Enter the number of students:");
        int n = sc.nextInt();
        int students[] = new int[n];
        
        for(int i=0;i<n;i++)
        {
            System.out.println("Enter details for student " + (i+1) + ":");
            System.out.print("USN: ");
            String usn = sc.next();
            System.out.print("Name: ");
            String name = sc.next();
            System.out.print("Semester: ");
            int sem = sc.nextInt();
            
            System.out.println("Enter internal marks for 5 subjects:");
            int internalMarks[] = new int[5];
            for(int j=0;j<5;j++)
            {
                internalMarks[j] = sc.nextInt();
            }
            Internals internals = new Internals(internalMarks);
            
            System.out.println("Enter SEE marks for 5 subjects:");
            int seeMarks[] = new int[5];
            for(int j=0;j<5;j++)
            {
                seeMarks[j] = sc.nextInt();
            }
            External external = new External(usn, name, sem, seeMarks);
            
            System.out.println("Student " + (i+1) + " details recorded.");
            System.out.println("USN:"+ usn);
            System.out.println("Name:"+ name);
            System.out.println("Semester:"+ sem);
            System.out.print("Internal Marks: ");
            for(int j=0; j<5; j++)
            {
                System.out.println("Subject "+(j+1)+"internalmarks[j]+seeMarks[j]/2");
                
            }
        }
    }
}