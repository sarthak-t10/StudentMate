#include <stdio.h>
#include <stdlib.h>

/* BST Node Structure */
struct Node
{
    int data;
    struct Node *left;
    struct Node *right;
};

/* Create a new node */
struct Node* createNode(int data)
{
    struct Node* newNode = (struct Node*)malloc(sizeof(struct Node));
    newNode->data = data;
    newNode->left = NULL;
    newNode->right = NULL;
    return newNode;
}

/* Insert function */
struct Node* insert(struct Node* root, int data)
{
    if (root == NULL)
        return createNode(data);

    if (data < root->data)
        root->left = insert(root->left, data);
    else if (data > root->data)
        root->right = insert(root->right, data);

    return root;
}

/* Find minimum value node (inorder successor) */
struct Node* findMin(struct Node* root)
{
    while (root->left != NULL)
        root = root->left;
    return root;
}

/* Delete function (as given) */
struct Node* deleteNode(struct Node* root, int key)
{
    if (root == NULL)
        return root;

    if (key < root->data)
        root->left = deleteNode(root->left, key);
    else if (key > root->data)
        root->right = deleteNode(root->right, key);
    else
    {
        /* Case 1: No child */
        if (root->left == NULL && root->right == NULL)
        {
            free(root);
            return NULL;
        }

        /* Case 2: One child (right) */
        else if (root->left == NULL)
        {
            struct Node* temp = root->right;
            free(root);
            return temp;
        }

        /* Case 2: One child (left) */
        else if (root->right == NULL)
        {
            struct Node* temp = root->left;
            free(root);
            return temp;
        }

        /* Case 3: Two children */
        struct Node* temp = findMin(root->right);
        root->data = temp->data;
        root->right = deleteNode(root->right, temp->data);
    }

    return root;
}

/* Inorder Traversal */
void inorder(struct Node* root)
{
    if (root != NULL)
    {
        inorder(root->left);
        printf("%d ", root->data);
        inorder(root->right);
    }
}

/* Driver Method */
int main()
{
    struct Node* root = NULL;

    /* Insert nodes */
    root = insert(root, 50);
    insert(root, 30);
    insert(root, 20);
    insert(root, 40);
    insert(root, 70);
    insert(root, 60);
    insert(root, 80);
    insert(root, 65);

    printf("Inorder traversal before deletion:\n");
    inorder(root);

    root = deleteNode(root, 50);

    printf("\n\nInorder traversal after deletion:\n");
    inorder(root);

    root = deleteNode(root, 20);

    printf("\n\nInorder traversal after deletion:\n");
    inorder(root);

    root = deleteNode(root, 65);

    printf("\n\nInorder traversal after deletion:\n");
    inorder(root);

    return 0;
}
