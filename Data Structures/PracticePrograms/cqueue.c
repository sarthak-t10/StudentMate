#include<stdio.h>
#include<stdlib.h>

#define max 100;
int front=-1;
int rear=-1
int queue[max];

void cenqueue(int item)
{
    if(rear=max-1)
    {
        printf("overflow\n");
        return;
    }
    if(front=-1)
    {
        front=0;
        rear=0;
        queue[rear]=item;
    }
    else
    {
        rear=(rear+1)%max;
        queue[rear]=item;
    }
}

