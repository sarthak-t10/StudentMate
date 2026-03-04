#include <stdio.h>
#include <string.h>
#include <stdlib.h>

struct node {
    char song[25];
    struct node *next;
    struct node *prev;
};

struct node *createplaylist()
{
    struct node *p, *start = NULL;
    char song[25];

    printf("Enter the name of the song to append to the beginning of the playlist\n");
    scanf("%s", song);

    while (strcmp(song, "-1") != 0)
    {
        p = (struct node *)malloc(sizeof(struct node));
        strcpy(p->song, song);
        p->prev = NULL;

        if (start == NULL)
        {
            p->next = NULL;
            start = p;
        }
        else
        {
            p->next = start;
            start->prev = p;
            start = p;
        }
        scanf("%s", song);
    }
    return start;
}

struct node *insertbef(struct node *start, char song[], char bef[])
{
    struct node *temp = start, *p;

    while (temp != NULL && strcmp(temp->song, bef) != 0)
        temp = temp->next;

    if (temp == NULL)
    {
        printf("The song was not found\n");
        return start;
    }

    p = (struct node *)malloc(sizeof(struct node));
    strcpy(p->song, song);

    p->next = temp;
    p->prev = temp->prev;

    if (temp->prev != NULL)
        temp->prev->next = p;
    else
        start = p;


    return start;
}

void displayplaylist(struct node *start)
{
    struct node *temp = start;

    if (start == NULL)
    {
        printf("The playlist is empty\n");
        return;
    }

    while (temp != NULL)
    {
        printf("%s\n", temp->song);
        temp = temp->next;
    }
}

struct node *deletesong(struct node *start, char song[])
{
    struct node *temp=start, *follow=NULL;
    while(temp!=NULL && strcmp(temp->song,song)!=0)
    {
        follow=temp;
        temp=temp->next;
    }
    if(temp==NULL)
    {
        printf("The song is not present in the playlist\n");
        return start;
    }
    follow->next=temp->next;
    temp->next->prev=follow;
    free(temp);
    return start;
};

int main()
{
    struct node *start;

    start = createplaylist();
    start = insertbef(start, "Welcome", "Hello");
    displayplaylist(start);
    start=deletesong(start,"Happy");
    displayplaylist(start);

    return 0;
}
