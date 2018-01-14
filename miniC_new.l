%{
    int lookUpSymbolItem();
    void insertSymbolItem();

    const int symbolTableSize = 1000;
    typedef struct symbolItemStruct{
        char tokenValue[100];
        char tokenType[100];
        int lineNumber;
        struct symbolItemStruct* next;
    } symbolItem;
    symbolItem * symbolTable[1000];

    int lineNo = 1;
%}

keyword         char|int|float|short|long|unsigned|signed|main|while|for|break|case|if|else|continue|default|do|goto|return|void|struct|switch
number          [0-9]
letter          [a-zA-Z]
operator        [+-<>*=/%,.]


%%

#(.*)                               { printf("%-20s%20s\n","PREPROCESSOR", yytext); }

[\n]                                { lineNo++; }

[{]                                 { printf("%-20s%20s\n","LEFT BRACE", yytext); }
[}]                                 { printf("%-20s%20s\n", "RIGHT BRACE", yytext); }

[/][*]                              { printf("%-20s%20s\n", "OPEN COMMENT",yytext); }
[*][/]                              { printf("%-20s%20s\n", "CLOSE COMMENT",yytext); }

\"[^"\n]*["\n]                      { if(yytext[yyleng-1]!='"'){
                                        printf("Error : Quote unbalanced at line number %d\n",lineNo);
                                        lineNo++;
                                    }
                                    printf("%-20s%20s\n", "STRING", yytext);
                                    }

{keyword}                           { printf("%-20s%20s\n", "KEYWORD", yytext);
                                    // if(!lookUpSymbolItem(yytext))
                                    //     insertSymbolItem(yytext, "KEYWORD", lineNo);
                                    }

\/\/(.)*[\n]                        {lineNo++;}

[(]                                 { printf("%-20s%20s\n", "OPEN PARANTHESIS", yytext); }
[)]                                 { printf("%-20s%20s\n", "CLOSE PARANTHESIS", yytext); }

[\t ]                               { ; }

[;]                                 { printf("%-20s%20s\n", "SEMICOLON", yytext); }

{number}+                           { printf("%-20s%20s\n", "NUMBER", yytext); }

(_|{letter})({letter}|{number}|_)*  { printf("%-20s%20s\n", "IDENTIFIER", yytext);
                                      if(!lookUpSymbolItem(yytext))
                                        insertSymbolItem(yytext, "IDENTIFIER", lineNo);
                                    }

{operator}                          { printf("%-20s%20s\n", "OPERATOR", yytext); }

%%


int yywrap(){
  return 1;
}

void initSymbolTable(){
    int i;
    for(i = 0;i<symbolTableSize; i++)
        symbolTable[i] = NULL;
}

int hash(unsigned char *str)
{
    unsigned long hashVar = 5381;
    int c;

    while (c = *str++)
        hashVar = (((hashVar << 5) + hashVar) + c)%1000;

    return hashVar;
}

symbolItem* createSymbolItem(char *tokenValue, char *tokenType, int lineNumber){
    symbolItem *item = (symbolItem*)malloc(sizeof(symbolItem));
    strcpy(item->tokenValue, tokenValue);
    strcpy(item->tokenType, tokenType);
    item->lineNumber = lineNumber;
    item->next = NULL;

    return item;
}

void insertSymbolItem(char *tokenValue, char *tokenType, int lineNumber){
    int hashIndex = hash(tokenValue);

    symbolItem *item = createSymbolItem(tokenValue, tokenType, lineNumber);
    symbolItem * temp = symbolTable[hashIndex];
    while(temp!=NULL && temp->next!=NULL)
        temp = temp->next;

    if(temp == NULL)
        symbolTable[hashIndex] = item;
    else
        temp->next = item;
}

int lookUpSymbolItem(char * tokenValue){
    int hashIndex = hash(tokenValue);

    symbolItem * temp = symbolTable[hashIndex];
    while(temp!=NULL && strcmp(tokenValue, temp->tokenValue)!=0)
        temp=temp->next;

    if(temp==NULL) return 0;
    else return 1;
}

void printSymbolItem(symbolItem * item){
    printf("%-20s%10s%20d\n",item->tokenValue, item->tokenType, item->lineNumber);
}

void showSymbolTable(){
    int i;
    printf("\n\n%-20s%10s%20s\n","VALUE","TYPE","LINE NUMBER");
    printf("-----------------------------------------------------------------\n");

    for(int i=0;i<symbolTableSize;i++){
        symbolItem* temp = symbolTable[i];
        while(temp!=NULL){
            printSymbolItem(temp);
            temp=temp->next;
        }
    }
}

int main(){
    initSymbolTable();
    yyin = fopen("samp_input.c", "r");
    printf("\n\n%-20s%20s\n", "TOKEN VALUE", "TOKEN TYPE");
    printf("-----------------------------------------------------------------\n");
    yylex();

    showSymbolTable();
}

