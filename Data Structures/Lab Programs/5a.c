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
    struct node *p,*start, *current;
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



struct node *deletesllbeg(struct node *start)
{
    struct node *temp;
    if(start==NULL)
    {
        printf("the sll is empty\n");
        return start;
    }
    else if(start->next==NULL)
    {
        temp=start;
        printf("Element deleted: %d\n",start->info);
        start=NULL;
        free(temp);
        return start;
    }
    else
    {
        temp=start;
        printf("Element deleted:%d",start->info);
        start=start->next;
        free(temp);
        return start;
    }
}


struct node *deletesllend(struct node *start)
{
    struct node *temp,*follow;
    if(start==NULL)
    {
        printf("The sll is empty\n");
    }
    else
    {
        temp=start;
        follow=NULL;
        while(temp->next!=NULL)
        {
            follow=temp;
            temp=temp->next;
        }
        printf("the element deleted: %d\n",temp->info);
        free(temp);
        follow->next=NULL;
    }
    return start;

}



struct node* delete_at_position(struct node *start, int pos) {
    struct node *temp, *p;
    int i;

    if (start == NULL)
        return start;

    if (pos == 1) {
        temp = start;
        start = start->next;
        free(temp);
        return start;
    }

    p = start;
    for (i = 1; i < pos - 1 && p != NULL; i++)
        p = p->next;

    if (p == NULL || p->next == NULL)
        return start;

    temp = p->next;
    p->next = temp->next;
    free(temp);

    return start;
}



void main()
{
    struct node *start;
    start=NULL;
    int choice,item,pos;
    printf("-----MENU FOR SINGLY LINKED LIST OPERATIONS-----\n");
    printf("1)Create sll\n");
    printf("2)Delete at beg of sll\n");
    printf("3)Delete at end of sll\n");
    printf("4)Delete at any pos of sll\n");
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
                start=deletesllbeg(start);
                break;
            case 3:
                start=deletesllend(start);
                break;
            case 4:
                printf("Enter the position to delete the element\n");
                scanf("%d",&pos);
                start=delete_at_position(start,pos);
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
