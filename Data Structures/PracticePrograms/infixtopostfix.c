#include<stdio.h>
#include<string.h>
#define max 100

char stack[max];
char infix[max];
char postfix[max];
int top=-1;
int pos=0;
int count=0;

void push(char s)
{
    if(top==max-1)
        return;
    stack[++top] = s;   // FIX: simplified increment and assignment
}

char pop()
{
    if(top==-1)
        return -1;
    return stack[top--];
}

int precedence(char s)
{
    int p = 0;          // FIX: initialize p to avoid garbage value
    switch(s)
    {
        case '^': p = 3; break;
        case '*':
        case '/': p = 2; break;
        case '+':
        case '-': p = 1; break;
        case '(':
        case ')': p = 0; break;
    }
    return p;
}

void itop(char infix[], char postfix[])
{
    char sym, temp;
    int len = strlen(infix);

    while(count < len)
    {
        sym = infix[count];

        switch(sym)
        {
        case '(':
            push(sym);
            break;

        case ')':
            temp = pop();
            while(temp != '(')
            {
                postfix[pos++] = temp;
                temp = pop();
            }
            break;

        case '+':
        case '-':
        case '*':
        case '/':
        case '^':
            while(top != -1 && precedence(stack[top]) >= precedence(sym))
            {
                temp=pop();
                postfix[pos++] = temp;   // FIX: removed extra pop
            }
            push(sym);
            break;

        default:
            postfix[pos++] = sym;         // FIX: increment pos
        }
        count++;
    }

    while(top != -1)                       // FIX: pop remaining operators
        postfix[pos++] = pop();

    postfix[pos] = '\0';                   // FIX: terminate postfix string
}

void main()                                 // FIX: standard main return type
{
    printf("Enter the infix expression\n");
    scanf("%s", infix);

    itop(infix, postfix);

    printf("The postfix expression is: %s\n", postfix);
}
