#include<stdio.h>
#include<stdlib.h>

struct tree {
    int info;
    struct tree *right;
    struct tree *left;
};


struct tree *createbst()
{
    int val;
    struct tree *root=NULL;
    root=(struct tree *)malloc(sizeof(struct tree));
    printf("Enter the value for the root node\n");
    scanf("%d",&val);
    root->info=val;
    root->left=NULL;
    root->right=NULL;
    return root;
}

struct tree *insertnode(struct tree *root, int val)
{
    struct tree *p, *temp=root, *curr=NULL;
    p=(struct tree *)malloc(sizeof(struct tree));
    p->info=val;
    p->left=NULL;
    p->right=NULL;
    while(temp!=NULL)
    {
        curr=temp;
        if(val<temp->info)
        {
            temp=temp->left;
        }
        else
        {
            temp=temp->right;
        }
    }
    if(val<curr->info)
        curr->left=p;
    else
        curr->right=p;
    return root;


}

void inorder(struct tree *root)
{
    if(root!=NULL)
    {
        inorder(root->left);
        printf("%d\t",root->info);
        inorder(root->right);
    }
}

void preorder(struct tree *root)
{
    if(root!=NULL)
    {
        printf("%d\t",root->info);
        preorder(root->left);
        preorder(root->right);
    }
}

void postorder(struct tree *root)
{
    if(root!=NULL)
    {
        postorder(root->left);
        postorder(root->right);
        printf("%d\t",root->info);
    }
}

void main()
{
    struct tree *root;
    root=createbst();
    root=insertnode(root,70);
    root=insertnode(root,120);
    root=insertnode(root,60);
    root=insertnode(root,80);
    root=insertnode(root,110);
    root=insertnode(root,200);
    inorder(root);
    printf("\n");
    preorder(root);
    printf("\n");
    postorder(root);
    printf("\n");
}
