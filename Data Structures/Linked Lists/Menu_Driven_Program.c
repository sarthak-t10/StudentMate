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

struct node *insertsllafter(struct node *start, int ele, int item)
{
    struct node *temp,*p;
    p=(struct node *)malloc(sizeof(struct node));
    p->info=item;
    if (start==NULL)
    {
        printf("The sll is empty\n");
    }
    else 
    {
        temp=start;
        while(temp!=NULL && temp->info!=ele)
        {
            temp=temp->next;
        }
        if(temp==NULL)
        {
            printf("The element was not found\n");
        }
        else
        {
            p->next=temp->next;
            temp->next=p;
        }
    }
}


void searchsll(struct node *start, int item)
{
    struct node *temp;
    temp=start;
    int count=0;
    if(start==NULL)
    {
        printf("the sll is empty");
    }
    else
    {
        while(temp!=NULL && item!=temp->info)
        {
            count=count+1;
            temp=temp->next;
        }
        if(temp==NULL)
        {
            printf("The element is not found\n");
        }
        else
        {
            printf("The element %d is found at the position %d\n",item,count+1);
        }
    }
    
}

void occurancesll(struct node *start, int item)
{
    struct node *temp;
    int count=0;
    if(start==NULL)
    {
        printf("The sll is empty\n");
    }
    else
    {
        temp=start;
        while(temp!=NULL)
        {
            if(temp->info==item)
            {
                count=count+1;
            }
            temp=temp->next;
        }
        printf("The element %d occurs %d times in the sll\n",item,count);
    }
}

void main()
{
    struct node *start;
    start=NULL;
    int choice,item;
    printf("-----MENU FOR SINGLY LINKED LIST OPERATIONS-----\n");
    printf("1)Create sll\n");
    printf("2)Insert at beg of sll\n");
    printf("3)Insert at end of sll\n");
    printf("4)Insert after an element in sll\n");
    printf("5)Delete at beg of sll\n");
    printf("6)Delete at end of sll\n");
    printf("7)Display sll\n");
    printf("8)Search in sll\n");
    printf("9)Count occurrences in sll\n");
    printf("10)Exit\n");
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
                printf("Enter the element after which to insert:\n");
                int ele;
                scanf("%d",&ele);
                printf("Enter the item to insert after %d in sll:\n",ele);
                scanf("%d",&item);
                start=insertsllafter(start,ele,item);
                break;    
            case 5:
                start=deletesllbeg(start);
                break;
            case 6:
                start=deletesllend(start);
                break;    
            case 7:
                displaysll(start);
                break;
            case 8:
                printf("Enter the item to search in sll:\n");
                scanf("%d",&item);
                searchsll(start,item);
                break;  
            case 9:
                printf("Enter the item to count occurrences in sll:\n");
                scanf("%d",&item);
                occurancesll(start,item);
                break;      
            case 10:
                exit(0);
            default:
                printf("Invalid choice! Please try again.\n");
        }
    }
}    