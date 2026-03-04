#include<stdio.h>
#include<stdlib.h>

struct node {
    int info;
    struct node *next;
    struct node *prev;
};

struct node *createdllbeg()
{
    struct node *p,*start=NULL;
    int item;
    printf("Enter the item to insert\n");
    scanf("%d",&item);
    while(item!=-1)
    {
        p=(struct node *)malloc(sizeof(struct node));
        p->info=item;
        p->next=NULL;
        p->prev=NULL;
        if(start==NULL)
        {
            start=p;
        }
        else
        {
            p->next=start;
            start->prev=p;
            start=p;
        }
        scanf("%d",&item);
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
            printf("%d\t",temp->info);
            temp=temp->next;
        }
        printf("\n");
    }
}

struct node *insertdll(struct node *start, int item, int key)
{
    struct node *p,*temp;
    p=(struct node *)malloc(sizeof(struct node));
    p->info=item;
    temp=start;
    while(temp!=NULL && temp->info!=key)
        temp=temp->next;
    if(temp==start)
    {
        p->prev=NULL;
        p->next=start;
        start->prev=p;
        start=p;
    }
    else
    {
        p->prev=temp->prev;
        p->next=temp;
        temp->prev->next=p;
        temp->prev=p;
    }
    return start;
}

struct node *deleteval(struct node *start, int item)
{
    struct node *temp,*follow;
    temp=start;
    while(temp!=NULL && temp->info!=item)
    {
        follow=temp;
        temp=temp->next;
    }
    if(temp==NULL)
    {
        printf("Item not found\n");
        return start;
    }
    if(temp==start)
    {
        start=start->next;
        free(temp);

    }
    else
    {
        follow->next=temp->next;
        temp->next->prev=follow;
        free(temp);
    }
    return start;
}

void main()
{
   int ch,item,key;
   struct node *start=NULL;
   while(1)
   {
       printf("1)Create\n2)Insert\n3)Delete\n4)Display\n5)Exit\nEnter your choice:\n");
       scanf("%d",&ch);
       switch(ch)
       {
           case 1:  start=createdllbeg();
                    break;
           case 2:  printf("Enter the item and key\n");
                    scanf("%d%d",&item,&key);
                    start=insertdll(start,item,key);
                    break;
           case 3:  printf("Enter the value to delete\n");
                    scanf("%d",&item);
                    start=deleteval(start,item);
                    break;
           case 4:  displaydll(start);
                    break;
           case 5: exit(0);
           default: printf("Invalid choice\n");
       }

   }
}
