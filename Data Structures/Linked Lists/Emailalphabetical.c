#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct node {
    char name[50];
    char email[50];
    struct node *prev;
    struct node *next;
};

struct node *head = NULL;

// Function to create a new node
struct node* createNode(char *name, char *email) {
    struct node *newNode = (struct node*)malloc(sizeof(struct node));
    strcpy(newNode->name, name);
    strcpy(newNode->email, email);
    newNode->prev = newNode->next = NULL;
    return newNode;
}

// Insert customer in alphabetical order
void insertSorted(char *name, char *email) {
    struct node *newNode = createNode(name, email);

    // Case 1: First node
    if (head == NULL) {
        head = newNode;
        return;
    }

    struct node *temp = head;

    // Case 2: Insert at beginning
    if (strcmp(name, temp->name) < 0) {
        newNode->next = head;
        head->prev = newNode;
        head = newNode;
        return;
    }

    // Traverse to find correct position
    while (temp->next != NULL && strcmp(name, temp->next->name) > 0) {
        temp = temp->next;
    }

    // Insert node
    newNode->next = temp->next;
    newNode->prev = temp;

    if (temp->next != NULL)
        temp->next->prev = newNode;

    temp->next = newNode;
}

// Display all customers
void display() {
    struct node *temp = head;
    printf("\nCustomer List in Alphabetical Order:\n");
    while (temp != NULL) {
        printf("Name: %s\tEmail: %s\n", temp->name, temp->email);
        temp = temp->next;
    }
}

int main() {
    int n;
    char name[50], email[50];

    printf("Enter number of customers: ");
    scanf("%d", &n);

    for (int i = 0; i < n; i++) {
        printf("\nEnter Customer %d Name: ", i+1);
        scanf("%s", name);
        printf("Enter Email: ");
        scanf("%s", email);

        insertSorted(name, email);
    }

    display();
    return 0;
}
