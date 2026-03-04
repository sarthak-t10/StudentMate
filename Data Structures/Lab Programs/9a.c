#include <stdio.h>

int n;
int adj[20][20];
int visited[20];
int queue[20];
int front = -1, rear = -1;

void bfs(int start) {
    int i, v;

    visited[start] = 1;
    queue[++rear] = start;

    printf("BFS Traversal: ");

    while (front != rear) {
        v = queue[++front];
        printf("%d ", v);

        for (i = 0; i < n; i++) {
            if (adj[v][i] == 1 && visited[i] == 0) {
                visited[i] = 1;
                queue[++rear] = i;
            }
        }
    }
}

int main() {
    int i, j, start;

    printf("Enter number of vertices: ");
    scanf("%d", &n);

    printf("Enter adjacency matrix:\n");
    for (i = 0; i < n; i++) {
        for (j = 0; j < n; j++) {
            scanf("%d", &adj[i][j]);
        }
    }

    for (i = 0; i < n; i++)
        visited[i] = 0;

    printf("Enter starting vertex: ");
    scanf("%d", &start);

    bfs(start);

    return 0;
}
