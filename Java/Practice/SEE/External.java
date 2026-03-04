Package SEE;
import CIE.Personal;

public class External extends Personal
{
    int[] seeMarks = new int[5];

    public External(int marks[])
    {
        super(usn, name, sem);
        for(int i=0; i<n; i++)
        {
            seeMarks[i] = marks[i];
        }
    }
}