%{
    #define RED   "\x1B[31m"
    #define RESET "\x1B[0m"

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
    int comment = 0;
%}

keyword         char|int|float|short|long|unsigned|signed|main|while|for|break|case|if|else|continue|default|do|goto|return|void|struct|switch
number          [0-9]
letter          [a-zA-Z]
operator        [+-<>*=/%,.]
function        (_|{letter})({letter}|{number}|_)*"()"


%%
\/\/(.)*[\n]                        {lineNo++;}

[/][*]                              { printf("%-20s%20s%20d\n", "OPEN COMMENT",yytext, lineNo); comment++; }
[*][/]                              { printf("%-20s%20s%20d\n", "CLOSE COMMENT",yytext, lineNo); comment--; }

{function}                          { printf("%-20s%20s%20d\n", "FUNCTION", yytext, lineNo); }

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
                                      }
                                    }

{keyword}                           { if(!comment){
                                        printf("%-20s%20s%20d\n", "KEYWORD", yytext, lineNo);
                                        // if(!lookUpSymbolItem(yytext))
                                        //     insertSymbolItem(yytext, "KEYWORD", lineNo);
                                      }
                                    }

[(]                                 { if(!comment) printf("%-20s%20s%20d\n", "OPEN PARANTHESIS", yytext, lineNo); }
[)]                                 { if(!comment) printf("%-20s%20s%20d\n", "CLOSE PARANTHESIS", yytext, lineNo); }

[\t ]                               { ; }

[;]                                 { if(!comment) printf("%-20s%20s%20d\n", "SEMICOLON", yytext, lineNo); }

{number}+                           { if(!comment) printf("%-20s%20s%20d\n", "NUMBER", yytext, lineNo); }

(_|{letter})({letter}|{number}|_)*  { if(!comment){
                                        printf("%-20s%20s%20d\n", "IDENTIFIER", yytext, lineNo);
                                        if(!lookUpSymbolItem(yytext))
                                            insertSymbolItem(yytext, "IDENTIFIER", lineNo);
                                      }
                                    }

{operator}                          { if(!comment) printf("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); }

.                                   { if(!comment) printf(RED "Error : Invalid Token %s at Line %d\n" RESET, yytext, lineNo); }

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

int main(int argc, char** argv){
    initSymbolTable();
    yyin = fopen("samp_input.c", "r");
    printf("\n\n%-20s%20s%20s\n", "TOKEN VALUE", "TOKEN TYPE", "LINE NUMBER");
    printf("-----------------------------------------------------------------\n");
    yylex();

    if(comment)
        printf(RED "Error : Error in parsing comments" RESET);

    showSymbolTable();
    printf("\n\n");
}

