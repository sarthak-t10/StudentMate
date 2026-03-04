#include <stdio.h>

int ht[100], m;

void insert(int key)
{
    int index = key % m;
    int start = index;

    while (ht[index] != -1)
    {
        index = (index + 1) % m;
        if (index == start)
        {
            printf("Hash table is full\n");
            return;
        }
    }
    ht[index] = key;
}

void display()
{
    int i;
    for (i = 0; i < m; i++)
        printf("%d : %d\n", i, ht[i]);
}

int main()
{
    int n, key, i;

    printf("Enter size of hash table: ");
    scanf("%d", &m);

    for (i = 0; i < m; i++)
        ht[i] = -1;

    printf("Enter number of keys: ");
    scanf("%d", &n);

    for (i = 0; i < n; i++)
    {
        printf("Enter key: ");
        scanf("%d", &key);
        insert(key);
    }

    display();
    return 0;
}

