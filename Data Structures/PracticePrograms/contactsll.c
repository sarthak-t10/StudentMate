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
    char contact[25];

    scanf("%s",contact);
    while(strcmp(contact,"-1")!=0)
    {
        p=(struct node *)malloc(sizeof(struct node));
        strcpy(p->info, contact);
        p->next=start;
        start=p;
        scanf("%s",contact);
    }
    return start;
}

struct node *insertsllbeg(struct node *start, char contact[])
{
    struct node *p;
    p=(struct node *)malloc(sizeof(struct node));
    strcpy(p->info,contact);
    p->next=start;
    start=p;
    return start;
}

struct node *insertsllend(struct node *start, char contact[])
{
    struct node *p,*temp;
    p=(struct node *)malloc(sizeof(struct node));
    strcpy(p->info,contact);
    p->next=NULL;

    if(start==NULL)
    {
        start=p;
    }
    else
    {
        temp=start;
        while(temp->next!=NULL)
            temp=temp->next;
        temp->next=p;
    }
    return start;
}

struct node *insertsllpos(struct node *start, char contact[], int pos)
{
    struct node *p,*temp;
    p=(struct node *)malloc(sizeof(struct node));
    strcpy(p->info,contact);

    if(pos==1)
    {
        p->next=start;
        start=p;
    }
    else
    {
        temp=start;
        for(int i=1;i<pos-1;i++)
            temp=temp->next;
        p->next=temp->next;
        temp->next=p;
    }
    return start;
}

void displaysll(struct node *start)
{
    struct node *temp=start;
    while(temp!=NULL)
    {
        printf("%s\n",temp->info);
        temp=temp->next;
    }
}

int main()
{
    struct node *start;
    char contact1[]="Mom";
    char contact2[]="Dad";
    char contact3[]="Samrat";
    char contact4[]="Sriram";

    start=createsllbeg();
    start=insertsllbeg(start, contact1);
    start=insertsllend(start, contact2);
    start=insertsllbeg(start, contact3);
    start=insertsllpos(start, contact4, 2);
    displaysll(start);

    return 0;
}
