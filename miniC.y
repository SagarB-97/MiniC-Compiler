%{
/*
        TO DO
- Convert SymbolItem.paramList to symbolitem array type for better access. 
- Compare return type with function type
- Check if id is array but used as a normal variable and vice versa.
- Expression should have variables of the same type. both lhs and rhs
- void variables shouldn't be allowed (Low Priority)
- Type checking in function call param list
- redeclaration of function def variables (low pri)
- better printing
*/

/*
        Done
- Scope eval
- Undeclared variable checking
- Undeclared function checking
- Redeclaration checking
- Illegal array size checking
- Wrong parameter count in function call detected
- Counting number of params
- Making list of params of a function
- array support
- had to add different arraynotation due to differing usage
- Checks if array size < 0
- some more stuff

*/
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
void printIllArrayError(int lineNo, char *s, int Dim){
        printf(RED "Array %s of illegal dimensions %d used at line %d\n" RESET, s, Dim, lineNo);
}
void printRetTypeError(int lineNo, char *ret, char *typ, char *name){
        printf(RED "Wrong return type of %s for Function %s of type %s at line %d\n" RESET, ret, typ, name, lineNo);
}
void printWrongParamCountError(int lineNo, int wrong, int actual, char *s){
        printf(RED "%s expects %d parameters and not %d parameters at line %d\n" RESET, s, actual, wrong, lineNo);
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
int num = -1;
char returnType[100];
int pCount = 0;

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
                                                                                        //if(strcmp(returnType,$1)!=0)
                                                                                        //        printRetTypeError(lineNo, returnType, $1, $2);
                                                                                        //else{
                                                                                                strcpy(returnType, "");
                                                                                                char ftype[100] = "func-";
                                                                                                strcat(ftype, $1);
                                                                                                printf("%d - ParamCount\n", pCount);
                                                                                                insertFunctionItem($2,ftype,lineNo,curScope,0,pList, pCount);
                                                                                                strcpy(pList, "");
                                                                                                pCount = 0;
                                                                                        //}
                                                                                }
             ;
FormalParamList: Type ID                                        {       
                                                                        pCount++;
                                                                        char temp[100];
                                                                        strcpy(temp, $1);
                                                                        strcat(pList,strcat(temp," "));
                                                                        strcpy(temp, $2);
                                                                        strcat(pList,strcat(temp,", "));
                                                                        insertSymbolItem($2,type,lineNo,nextNum + 1,0);
                                                                }
                | Type '*' ID                                   {
                                                                        pCount++;
                                                                        char temp[100];
                                                                        strcpy(temp, $1);
                                                                        strcat(pList,strcat(temp," "));
                                                                        strcpy(temp, $3);
                                                                        strcat(pList,strcat(temp,", "));
                                                                        insertSymbolItem($3,type,lineNo,nextNum + 1,0);
                                                                }
                | Type FuncArrayNotation                            {DEBUGY_PRINT("FLIST Call 3\n");}
                | Type ID ',' FormalParamList                   {       
                                                                        pCount++;
                                                                        char temp[100];
                                                                        strcpy(temp, $1);
                                                                        printf("%s %s\n", $1, $2);
                                                                        strcat(pList,strcat(temp," "));
                                                                        strcpy(temp, $2);
                                                                        strcat(pList,strcat(temp,", "));
                                                                        insertSymbolItem($2,type,lineNo,nextNum + 1,0);
                                                                }
                | Type '*' ID ',' FormalParamList               {
                                                                        pCount++;
                                                                        char temp[100];
                                                                        strcpy(temp, $1);
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

Type:   INT {strcpy(type,$1);strcpy($$,$1);}| FLOAT {strcpy(type,$1);strcpy($$,$1);}| VOID {strcpy(type,$1);strcpy($$,$1);}| CHAR {strcpy(type,$1);strcpy($$,$1);}| DOUBLE {strcpy(type,$1);strcpy($$,$1);}| 
        Modifiers INT {strcpy(type,$2);}| Modifiers FLOAT {strcpy(type,$2);}| Modifiers DOUBLE {strcpy(type,$2);}| Modifiers CHAR {strcpy(type,$2);}
        ;
Modifiers: SHORT | LONG | UNSIGNED | SIGNED
        ;

FuncArrayNotation: ID '[' ']'   {
                                        pCount++;
                                        char temp[100];
                                        strcpy(temp, type);
                                        strcat(pList,strcat(temp," "));
                                        char ar[100] = "arr -"; 
                                        strcat(ar, type);
                                        strcpy(temp, $1);
                                        strcat(pList,strcat(temp,"[], "));
                                        insertArrayItem($1,ar,lineNo,nextNum + 1,0,0);
                                }
            | ID '[' Expr ']'   {       if(num<=0)
                                                printIllArrayError(lineNo,$1,num);
                                        else{
                                                pCount++;
                                                char temp[100];
                                                strcpy(temp, type);
                                                strcat(pList,strcat(temp," "));
                                                char ar[100] = "arr -"; 
                                                strcat(ar, type);
                                                strcpy(temp, $1);
                                                strcat(pList,strcat(temp,"[], "));
                                                insertArrayItem($1,ar,lineNo,nextNum + 1,0,num);
                                        }    
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
                                else if(num<=0)
                                        printIllArrayError(lineNo,$1,num);
                                else{
                                        char ar[100] = "arr -";
                                        strcat(ar, type);
                                        insertArrayItem($1,type,lineNo,curScope,0,num);
                                    }
                                }
            ;
ArrayNotation: ID '[' Expr ']'   {if(!checkAncestors($1))
                                        printUndecVarErr(lineNo, $1);
                                  else if(num<=0)
                                        printIllArrayError(lineNo,$1,num);
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


ParamList: Expr                 {pCount++;}
        | Expr ',' ParamList    {pCount++;}
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
         | '-' Primary                  {num = -num;}
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
ReturnStatement: RETURN Expr ';'   
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

FunctionCall: ID OPEN_PAR ParamList CLOSE_PAR   {
                                                 if(!checkAncestors($1))
                                                       printUndecVarErr(lineNo, $1);
                                                 else if(pCount!=(lookUpSymbolItem($1))->paramCount)
                                                        {
                                                                printWrongParamCountError(lineNo,pCount,(lookUpSymbolItem($1))->paramCount, $1);
                                                                pCount = 0;
                                                        }
                                                 pCount = 0;
                                                }
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