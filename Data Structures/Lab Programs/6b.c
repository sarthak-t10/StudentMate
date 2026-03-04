#include<stdio.h>
#include<stdlib.h>

struct node {
    int info;
    struct node *next;
};

struct node* push(struct node *start, int item) {
    struct node *p = (struct node*)malloc(sizeof(struct node));
    p->info = item;
    p->next = start;
    start = p;
    return start;
}

struct node* pop(struct node *start) {
    struct node *temp;
    if (start == NULL)
    {
        printf("The stack is empty\n");
        return start;
    }
    temp = start;
    start = start->next;
    free(temp);
    return start;
}

void display(struct node *start) {
    struct node *temp = start;
    if (start == NULL) {
        printf("Empty\n");
        return;
    }
    while (temp != NULL) {
        printf("%d ", temp->info);
        temp = temp->next;
    }
    printf("\n");
}

struct node* enqueue(struct node *start, int item) {
    struct node *p, *temp;
    p = (struct node*)malloc(sizeof(struct node));
    p->info = item;
    p->next = NULL;

    if (start == NULL) {
        start = p;
        return start;
    }

    temp = start;
    while (temp->next != NULL)
        temp = temp->next;

    temp->next = p;
    return start;
}

struct node* dequeue(struct node *start) {
    struct node *temp;
    if (start == NULL)
    {
        printf("The queue is empty\n");
        return start;
    }

    return start;
    temp = start;
    start = start->next;
    free(temp);
    return start;
}

int main() {
    struct node *stack = NULL, *queue = NULL;
    int ch, item;

    while (1) {
        printf("\n1 Push\n2 Pop\n3 Display Stack\n4 Enqueue\n5 Dequeue\n6 Display Queue\n7 Exit\n");
        scanf("%d", &ch);

        switch (ch) {
            case 1:
                scanf("%d",&item);
                stack = push(stack, item);
                break;
            case 2:
                stack = pop(stack);
                break;
            case 3:
                display(stack);
                break;
            case 4:
                scanf("%d",&item);
                queue = enqueue(queue, item);
                break;
            case 5:
                queue = dequeue(queue);
                break;
            case 6:
                display(queue);
                break;
            case 7:
                exit(0);
        }
    }
}
