#include<stdio.h>
#include<conio.h>
#include<string.h>

#define max 100
#define size 50

int top=-1;
char stack[max][size];

void push(char operation[])
{
    if(top==max-1)
    {
        printf("The Action list is full\n");
    }
    else
    {
        top++;
        strcpy(stack[top],operation);
        printf("Action Pushed: %s\n",operation);
    }
}

void pop()
{
    if(top==-1)
    {
        printf("There are no previous operations to undo\n");
    }
    else
    {
        printf("The undo is done for %s\n",stack[top]);
        top--;
    }
}

void display()
{
    printf("Operation history\n");
    for(int i=top;i>=0;i--)
    {
        printf("%s\n",stack[i]);
    }
    printf("\n");
}

void main()
{
    char op[50];
    int ch;
    printf("\n--Text Editor--\n");
    printf("----Operation Menu----\n");
    printf("1)Perform Operation\n2)Undo operation\n3)Display operation list\nExit\n");
    while(1)
    {
        printf("Enter choice:\n");
        scanf("%d",&ch);
        switch(ch)
        {
            case 1: printf("Enter the operation to perform:\n");
                    scanf("%s",op);
                    push(op);
                    break;
            case 2: pop();
                    break;
            case 3: display();
                    break;
            case 4: exit(0);
            default:printf("Invalid Choice!\n");
                    break;
        }
    }
}


