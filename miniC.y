%{

#include <stdio.h>
#include <stdlib.h>
#include "symbolTable.h"
#include "scope.h"

#define DEBUGY 0

#if defined(DEBUGY) && DEBUGY > 0
        #define DEBUGY_PRINT(fmt, args...) fprintf(stderr, fmt, ##args)
#else
        #define DEBUGY_PRINT(fmt, args...) /* Don't do anything in release builds */
#endif


#define RED   "\x1B[31m"
#define RESET "\x1B[0m"
#define GRN   "\x1B[32m"
#define BLU   "\x1B[34m"


int yyparse (void);
int yylex();
void yyerror(const char * s);

extern FILE *yyin, *yyout;

extern char *yytext;
extern int lineNo;
extern int curScope;

char type[100];

void printUndecVarErr(int lineNo, char * s){
        printf(RED "Variable %s not declared at line %d\n" RESET, s,lineNo);
}

void printReDecError(int lineNo, char *s){
        printf(RED "Variable %s redeclared at line %d\n" RESET, s,lineNo);
}

int checkAncestors(char * s)
{
        //printf("%s\n", s);
        ScopeNode *node = findChild(root, curScope);
        while(node!=NULL)
        {
                //printf("%d\n", node->num);
                if(lookUpSymbolItem_scope(s,node->num))
                        return 1; 
                        
                node = node->parent;
        }
        return 0;
}

char pList[100];
int num;

%}


%token RETURN
%token SIGNED UNSIGNED LONG SHORT
%token SWITCH BREAK CONTINUE CASE DEFAULT STRUCT  
%token FOR WHILE DO
%token IF ELSE  
%token FLOATNUM STRING CHARCONST
%token INCLUDE
%token OPEN_PAR CLOSE_PAR

%union {
	char id[100];
        int num;
}
%token <id> ID
%token <id> INT
%token <id> CHAR
%token <id> FLOAT
%token <id> DOUBLE
%token <id> VOID
%token <num> NUM
%type <id> Type

%right '=' PAS MAS DAS SAS           
%left AND OR NOT PP MM
%left LE GE EQ NE LT GT                        // LE <= GE >= EQ == NE != LT < GT >
%left '+' '-' '*' '/' '%' '^' '&' '.'  
%start start

%% 
start:	FunctionDef
	| Declaration
        | Include
        | FunctionDef start
        | Declaration start
        | Include start
	;

IncludeStatement: '#' INCLUDE LT ID GT
                  | '#' INCLUDE LT ID '.' ID GT
                  ;
Include:   IncludeStatement
           ;

FunctionDef: Type ID OPEN_PAR FormalParamList CLOSE_PAR CompoundStatement       {
                                                                                        insertFunctionItem($2,"function",lineNo,curScope,0,pList);
                                                                                        strcpy(pList, "");
                                                                                }
             ;
FormalParamList: Type ID                                        {
                                                                        char temp[100];
                                                                        strcpy(type, $1);
                                                                        strcat(pList,strcat(temp," "));
                                                                        strcpy(temp, $2);
                                                                        strcat(pList,strcat(temp,", "));
                                                                        insertSymbolItem($2,type,lineNo,nextNum + 1,0);
                                                                }
                | Type '*' ID                                   {
                                                                        char temp[100];
                                                                        strcpy(type, $1);
                                                                        strcat(pList,strcat(temp," "));
                                                                        strcpy(temp, $3);
                                                                        strcat(pList,strcat(temp,", "));
                                                                        insertSymbolItem($3,type,lineNo,nextNum + 1,0);
                                                                }
                | Type FuncArrayNotation                            {DEBUGY_PRINT("FLIST Call 3\n");}
                | Type ID ',' FormalParamList                   {
                                                                        char temp[100];
                                                                        strcpy(type, $1);
                                                                        printf("%s %s\n", $1, $2);
                                                                        strcat(pList,strcat(temp," "));
                                                                        strcpy(temp, $2);
                                                                        strcat(pList,strcat(temp,", "));
                                                                        insertSymbolItem($2,type,lineNo,nextNum + 1,0);
                                                                }
                | Type '*' ID ',' FormalParamList               {
                                                                        char temp[100];
                                                                        strcpy(type, $1);
                                                                        strcat(pList,strcat(temp," "));
                                                                        strcpy(temp, $3);
                                                                        strcat(pList,strcat(temp,", "));
                                                                        insertSymbolItem($3,type,lineNo,nextNum + 1,0);
                                                                }
                | Type FuncArrayNotation ',' FormalParamList        {DEBUGY_PRINT("FLIST Call 6\n");}
                |
                ;


Declaration:  Type IDList ';'    {;}
        ;

Type: INT {strcpy(type,$1);strcpy($$,$1);}| FLOAT {strcpy(type,$1);strcpy($$,$1);}| VOID {strcpy(type,$1);strcpy($$,$1);}| CHAR {strcpy(type,$1);strcpy($$,$1);}| DOUBLE {strcpy(type,$1);strcpy($$,$1);}| 
        Modifiers INT {strcpy(type,$2);}| Modifiers FLOAT {strcpy(type,$2);}| Modifiers DOUBLE {strcpy(type,$2);}| Modifiers CHAR {strcpy(type,$2);}
        ;
Modifiers: SHORT | LONG | UNSIGNED | SIGNED
        ;

FuncArrayNotation: ID '[' ']'   {
                                        char temp[100];
                                        strcpy(temp, type);
                                        strcat(pList,strcat(temp," "));
                                        char ar[100] = "array -"; 
                                        strcat(ar, type);
                                        strcpy(temp, $1);
                                        strcat(pList,strcat(temp,"[], "));
                                        insertSymbolItem($1,ar,lineNo,nextNum + 1,0);
                                }
            | ID '[' NUM ']'   { 
                                        char temp[100];
                                        strcpy(temp, type);
                                        strcat(pList,strcat(temp," "));
                                        char ar[100] = "array -"; 
                                        strcat(ar, type);
                                        strcat(pList,strcat(temp,", "));
                                        strcpy(temp, $1);
                                        //strcat(pList,strcat(itoa($3),"], "));
                                        insertSymbolItem($1,ar,lineNo,nextNum + 1,0);
                                }
            ;

DefArrayNotation: ID '[' ']'   {
                                if(lookUpSymbolItem_scope($1, curScope))
                                        printReDecError(lineNo, $1);
                                else{
                                        char ar[100] = "arr -"; 
                                        insertSymbolItem($1,type,lineNo,curScope,0);
                                    }
                                }
            | ID '[' Expr ']' {
                                if(lookUpSymbolItem_scope($1, curScope))
                                        printReDecError(lineNo, $1);
                                else{
                                        char ar[100] = "arr -";
                                        strcat(ar, type);
                                        insertSymbolItem($1,type,lineNo,curScope,0);
                                    }
                                }
            ;
ArrayNotation: ID '[' ']'       {if(!checkAncestors($1))
                                        printUndecVarErr(lineNo, $1);
                                }
            | ID '[' Expr ']'   {if(!checkAncestors($1))
                                        printUndecVarErr(lineNo, $1);
                                }
            ;


IDList: DefArrayNotation
        | ID ',' IDList                        {
                                                if(lookUpSymbolItem_scope($1, curScope))
                                                        printReDecError(lineNo, $1);
                                                else
                                                        insertSymbolItem($1,type,lineNo,curScope,0);
                                               }
        | '*' ID ',' IDList                    {
                                                if(lookUpSymbolItem_scope($2, curScope))
                                                        printReDecError(lineNo, $2);
                                                else
                                                        insertSymbolItem($2,type,lineNo,curScope,0);
                                               }
        | DefArrayNotation ',' IDList 
        | ID                                   {
                                                if(lookUpSymbolItem_scope($1,curScope))
                                                        printReDecError(lineNo, $1);
                                                else
                                                        insertSymbolItem($1,type,lineNo,curScope,0);
                                               }
        | '*' ID                               {
                                                if(lookUpSymbolItem_scope($2,curScope))
                                                        printReDecError(lineNo, $2);
                                                else
                                                        insertSymbolItem($2,type,lineNo,curScope,0);
                                               }
        | DefineAssign ',' IDList
        | DefineAssign 
        ;

DefineAssign: ID '=' Expr                      {
                                                if(lookUpSymbolItem_scope($1,curScope))
                                                        printReDecError(lineNo, $1);
                                                else
                                                        insertSymbolItem($1,type,lineNo,curScope,0);
                                               }
            | ID PAS Expr                      {
                                                if(lookUpSymbolItem_scope($1,curScope))
                                                        printReDecError(lineNo, $1);
                                                else
                                                        insertSymbolItem($1,type,lineNo,curScope,0);
                                               }       
            | ID SAS Expr                      {
                                                if(lookUpSymbolItem_scope($1,curScope))
                                                        printReDecError(lineNo, $1);
                                                else
                                                        insertSymbolItem($1,type,lineNo,curScope,0);
                                               }  
            | ID MAS Expr                      {
                                                if(lookUpSymbolItem_scope($1,curScope))
                                                        printReDecError(lineNo, $1);
                                                else
                                                        insertSymbolItem($1,type,lineNo,curScope,0);
                                               }  
            | ID DAS Expr                      {
                                                if(lookUpSymbolItem_scope($1,curScope))
                                                        printReDecError(lineNo, $1);
                                                else
                                                        insertSymbolItem($1,type,lineNo,curScope,0);
                                               }  
            | '*' ID '=' Expr                  {
                                                if(lookUpSymbolItem_scope($2,curScope))
                                                        printReDecError(lineNo, $2);
                                                else
                                                        insertSymbolItem($2,type,lineNo,curScope,0);
                                               }           
            | '*' ID PAS Expr                  {
                                                if(lookUpSymbolItem_scope($2,curScope))
                                                        printReDecError(lineNo, $2);
                                                else
                                                        insertSymbolItem($2,type,lineNo,curScope,0);
                                               }  
            | '*' ID SAS Expr                  {
                                                if(lookUpSymbolItem_scope($2,curScope))
                                                        printReDecError(lineNo, $2);
                                                else
                                                        insertSymbolItem($2,type,lineNo,curScope,0);
                                               }  
            | '*' ID MAS Expr                  {
                                                if(lookUpSymbolItem_scope($2,curScope))
                                                        printReDecError(lineNo, $2);
                                                else
                                                        insertSymbolItem($2,type,lineNo,curScope,0);
                                               }  
            | '*' ID DAS Expr                  {
                                                if(lookUpSymbolItem_scope($2,curScope))
                                                        printReDecError(lineNo, $2);
                                                else
                                                        insertSymbolItem($2,type,lineNo,curScope,0);
                                               }
            | DefArrayNotation '=' Expr                   
            | DefArrayNotation PAS Expr  
            | DefArrayNotation SAS Expr  
            | DefArrayNotation MAS Expr  
            | DefArrayNotation DAS Expr
            ;


ParamList: Expr
        | Expr ',' ParamList
        | 
        ;

Assignment: ID '=' Expr                   {if(!checkAncestors($1)){
                                                printUndecVarErr(lineNo, $1);
                                          }}
            | ID PAS Expr                 {if(!checkAncestors($1)){
                                                printUndecVarErr(lineNo, $1);
                                          }}      
            | ID SAS Expr                 {if(!checkAncestors($1)){
                                                printUndecVarErr(lineNo, $1);
                                          }}  
            | ID MAS Expr                 {if(!checkAncestors($1)){
                                                printUndecVarErr(lineNo, $1);
                                          }}
            | ID DAS Expr                 {if(!checkAncestors($1)){
                                                printUndecVarErr(lineNo, $1);
                                          }}
            | '*' ID '=' Expr             {if(!checkAncestors($2)){
                                                printUndecVarErr(lineNo, $2);
                                          }}
            | '*' ID PAS Expr             {if(!checkAncestors($2)){
                                                printUndecVarErr(lineNo, $2);
                                          }} 
            | '*' ID SAS Expr             {if(!checkAncestors($2)){
                                                printUndecVarErr(lineNo, $2);
                                          }}
            | '*' ID MAS Expr             {if(!checkAncestors($2)){
                                                printUndecVarErr(lineNo, $2);
                                          }}
            | '*' ID DAS Expr             {if(!checkAncestors($2)){
                                                printUndecVarErr(lineNo, $2);
                                          }}
            | ArrayNotation '=' Expr                   
            | ArrayNotation PAS Expr  
            | ArrayNotation SAS Expr  
            | ArrayNotation MAS Expr  
            | ArrayNotation DAS Expr
            | Primary   
            ;

Expr: Logical_Expr
      ;


Logical_Expr: Relational_Expr
              | Logical_Expr AND Relational_Expr
              | Logical_Expr OR Relational_Expr
              | NOT Relational_Expr 
              ;

Relational_Expr: Additive_Expr
                 | Relational_Expr GT Additive_Expr
                 | Relational_Expr LT Additive_Expr
                 | Relational_Expr GE Additive_Expr
                 | Relational_Expr LE Additive_Expr
                 | Relational_Expr EQ Additive_Expr
                 | Relational_Expr NE Additive_Expr
                 ;


Additive_Expr: Multiplicative_Expr
               | Additive_Expr '+' Multiplicative_Expr
               | Additive_Expr '-' Multiplicative_Expr
               ;
Multiplicative_Expr: Primary
                     | Multiplicative_Expr '*' Primary
                     | Multiplicative_Expr '/' Primary
                     | Multiplicative_Expr '%' Primary
                     ;
Primary: OPEN_PAR Expr CLOSE_PAR
         | NUM                          {num = $1;}
         | FLOATNUM | CHARCONST | STRING 
         | ID                           {if(!checkAncestors($1)){
                                                printUndecVarErr(lineNo, $1);
                                        }}
         | '*' ID                       {if(!checkAncestors($2)){
                                                printUndecVarErr(lineNo, $2);
                                        }}
         | '&' ID                       {if(!checkAncestors($2)){
                                                printUndecVarErr(lineNo, $2);
                                        }}
         | '-' Primary
         | '+' Primary
         | ArrayNotation
         | FunctionCall
         | PP ID                        {if(!checkAncestors($2)){
                                                printUndecVarErr(lineNo, $2);
                                        }}
         | ID PP                        {if(!checkAncestors($1)){
                                                printUndecVarErr(lineNo, $1);
                                        }}
         | MM ID                        {if(!checkAncestors($2)){
                                                printUndecVarErr(lineNo, $2);
                                        }}
         | ID MM                        {if(!checkAncestors($1)){
                                                printUndecVarErr(lineNo, $1);
                                        }}
         ;

CompoundStatement: '{' StatementList '}'
	;
StatementList: Statement StatementList
               |
               ;

Statement: WhileStatement 
	| Declaration   
	| ForStatement  
	| IfStatement  
        | Assignment    ';'
        | ReturnStatement    
        | DoWhileStatement      
        | BREAK ';'
        | CONTINUE ';'                    
	| ';'
        ; 
ReturnStatement: RETURN Expr ';'   {DEBUGY_PRINT("Return Statement Call\n");}
                 ;

WhileStatement: WHILE OPEN_PAR Expr CLOSE_PAR Statement                                                        
                | WHILE OPEN_PAR Expr CLOSE_PAR CompoundStatement
                ;

DoWhileStatement: DO CompoundStatement WHILE OPEN_PAR Expr CLOSE_PAR ';'
                  ;


ForStatement: FOR OPEN_PAR Assignment ';' Expr ';' Assignment CLOSE_PAR Statement 
              | FOR OPEN_PAR Assignment ';' Expr ';' Assignment CLOSE_PAR CompoundStatement 
              ;

IfStatement: IF OPEN_PAR Expr CLOSE_PAR Statement ElseStatement
             | IF OPEN_PAR Expr CLOSE_PAR CompoundStatement ElseStatement
             ;

ElseStatement: ELSE CompoundStatement
               | ELSE Statement
               |
               ;

FunctionCall: ID OPEN_PAR ParamList CLOSE_PAR           {DEBUGY_PRINT("Function Call\n");} 
                ;

%%
#include<ctype.h>
int count=0;

int main(int argc, char *argv[])
{
        initScope();
        yyin = fopen(argv[1], "r");
	
        if(!yyparse())
                printf("\nParsing complete\n");
        else
                printf(RED "\nParsing failed\n" RESET);

        fclose(yyin);

        showSymbolTable();
        return 0;
}
         
void yyerror(const char *s) {
	printf(RED "%d : %s %s\n" RESET, lineNo, s, yytext );
}