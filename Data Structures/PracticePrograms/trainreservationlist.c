#include<stdio.h>
#include<stdlib.h>
#include<string.h>

struct node
{
    char info[25];
    struct node *next;
};

struct node *createsllbeg()
{
    struct node *p,*start=NULL;
    char passenger[25];

    scanf("%s",passenger);
    while(strcmp(passenger,"-1")!=0)
    {
        p=(struct node *)malloc(sizeof(struct node));
        strcpy(p->info, passenger);
        p->next=start;
        start=p;
        scanf("%s",passenger);
    }
    return start;
}

struct node *deletesllbeg(struct node *start)
{
    struct node *temp=start;
    if(start==NULL)
    {
        printf("Reservation list empty\n");
    }
    else if(start->next==NULL)
    {
        printf("Passenger out of waitlist:%s\n",temp->info);
        free(temp);
        start=NULL;
    }
    else
    {
        printf("Passenger out of waitlist:%s\n",temp->info);
        start=start->next;
        free(temp);
    }
    return start;
}

struct node *deletesllend(struct node *start)
{
    struct node *temp=start,*follow=NULL;
    if(start==NULL)
    {
        printf("Reservation list empty\n");
    }
    else if(start->next==NULL)
    {
        printf("Passenger removed from end of waitlist:%s\n",start->info);
        free(start);
        start=NULL;
    }
    else
    {
        while(temp->next!=NULL)
        {
            follow=temp;
            temp=temp->next;
        }
        printf("Passenger removed from end of waitlist:%s\n",temp->info);
        follow->next=NULL;
        free(temp);
    }
    return start;
}

struct node *deletesllpos(struct node *start, int pos)
{
    struct node *temp=start,*follow=NULL;
    if(start==NULL)
    {
        printf("Reservation list empty\n");
    }
    else if(pos==1)
    {
        printf("The passenger cancelled and removed:%s\n",start->info);
        start=start->next;
        free(temp);
    }
    else
    {
        int i=1;
        while(temp!=NULL && i<pos)
        {
            follow=temp;
            temp=temp->next;
            i++;
        }
        if(temp==NULL)
            printf("Invalid position\n");
        else
        {
            printf("The passenger cancelled and removed:%s\n",temp->info);
            follow->next=temp->next;
            free(temp);
        }
    }
    return start;
}

void displaysll(struct node *start)
{
    struct node *temp=start;
    if(start==NULL)
        printf("Reservation list empty\n");
    while(temp!=NULL)
    {
        printf("%s\n",temp->info);
        temp=temp->next;
    }
}

int main()
{
    struct node *start=NULL;
    start=createsllbeg();
    displaysll(start);
    start=deletesllbeg(start);
    displaysll(start);
    start=deletesllend(start);
    displaysll(start);
    start=deletesllpos(start, 3);
    displaysll(start);
    return 0;
}
