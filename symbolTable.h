#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include <string.h>
    #define DEBUG 1

    #if defined(DEBUG) && DEBUG > 0
        #define DEBUG_PRINT(fmt, args...) fprintf(stderr, fmt, ##args)
    #else
        #define DEBUG_PRINT(fmt, args...) /* Don't do anything in release builds */
    #endif


#define RED   "\x1B[31m"
    #define RESET "\x1B[0m"
    #define GRN   "\x1B[32m"
    #define BLU   "\x1B[34m"

const int symbolTableSize = 1000;
    typedef struct symbolItemStruct{
        char tokenValue[100];
        char tokenType[100];
        int lineNumber;
        int scope;
        int arrayDim;
        char paramList[100];
        int paramCount;
        struct symbolItemStruct* next;
    } symbolItem;
    symbolItem * symbolTable[1000];
    symbolItem * constantTable[1000];


void initSymbolTable(){
    int i;
    for(i = 0;i<symbolTableSize; i++)
        symbolTable[i] = NULL;

    for(i = 0;i<symbolTableSize; i++)
        constantTable[i] = NULL;
}

int hash(char *str)
{
    unsigned long hashVar = 5381;
    int c;

    while (c = *str++)
        hashVar = (((hashVar << 5) + hashVar) + c)%1000;

    return hashVar;
}

symbolItem* createSymbolItem(char *tokenValue, char *tokenType, int lineNumber, int scope){
    symbolItem *item = (symbolItem*)malloc(sizeof(symbolItem));
    strcpy(item->tokenValue, tokenValue);
    strcpy(item->tokenType, tokenType);
    item->lineNumber = lineNumber;
    item->scope = scope;
    item->next = NULL;
    item->arrayDim = -1;
    item->paramCount = 0;

    return item;
}

symbolItem* lookUpSymbolItem_scope(char * tokenValue, int scope){
    if(scope == -1){
    int hashIndex = hash(tokenValue);
    symbolItem * temp = symbolTable[hashIndex];
    while(temp!=NULL && strcmp(tokenValue, temp->tokenValue)!=0)
        temp=temp->next;

    return temp;
    }

    else{
        int hashIndex = hash(tokenValue);
        symbolItem * temp = symbolTable[hashIndex];
        while(temp!=NULL && (strcmp(tokenValue, temp->tokenValue)!=0 || temp->scope !=scope))
            temp=temp->next;

    return temp;
    }
}

symbolItem* lookUpSymbolItem(char * tokenValue){
    
    int hashIndex = hash(tokenValue);
    symbolItem * temp = symbolTable[hashIndex];
    while(temp!=NULL && strcmp(tokenValue, temp->tokenValue)!=0)
        temp=temp->next;

    return temp;
}


void insertSymbolItem(char *tokenValue, char *tokenType, int lineNumber, int scope, int tableno){
    
    int hashIndex = hash(tokenValue);

    symbolItem *item = createSymbolItem(tokenValue, tokenType, lineNumber, scope);

    if(tableno == 0)
    {
        symbolItem * temp = symbolTable[hashIndex];
        while(temp!=NULL && temp->next!=NULL)
            temp = temp->next;

        if(temp == NULL)
            symbolTable[hashIndex] = item;
        else
            temp->next = item;
    }

    else
    {
        symbolItem * temp = constantTable[hashIndex];
        while(temp!=NULL && temp->next!=NULL)
            temp = temp->next;

        if(temp == NULL)
            constantTable[hashIndex] = item;
        else
            temp->next = item;
    }
}

void insertFunctionItem(char *tokenValue, char *tokenType, int lineNumber, int scope, int tableno, char *pList, int pCount){
    
    int hashIndex = hash(tokenValue);

    symbolItem *item = createSymbolItem(tokenValue, tokenType, lineNumber, scope);
    strcpy(item->paramList, pList);
    item->paramCount = pCount;

    if(tableno == 0)
    {
        symbolItem * temp = symbolTable[hashIndex];
        while(temp!=NULL && temp->next!=NULL)
            temp = temp->next;

        if(temp == NULL)
            symbolTable[hashIndex] = item;
        else
            temp->next = item;
    }

    else
    {
        symbolItem * temp = constantTable[hashIndex];
        while(temp!=NULL && temp->next!=NULL)
            temp = temp->next;

        if(temp == NULL)
            constantTable[hashIndex] = item;
        else
            temp->next = item;
    }
}

void insertArrayItem(char *tokenValue, char *tokenType, int lineNumber, int scope, int tableno, int num){
    
    int hashIndex = hash(tokenValue);

    symbolItem *item = createSymbolItem(tokenValue, tokenType, lineNumber, scope);
    item->arrayDim = num;

    if(tableno == 0)
    {
        symbolItem * temp = symbolTable[hashIndex];
        while(temp!=NULL && temp->next!=NULL)
            temp = temp->next;

        if(temp == NULL)
            symbolTable[hashIndex] = item;
        else
            temp->next = item;
    }

    else
    {
        symbolItem * temp = constantTable[hashIndex];
        while(temp!=NULL && temp->next!=NULL)
            temp = temp->next;

        if(temp == NULL)
            constantTable[hashIndex] = item;
        else
            temp->next = item;
    }
}

void printSymbolItem(symbolItem * item){
    DEBUG_PRINT("%-20s%10s%20d%20d%40s%20d\n",item->tokenValue, item->tokenType, item->lineNumber, item->scope, item->paramList, item->arrayDim);
}

void showSymbolTable(){
    int i;
    DEBUG_PRINT("\n--------------------------------------------------------------------------------------------------------------------------------------\n");
    DEBUG_PRINT(BLU "%-20s%10s%24s%20s%40s%20s\n","VALUE","TYPE","LINE NUMBER", "SCOPE","PARAMLIST","ARRAYDIM" RESET);
    DEBUG_PRINT("--------------------------------------------------------------------------------------------------------------------------------------\n");

    for(int i=0;i<symbolTableSize;i++){
        symbolItem* temp = symbolTable[i];
        while(temp!=NULL){
            printSymbolItem(temp);
            temp=temp->next;
        }
    }
}

void showConstantTable(){
    int i;
    DEBUG_PRINT("\n-----------------------------------------------------------------\n");
    DEBUG_PRINT(BLU "%-20s%10s%24s\n","VALUE","TYPE","LINE NUMBER" RESET);
    DEBUG_PRINT("-----------------------------------------------------------------\n");

    for(int i=0;i<symbolTableSize;i++){
        symbolItem* temp = constantTable[i];
        while(temp!=NULL){
            printSymbolItem(temp);
            temp=temp->next;
        }
    }
}

#endif