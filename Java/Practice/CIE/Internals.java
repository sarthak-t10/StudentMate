Package CIE;

public class Internals
{
    int internalmarks[] = new int[5];

    public Internals(int[] marks)
    {
        for(int i=0;i<5;i++)
        {
            internalmarks[i] = marks[i];
        }
    }
}