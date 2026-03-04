#include <stdio.h>
#include <stdlib.h>

struct node {
    int info;
    struct node *left;
    struct node *right;
};

struct node* insert(struct node *root, int item) {
    struct node *p,*par,*cur;
    p=(struct node *)malloc(sizeof(struct node));
    p->info=item;
    p->left=NULL;
    p->right=NULL;
    if(root==NULL)
    {
        root=p;
        return root;
    }
    else
    {
        cur=root;
        while(cur!=NULL)
        {
            par=cur;
            if(item<cur->info)
                cur=cur->left;
            else
                cur=cur->right;
        }
    }
    if (item < par->info)
        par->left = p;
    else if (item > par->info)
        par->right = p;
    return root;
}

void inorder(struct node *root) {
    if (root != NULL) {
        inorder(root->left);
        printf("%d ", root->info);
        inorder(root->right);
    }
}

void preorder(struct node *root) {
    if (root != NULL) {
        printf("%d ", root->info);
        preorder(root->left);
        preorder(root->right);
    }
}

void postorder(struct node *root) {
    if (root != NULL) {
        postorder(root->left);
        postorder(root->right);
        printf("%d ", root->info);
    }
}

int main() {
    struct node *root = NULL;
    int choice, item;

    while (1) {
        printf("\n1.Insert\n2.Inorder\n3.Preorder\n4.Postorder\n5.Exit\n");
        scanf("%d", &choice);

        switch (choice) {
            case 1:
                scanf("%d", &item);
                root = insert(root, item);
                break;
            case 2:
                inorder(root);
                break;
            case 3:
                preorder(root);
                break;
            case 4:
                postorder(root);
                break;
            case 5:
                exit(0);
        }
    }
}
