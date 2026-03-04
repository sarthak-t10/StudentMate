#include<stdio.h>
#include<conio.h>
#include<stdlib.h>

struct node {
    int info;
    struct node *next;
};

struct node *createsllbeg()
{
    int item;
    struct node *p,*start;
    start = NULL;
    printf("Enter the item to insert into the linked list (Enter -1 to exit)\n");
    scanf("%d",&item);

    while(item!=-1)
    {
        p=(struct node *)malloc(sizeof(struct node));
        p->info=item;
        if(start==NULL)
        {
            p->next=NULL;
            start=p;
            printf("First element inserted into the linked list\n");
        }
        else
        {
            p->next=start;
            start=p;
            printf(" element inserted into the linked list\n");
        }
        scanf("%d",&item);
    }

    return start;
}

void displaysll(struct node *start)
{
    struct node *temp;
    if(start==NULL)
    {
        printf("The sll is empty\n");
        return;
    }
    else
    {
        printf("The items in the sll are as follows:\n");
        temp=start;
        while(temp!=NULL)
        {
            printf("%d\t",temp->info);
            temp=temp->next;
        }
    }
}



struct node *insertsllbeg(struct node *start,int item)
{
    struct node *p;
    p=(struct node *)malloc(sizeof(struct node));
    p->info=item;
    if(start==NULL)
    {
        p->next=NULL;
        start=p;
    }
    else
    {
        p->next=start;
        start=p;
    }
    return start;
}


struct node *insertsllend(struct node *start, int item)
{
    struct node *p,*temp;
    p=(struct node *)malloc(sizeof(struct node));
    p->info=item;
    if(start==NULL)
    {
        p->next=NULL;
        start=p;
    }
    else
    {
        temp=start;
        while(temp->next!=NULL)
        {
            temp=temp->next;
        }
        temp->next=p;
        p->next=NULL;
    }
    return start;
}



struct node* insert_at_position(struct node *start, int value, int pos) {
    int i;
    struct node *temp, *p;

    temp = (struct node*)malloc(sizeof(struct node));
    temp->info = value;
    temp->next = NULL;

    if (pos == 1) {
        temp->next = start;
        start = temp;
        return start;
    }

    p = start;
    for (i = 1; i < pos - 1 && p != NULL; i++)
        p = p->next;

    if (p == NULL)
        return start;

    temp->next = p->next;
    p->next = temp;

    return start;
}



void main()
{
    struct node *start;
    start=NULL;
    int choice,item,pos;
    printf("-----MENU FOR SINGLY LINKED LIST OPERATIONS-----\n");
    printf("1)Create sll\n");
    printf("2)Insert at beg of sll\n");
    printf("3)Insert at end of sll\n");
    printf("4)Insert at any position in sll\n");
    printf("5)Display sll\n");
    printf("6)Exit\n");
    while(1)
    {
        printf("\nEnter your choice:\n");
        scanf("%d",&choice);
        switch(choice)
        {
            case 1:
                start=createsllbeg();
                break;
            case 2:
                printf("Enter the item to insert at beg of sll:\n");
                scanf("%d",&item);
                start=insertsllbeg(start,item);
                break;
            case 3:
                printf("Enter the item to insert at end of sll:\n");
                scanf("%d",&item);
                start=insertsllend(start,item);
                break;
            case 4:
                printf("Enter the item to insert:\n");
                int item;
                scanf("%d",&item);
                printf("Enter the position to insert\n");
                scanf("%d",&pos);
                start=insert_at_position(start,item,pos);
                break;

            case 5:
                displaysll(start);
                break;

            case 6:
                exit(0);
            default:
                printf("Invalid choice! Please try again.\n");
        }
    }
}
