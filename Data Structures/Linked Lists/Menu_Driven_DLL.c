#include<stdio.h>
#include<stdlib.h>



struct node {
    struct node *prev;
    int info;
    struct node *next;
};

struct node *createdllbeg()
{
    struct node *p,*start=NULL;
    int item;
    p=(struct node *)malloc(sizeof(struct node));
    printf("Enter the element to isert\n");
    scanf("%d",&item);
    while(item!=-1)
    {
            p=(struct node *)malloc(sizeof(struct node));
            p->info=item;
            if(start==NULL)
            {
                p->prev=NULL;
                p->next=NULL;
                start=p;
            }
            else
            {
                p->next=start;
                p->prev=NULL;
                start->prev=p;
                start=p;
            }
            printf("Enter the element to insert\n");
            scanf("%d",&item);
    }
    return start;
}

struct node *insertdllbeg(struct node *start, int item)
{
    struct node *p;
    p=(struct node *)malloc(sizeof(struct node));
    p->info=item;
    if(start == NULL)
    {
        p->prev=NULL;
        p->next=NULL;
        start=p;
    }
    else
    {
        p->next=start;
        p->prev=NULL;
        start->prev=p;
        start=p;
    }
    return start;
}

struct node *insertdllend(struct node *start, int item)
{
    struct node *p,*temp;
    p=(struct node *)malloc(sizeof(struct node));
    p->info=item;
    if (start == NULL)
    {
        p->prev=NULL;
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
        p->prev=temp;
    }
    return start;
}

struct node *deletedllbeg(struct node *start)
{
    struct node *temp;
    if(start==NULL)
    {
        printf("The dll is empty \n");


    }
    else if(start->next==NULL)
    {
        temp=start;
        printf("Element deleted:%d\n",start->info);
        start=NULL;
        free(temp);
    }    
    else
    {
        temp=start;
        printf("Element deleted:%d\n",start->info);
        start=start->next;
        start->prev=NULL;
        free(temp);
    }
    return start;
}

struct node *deletedllend(struct node *start)
{
    struct node *temp;
    if(start==NULL)
    {
        printf("The dll is empty\n");
    }
    else if(temp->next==NULL)
    {
        temp=start;
        printf("Element deleted:%d\n",start->info);
        start=NULL;
        free(temp);
    }
    else
    {
        temp=start;
        while(temp->next!=NULL)
        {
            temp=temp->next;
        }
        printf("Element deleted:%d\n",temp->info);
        temp->prev->next=NULL;
        free(temp);
    }
    return start;
}


void displaydll(struct node *start)
{
    struct node *temp;
    if(start==NULL)
    {
        printf("The dll is empty\n");
    }
    else
    {
        temp=start;
        while(temp!=NULL)
        {
            printf("%d ",temp->info);
            temp=temp->next;
        }
        printf("\n");
    }
}

int main()
{
    struct node *start;
    int choice,item;
    start=NULL;
    printf("-----MENU FOR DOUBLY LINKED LIST OPERATIONS-----\n");
    printf("1)Create dll at beg\n");
    printf("2)Insert at beg of dll\n");
    printf("3)Insert at end of dll\n");
    printf("4)Display dll\n");
    printf("5)Delete from beg of dll\n");
    printf("6)Delete from end of dll\n");
    while(1)
    {
        printf("\nEnter your choice:\n");
        scanf("%d",&choice);
        switch(choice)
        {
            case 1:
                start=createdllbeg();
                break;
            case 2:
                printf("Enter the item to insert at beg of dll:\n");
                scanf("%d",&item);
                start=insertdllbeg(start,item);
                break;
            case 3:
                printf("Enter the item to insert at end of dll:\n");
                scanf("%d",&item);
                start=insertdllend(start,item);    
                break;
                
            case 4:
                displaydll(start);
                break;
            case 5:
                start=deletedllbeg(start);
                break;
            case 6:
                start=deletedllend(start);
                break;
            case 7: 
                exit(0);
            default:
                printf("Invalid choice! Please try again.\n");
        }
    }
    return 0;
}