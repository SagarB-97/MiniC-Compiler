#ifndef SCOPE_H
#define SCOPE_H

typedef struct ScopeNode{

    int num;
    int nbchild;
    struct ScopeNode *child[100];
    struct ScopeNode *parent;
} ScopeNode;

ScopeNode *root;
int nextNum = 0;

ScopeNode* createNode(int num){
    int i = 0;
    ScopeNode *node = (ScopeNode *) malloc(sizeof(ScopeNode));
    node->num = num;
    node->nbchild = 0;
    for(i = 0; i < 100; i++)
        node->child[i] = NULL;
    node->parent = NULL;
    return node;
}

ScopeNode* findChild(ScopeNode * currentScope, int targetScope)
{
    if(currentScope!= NULL && targetScope == currentScope->num)
        return currentScope;

    int i;
    int found = 0;
    for(i = 0;i<currentScope->nbchild; i++){
        ScopeNode * res = findChild(currentScope->child[i],targetScope);
        if(res!=NULL){
            found = 1;
            return res;
        }
    }
    if(found==0) return NULL;
} 
void insertScope(int *curScope){


    ScopeNode * node = createNode(++nextNum);
    ScopeNode * ParentNode = findChild(root, *curScope);
    ParentNode->child[ParentNode->nbchild++] = node;
    node->parent = ParentNode; 


    *curScope = nextNum;
}

int findParentScope(int num)
{
    ScopeNode *Node = findChild(root, num);
    ScopeNode *ParentNode = Node->parent;
    return ParentNode->num;
}

void initScope()
{
    root = createNode(0);
}


#endif