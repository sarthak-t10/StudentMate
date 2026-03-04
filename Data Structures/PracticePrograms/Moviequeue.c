#include<stdio.h>
#include<stdlib.h>

#define max 100

int front=-1;
int rear=-1;
int queue[max];

void enqueue(int tno)
{
    if(rear==max-1)
    {
        printf("The queue is full. Try again later\n");
    }
    else if(front==-1)
    {
        front=0;
        rear=0;
        queue[rear]=tno;

    }
    else
    {
        rear++;
        queue[rear]=tno;
    }
}

void dequeue()
{
    if(front==-1)
    {
        printf("The queue is empty cannot remove \n");

    }
    else if(front==rear)
    {
        printf("%d ticket number removed\n",queue[front]);
        front=-1;
        rear=-1;
    }
    else
    {
        printf("%d ticket number removed\n",queue[front]);
        front++;
    }
}

void display()
{
    for(int i=front;i<=rear;i++)
    {
        printf("%d \t",queue[i]);
    }
    printf("\n");
}

void main()
{
    enqueue(1);
    enqueue(2);
    enqueue(3);
    display();
    dequeue();
    display();
}
