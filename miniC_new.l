%{
    #define RED   "\x1B[31m"
    #define RESET "\x1B[0m"
    #define GRN   "\x1B[32m"
    #define BLU   "\x1B[34m"

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
    symbolItem * constantTable[1000];

    int lineNo = 1;
    int comment = 0;
%}

keyword         char|int|float|short|long|unsigned|signed|main|while|for|break|case|if|else|continue|default|do|return|void|struct|switch
number          [0-9]
letter          [a-zA-Z]
operator        [+-<>*=/!%^&.]
function        (_|{letter})({letter}|{number}|_)*"()"


%%
\/\/(.)*[\n]                        {lineNo++;}

[/][*]                              { printf("%-20s%20s%20d\n", "OPEN COMMENT",yytext, lineNo); comment++; }
[*][/]                              { printf("%-20s%20s%20d\n", "CLOSE COMMENT",yytext, lineNo); comment--; }

{function}                          { if(!comment) printf("%-20s%20s%20d\n", "FUNCTION", yytext, lineNo); }

#(.*)                               { if(!comment) printf("%-20s%20s%20d\n","PREPROCESSOR", yytext, lineNo); }

[\n]                                { lineNo++; }

[{]                                 { if(!comment) printf("%-20s%20s%20d\n","LEFT BRACE", yytext, lineNo); }
[}]                                 { if(!comment) printf("%-20s%20s%20d\n", "RIGHT BRACE", yytext, lineNo); }

\"[^"\n]*["\n]                      { if(!comment) {
                                        if(yytext[yyleng-1]!='"'){
                                            printf(RED "Error : Quote unbalanced at line number %d\n" RESET,lineNo);
                                            lineNo++;
                                        }
                                        printf("%-20s%20s%20d\n", "STRING", yytext, lineNo);
                                        insertSymbolItem(yytext, "STRING", lineNo, 1);
                                      }
                                    }

{keyword}                           { if(!comment){
                                        printf("%-20s%20s%20d\n", "KEYWORD", yytext, lineNo);
                                        if(!lookUpSymbolItem(yytext))
                                            insertSymbolItem(yytext, "KEYWORD", lineNo, 0);
                                      }
                                    }

[(]                                 { if(!comment) printf("%-20s%20s%20d\n", "OPEN PARANTHESIS", yytext, lineNo); }
[)]                                 { if(!comment) printf("%-20s%20s%20d\n", "CLOSE PARANTHESIS", yytext, lineNo); }
[\[\]]                              { if(!comment) printf("%-20s%20s%20d\n", "SQUARE BRACKETS", yytext, lineNo); }
[,]                                 { if(!comment) printf("%-20s%20s%20d\n", "COMMA", yytext, lineNo); }


[\t ]                               { ; }

[;]                                 { if(!comment) printf("%-20s%20s%20d\n", "SEMICOLON", yytext, lineNo); }

\'.\'                               { if(!comment) {
                                        printf("%-20s%20s%20d\n", "CHARACTER", yytext, lineNo); 
                                        insertSymbolItem(yytext, "CHARACTER", lineNo, 1);
                                        }
                                    }
\[{number}*\]                       { if(!comment) printf("%-20s%20s%20d\n", "ARRAY SUBSCRIPT", yytext, lineNo); }

{number}+(\.{number}+)?e{number}+    { if(!comment) {
                                        printf("%-20s%20s%20d\n", "FLOAT EXP FORM", yytext, lineNo); 
                                        insertSymbolItem(yytext, "FLOAT", lineNo, 1);
                                        }
                                    } 

{number}+\.{number}+                { if(!comment) {
                                        printf("%-20s%20s%20d\n", "FLOAT NUMBER", yytext, lineNo); 
                                        insertSymbolItem(yytext, "FLOAT", lineNo, 1);
                                        }
                                    } 


{number}+                           { if(!comment) {
                                        printf("%-20s%20s%20d\n", "NUMBER", yytext, lineNo); 
                                        insertSymbolItem(yytext, "INTEGER", lineNo, 1);
                                        }
                                    }    

(_|{letter})({letter}|{number}|_)*  { if(!comment){
                                        printf("%-20s%20s%20d\n", "IDENTIFIER", yytext, lineNo);
                                        if(!lookUpSymbolItem(yytext))
                                            insertSymbolItem(yytext, "IDENTIFIER", lineNo, 0);
                                            
                                      }
                                    }
\(_|{letter})({letter}|{number}|_)*  { if(!comment){
                                        printf("%-20s%20s%20d\n", "IDENTIFIER", yytext, lineNo);
                                        if(!lookUpSymbolItem(yytext))
                                            insertSymbolItem(yytext, "IDENTIFIER", lineNo, 0);
                                            
                                      }
                                    }

{operator}                          { if(!comment) printf("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); }

{number}({letter}|{number}|_)+      { if(!comment) printf(RED "Error : Invalid Token %s at Line %d\n" RESET, yytext, lineNo); }

.                                   { if(!comment) printf(RED "Error : Invalid Token %s at Line %d\n" RESET, yytext, lineNo); }

%%


int yywrap(){
  return 1;
}

void initSymbolTable(){
    int i;
    for(i = 0;i<symbolTableSize; i++)
        symbolTable[i] = NULL;

    for(i = 0;i<symbolTableSize; i++)
        constantTable[i] = NULL;
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

void insertSymbolItem(char *tokenValue, char *tokenType, int lineNumber, int tableno){
    int hashIndex = hash(tokenValue);

    symbolItem *item = createSymbolItem(tokenValue, tokenType, lineNumber);

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
    printf("\n-----------------------------------------------------------------\n");
    printf(BLU "%-20s%10s%24s\n","VALUE","TYPE","LINE NUMBER" RESET);
    printf("-----------------------------------------------------------------\n");

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
    printf("\n-----------------------------------------------------------------\n");
    printf(BLU "%-20s%10s%24s\n","VALUE","TYPE","LINE NUMBER" RESET);
    printf("-----------------------------------------------------------------\n");

    for(int i=0;i<symbolTableSize;i++){
        symbolItem* temp = constantTable[i];
        while(temp!=NULL){
            printSymbolItem(temp);
            temp=temp->next;
        }
    }
}

int main(int argc, char** argv){
    if(argc < 2){
        printf(RED "Pass input file as command line argument\n" RESET);
        exit(0);
    }
    initSymbolTable();
    yyin = fopen(argv[1], "r");
    printf("\n\n-----------------------------------------------------------------\n");
    printf(BLU "%-20s%20s%24s\n", "TOKEN VALUE", "TOKEN TYPE", "LINE NUMBER" RESET);
    printf("-----------------------------------------------------------------\n");
    yylex();

    if(comment)
        printf(RED "Error : Error in parsing comments" RESET);

    printf(GRN "\n\nSYMBOL TABLE" RESET);
    showSymbolTable();
    printf(GRN "\n\nCONSTANT TABLE" RESET);
    showConstantTable();
    printf("\n\n");
}

