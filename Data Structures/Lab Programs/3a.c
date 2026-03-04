#include<stdio.h>
#include<stdlib.h>

struct node {
    int info;
    struct node *next;
};


struct node* create_list() {
    int item;
    struct node *start = NULL, *p;

    printf("Enter elements (-1 to stop): ");
    scanf("%d", &item);

    while (item != -1) {
        p = (struct node*)malloc(sizeof(struct node));
        p->info = item;
        p->next = start;
        start = p;
        scanf("%d", &item);
    }
    return start;
}


void display(struct node *start) {
    struct node *temp = start;
    if (start == NULL) {
        printf("List empty\n");
        return;
    }
    while (temp != NULL) {
        printf("%d ", temp->info);
        temp = temp->next;
    }
    printf("\n");
}


struct node* sort_list(struct node *start) {
    struct node *temp, *follow;
    int t;

    if (start == NULL)
        return start;

    for (temp = start; temp->next != NULL; temp = temp->next) {
        for (follow = temp->next; follow != NULL; follow = follow->next) {
            if (temp->info > follow->info) {
                t = temp->info;
                temp->info = follow->info;
                follow->info = t;
            }
        }
    }
    return start;
}


struct node* reverse_list(struct node *start) {
    struct node *prev = NULL, *next = NULL, *current = NULL;
    current = start;

    while (start != NULL) {
        next = current->next;
        current->next = prev;
        prev = current;
        current = next;
    }
    return prev;
}


struct node* concatenate(struct node *start1, struct node *start2) {
    struct node *temp;

    if (start1 == NULL)
        return start2;
    if (start2 == NULL)
        return start1;

    temp = start1;
    while (temp->next != NULL)
        temp = temp->next;

    temp->next = start2;
    return start1;
}


int main() {

    struct node *start1 = NULL, *start2 = NULL;
    int choice;

    while (1) {
        printf("\n--- MENU ---\n");
        printf("1. Create 1st List\n");
        printf("2. Create 2nd List\n");
        printf("3. Display Lists\n");
        printf("4. Sort 1st List\n");
        printf("5. Reverse 1st List\n");
        printf("6. Concatenate List2 to List1\n");
        printf("7. Exit\n");

        scanf("%d", &choice);

        switch (choice) {
            case 1:
                start1 = create_list();
                break;
            case 2:
                start2 = create_list();
                break;
            case 3:
                printf("List 1: ");
                display(start1);
                printf("List 2: ");
                display(start2);
                break;
            case 4:
                start1 = sort_list(start1);
                break;
            case 5:
                start1 = reverse_list(start1);
                break;
            case 6:
                start1 = concatenate(start1, start2);
                printf("Lists concatenated.\n");
                break;
            case 7:
                exit(0);
        }
    }
    return 0;
}
