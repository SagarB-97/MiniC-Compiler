%{
/*
        TO DO
- Check if id is array but used as a normal variable and vice versa. --
- void variables shouldn't be allowed (Low Priority) --
- Type checking in function call param list 
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

int isHigherPri(char * type1, char * type2){
        int type1_pri, type2_pri;

        if(strcmp(type1,"char")==0) type1_pri = 1;
        else if(strcmp(type1,"int")==0) type1_pri = 2;
        else if(strcmp(type1,"float")==0) type1_pri = 3;

        if(strcmp(type2,"char")==0) type2_pri = 1;
        else if(strcmp(type2,"int")==0) type2_pri = 2;
        else if(strcmp(type2,"float")==0) type2_pri = 3;

        return type1_pri>type2_pri;
}

void printUndecVarErr(int lineNo, char * s){
        printf(RED "Variable %s not declared at line %d\n" RESET, s,lineNo);
}
void printWrongIDUsageError(int lineNo, char * id){
        printf(RED "%s at Line %d is Array. No Subscript given\n" RESET, id,lineNo);
}
void printWrongArrayUsageError(int lineNo, char * id){
        printf(RED "%s at Line %d is not Array\n" RESET, id,lineNo);
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
void printMismatchError(int lineNo, char *lhsType, char *rhsType){
        printf(RED "Error : Type Mismatch in expression at line %d. LHS : %s, RHS : %s\n" RESET, lineNo, lhsType, rhsType);
}
void printVoidVariableError(int lineNo){
        printf(RED "Error : Line - %d. void variables are not allowed\n" RESET, lineNo);
}
void printVoidFunctionReturningError(int lineNo, char *returnType){
        printf(RED "Void function at line %d returning %s" RESET, lineNo, returnType);
}
void printWrongParamError(int lineNo, char * fnName, char expectedParams[100][100], char gotParams[100][100], int count){
        printf(RED "Wrong parameters passed to function %s at line %d\n" RESET,fnName,lineNo);

        int i,j;        
        for(i=0,j=count-1; i<j;i++,j--){
                char temp[100];
                strcpy(temp,expectedParams[j]);
                strcpy(expectedParams[j],expectedParams[i]);
                strcpy(expectedParams[i],temp);
        }

        for(i=0,j=count-1; i<j;i++,j--){
                char temp[100];
                strcpy(temp,gotParams[j]);
                strcpy(gotParams[j],gotParams[i]);
                strcpy(gotParams[i],temp);
        }
        printf(RED "Expected : ");
        
        printf("(");
        for(i=0;i<count;i++){
                printf("%s,",expectedParams[i]);
        }
        printf(")");

        printf("\nGot : ");
        
        printf("(");
        for(i=0;i<count;i++){
                printf("%s,",gotParams[i]);
        }
        printf(")\n" RESET);
}
void printWrongArraySubscriptError(int lineNo, char * id){
        printf(RED "Wrong array subscript at line %d for %s\n" RESET, lineNo, id);
}

symbolItem* checkAncestors(char * s)
{
        //printf("%s\n", s);
        ScopeNode *node = findChild(root, curScope);
        while(node!=NULL)
        {
                //printf("%d\n", node->num);
                if(lookUpSymbolItem_scope(s,node->num))
                        return lookUpSymbolItem_scope(s,node->num); 
                        
                node = node->parent;
        }
        return NULL;
}

char pList[100];
int num = -1;
char returnType[100] = "void";

char params[100][100];
int pCount = 0;

void addToParamList(char *paramType, int position){
        strcpy(params[position],paramType);
}
int isCorrectParams(char params[][100], char * list, char * fnName){
        int i,j;
        // for(i=0,j=pCount-1; i<j;i++,j--){
        //         char temp[100];
        //         strcpy(temp,params[j]);
        //         strcpy(params[j],params[i]);
        //         strcpy(params[i],temp);
        // }
        i=0;
        char thisList[100][100];
        int l = 0;
        while(list[i]!='\0'){
                int k=0;
                char temp[100];
                while(list[i]!=' ' && list[i]!='\0'){
                        temp[k++] = list[i++];
                }
                temp[k]='\0';
                strcpy(thisList[l++],temp);

                while(list[i]!=',' && list[i]!='\0') i++;
                i+=2;
        }

        for(i=0;i<l;i++){
                if(strcmp(thisList[i],params[i])!=0){
                        printWrongParamError(lineNo, fnName, thisList, params, l);
                        return 0;
                }
        }
        return 1;
}

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

%type <id> Expr
%type <id> Logical_Expr
%type <id> Primary
%type <id> Relational_Expr
%type <id> Additive_Expr
%type <id> Multiplicative_Expr
%type <id> ArrayNotation
%type <id> FunctionCall

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
                                                                                        if(strcmp(returnType,$1)!=0)
                                                                                                printRetTypeError(lineNo, returnType, $1, $2);
                                                                                        else if(strcmp($1,"void")==0 && strcmp(returnType,"void")!=0)
                                                                                                printVoidFunctionReturningError(lineNo, returnType);
                                                                                        else{
                                                                                                strcpy(returnType, "");
                                                                                                insertFunctionItem($2,$1,lineNo,curScope,0,pList, pCount);
                                                                                                strcpy(pList, "");
                                                                                                pCount = 0;
                                                                                        }
                                                                                        strcpy(returnType, "void");
                                                                                }
             ;
FormalParamList: Type ID                                        {       
                                                                        pCount++;
                                                                        char temp[100];
                                                                        strcpy(temp, $1);
                                                                        insertSymbolItem($2,temp,lineNo,nextNum + 1,0);
                                                                        strcat(pList,strcat(temp," "));
                                                                        strcpy(temp, $2);
                                                                        strcat(pList,strcat(temp,", "));                                                                       
                                                                }
                | Type '*' ID                                   {
                                                                        pCount++;
                                                                        char temp[100];
                                                                        strcpy(temp, $1);
                                                                        insertSymbolItem($3,temp,lineNo,nextNum + 1,0);
                                                                        strcat(pList,strcat(temp," "));
                                                                        strcpy(temp, $3);
                                                                        strcat(pList,strcat(temp,", "));
                                                                        
                                                                }
                | Type FuncArrayNotation                            {DEBUGY_PRINT("FLIST Call 3\n");}
                | Type ID ',' FormalParamList                   {       
                                                                        pCount++;
                                                                        char temp[100];
                                                                        strcpy(temp, $1);
                                                                        insertSymbolItem($2,temp,lineNo,nextNum + 1,0);
                                                                        strcat(pList,strcat(temp," "));
                                                                        strcpy(temp, $2);
                                                                        strcat(pList,strcat(temp,", "));
                                                                        
                                                                }
                | Type '*' ID ',' FormalParamList               {
                                                                        pCount++;
                                                                        char temp[100];
                                                                        strcpy(temp, $1);
                                                                        insertSymbolItem($3,temp,lineNo,nextNum + 1,0);
                                                                        strcat(pList,strcat(temp," "));
                                                                        strcpy(temp, $3);
                                                                        strcat(pList,strcat(temp,", "));
                                                                }
                | Type FuncArrayNotation ',' FormalParamList        {DEBUGY_PRINT("FLIST Call 6\n");}
                |
                ;


Declaration:  Type IDList ';'    {if(strcmp($1,"void")==0) printVoidVariableError(lineNo);}
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
                                        strcpy(temp, $1);
                                        strcat(pList,strcat(temp,"[], "));
                                        insertArrayItem($1,type,lineNo,nextNum + 1,0,0);
                                }
            | ID '[' Expr ']'   {       if(num<=0)
                                                printIllArrayError(lineNo,$1,num);
                                        else{
                                                pCount++;
                                                char temp[100];
                                                strcpy(temp, type);
                                                strcat(pList,strcat(temp," "));
                                                strcpy(temp, $1);
                                                strcat(pList,strcat(temp,"[], "));
                                                insertArrayItem($1,type,lineNo,nextNum + 1,0,num);
                                        }    
                                }
            ;

DefArrayNotation: ID '[' ']'   {
                                if(lookUpSymbolItem_scope($1, curScope))
                                        printReDecError(lineNo, $1);
                                else{
                                        insertSymbolItem($1,type,lineNo,curScope,0);
                                    }
                                }
            | ID '[' Expr ']' {
                                if(lookUpSymbolItem_scope($1, curScope))
                                        printReDecError(lineNo, $1);
                                else if(num<=0)
                                        printIllArrayError(lineNo,$1,num);
                                else{
                                        insertArrayItem($1,type,lineNo,curScope,0,num);
                                    }
                                }
            ;
ArrayNotation: ID '[' Expr ']'   {if(!checkAncestors($1))
                                        printUndecVarErr(lineNo, $1);
                                  else if(checkAncestors($1)->arrayDim==-1)
                                        printWrongArrayUsageError(lineNo,$1);
                                  else if(strcmp($3,"int")!=0)
                                        printWrongArraySubscriptError(lineNo, $1);
                                  else if(num<=0)
                                        printIllArrayError(lineNo,$1,num);
                                  else{
                                        strcpy($$,checkAncestors($1)->tokenType);
                                  }
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


ParamList: Expr                 {addToParamList($1, pCount); pCount++; }
        | Expr ',' ParamList    {addToParamList($1, pCount); pCount++; }
        | 
        ;

Assignment: ID '=' Expr                   {if(!checkAncestors($1))
                                                printUndecVarErr(lineNo, $1);
                                           else if(strcmp(checkAncestors($1)->tokenType,$3)!=0)
                                                  printMismatchError(lineNo,checkAncestors($1)->tokenType,$3);
                                           else if(checkAncestors($1)->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,$1);
                                          }
            | ID PAS Expr                 {if(!checkAncestors($1))
                                                printUndecVarErr(lineNo, $1);
                                           else if(strcmp(checkAncestors($1)->tokenType,$3)!=0)
                                                  printMismatchError(lineNo,checkAncestors($1)->tokenType,$3);
                                           else if(checkAncestors($1)->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,$1);
                                          }   
            | ID SAS Expr                 {if(!checkAncestors($1))
                                                printUndecVarErr(lineNo, $1);
                                          else if(strcmp(checkAncestors($1)->tokenType,$3)!=0)
                                                  printMismatchError(lineNo,checkAncestors($1)->tokenType,$3);
                                          else if(checkAncestors($1)->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,$1);
                                          }  
            | ID MAS Expr                 {if(!checkAncestors($1))
                                                printUndecVarErr(lineNo, $1);
                                          else if(strcmp(checkAncestors($1)->tokenType,$3)!=0)
                                                  printMismatchError(lineNo,checkAncestors($1)->tokenType,$3);
                                          else if(checkAncestors($1)->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,$1);
                                          }
            | ID DAS Expr                 {if(!checkAncestors($1))
                                                printUndecVarErr(lineNo, $1);
                                           else if(strcmp(checkAncestors($1)->tokenType,$3)!=0)
                                                  printMismatchError(lineNo,checkAncestors($1)->tokenType,$3);
                                          else if(checkAncestors($1)->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,$1);
                                          }
            | '*' ID '=' Expr             {if(!checkAncestors($2))
                                                printUndecVarErr(lineNo, $2);
                                           else if(strcmp(checkAncestors($2)->tokenType,$4)!=0)
                                                  printMismatchError(lineNo,checkAncestors($2)->tokenType,$4);
                                          else if(checkAncestors($2)->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,$2);
                                          }
            | '*' ID PAS Expr             {if(!checkAncestors($2))
                                                printUndecVarErr(lineNo, $2);
                                          else if(strcmp(checkAncestors($2)->tokenType,$4)!=0)
                                                  printMismatchError(lineNo,checkAncestors($2)->tokenType,$4);
                                          else if(checkAncestors($2)->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,$2);
                                          }
            | '*' ID SAS Expr             {if(!checkAncestors($2))
                                                printUndecVarErr(lineNo, $2);
                                           else if(strcmp(checkAncestors($2)->tokenType,$4)!=0)
                                                  printMismatchError(lineNo,checkAncestors($2)->tokenType,$4);
                                          else if(checkAncestors($2)->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,$2);
                                          }
            | '*' ID MAS Expr             {if(!checkAncestors($2))
                                                printUndecVarErr(lineNo, $2);
                                           else if(strcmp(checkAncestors($2)->tokenType,$4)!=0)
                                                  printMismatchError(lineNo,checkAncestors($2)->tokenType,$4);
                                          else if(checkAncestors($2)->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,$2);
                                          }
            | '*' ID DAS Expr             {if(!checkAncestors($2))
                                                printUndecVarErr(lineNo, $2);
                                           else if(strcmp(checkAncestors($2)->tokenType,$4)!=0)
                                                  printMismatchError(lineNo,checkAncestors($2)->tokenType,$4);
                                          else if(checkAncestors($2)->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,$2);
                                          }
            | ArrayNotation '=' Expr      {if(strcmp($1,$3)!=0){
                                                  printMismatchError(lineNo,checkAncestors($1)->tokenType,$3);
                                          }}           
            | ArrayNotation PAS Expr      {if(strcmp($1,$3)!=0){
                                                  printMismatchError(lineNo,checkAncestors($1)->tokenType,$3);
                                          }}
            | ArrayNotation SAS Expr      {if(strcmp($1,$3)!=0){
                                                  printMismatchError(lineNo,checkAncestors($1)->tokenType,$3);
                                          }}
            | ArrayNotation MAS Expr      {if(strcmp($1,$3)!=0){
                                                  printMismatchError(lineNo,checkAncestors($1)->tokenType,$3);
                                          }}
            | ArrayNotation DAS Expr      {if(strcmp($1,$3)!=0){
                                                  printMismatchError(lineNo,checkAncestors($1)->tokenType,$3);
                                          }}
            | Primary                      
            ;

Expr: Logical_Expr { strcpy($$, $1); }
      ;


Logical_Expr: Relational_Expr { strcpy($$, $1); }
              | Logical_Expr AND Relational_Expr { strcpy($$, "int"); }
              | Logical_Expr OR Relational_Expr { strcpy($$, "int"); }
              | NOT Relational_Expr { strcpy($$, "int"); }
              ;

Relational_Expr: Additive_Expr { strcpy($$, $1); }
                 | Relational_Expr GT Additive_Expr { strcpy($$, "int"); }
                 | Relational_Expr LT Additive_Expr { strcpy($$, "int"); }
                 | Relational_Expr GE Additive_Expr { strcpy($$, "int"); }
                 | Relational_Expr LE Additive_Expr { strcpy($$, "int"); }
                 | Relational_Expr EQ Additive_Expr { strcpy($$, "int"); }
                 | Relational_Expr NE Additive_Expr { strcpy($$, "int"); }
                 ;


Additive_Expr: Multiplicative_Expr { strcpy($$, $1); }
               | Additive_Expr '+' Multiplicative_Expr { if(isHigherPri($1,$3)) strcpy($$,$1);
                                                         else strcpy($$,$3);
                                                        }
               | Additive_Expr '-' Multiplicative_Expr { if(isHigherPri($1,$3)) strcpy($$,$1);
                                                         else strcpy($$,$3);
                                                        }
               ;
Multiplicative_Expr: Primary { strcpy($$, $1); }
                     | Multiplicative_Expr '*' Primary { if(isHigherPri($1,$3)) strcpy($$,$1);
                                                         else strcpy($$,$3);
                                                        }
                     | Multiplicative_Expr '/' Primary { if(isHigherPri($1,$3)) strcpy($$,$1);
                                                         else strcpy($$,$3);
                                                        }
                     | Multiplicative_Expr '%' Primary { if(strcmp($1,"int")!=0 || strcmp($3,"int")!=0){
                                                                printf(RED "Error : Modulus operator expects int\n" RESET);
                                                                strcpy($$, "int");
                                                        }
                                                        else{
                                                                strcpy($$, "int");
                                                        }
                                                        }
                     ;
Primary: OPEN_PAR Expr CLOSE_PAR                        { strcpy($$, $2); }
         | NUM                                          {num = $1; strcpy($$,"int"); }
         | FLOATNUM                                     { strcpy($$,"float"); }
         | CHARCONST                                    { strcpy($$,"char"); }
         | STRING                                       { strcpy($$,"string"); }
         | ID                           {if(!checkAncestors($1)){
                                                printUndecVarErr(lineNo, $1);
                                         }
                                        else if(checkAncestors($1)->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,$1);
                                         else{
                                                 strcpy($$,checkAncestors($1)->tokenType);
                                         }
                                        }
         | '*' ID                       {if(!checkAncestors($2)){
                                                printUndecVarErr(lineNo, $2);
                                        }
                                        else if(checkAncestors($2)->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,$2);
                                        else{
                                                 strcpy($$,checkAncestors($2)->tokenType);
                                         }
                                        }
         | '&' ID                       {if(!checkAncestors($2)){
                                                printUndecVarErr(lineNo, $2);
                                        }
                                        else if(checkAncestors($2)->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,$2);
                                        else{
                                                 strcpy($$,checkAncestors($2)->tokenType);
                                         }}
         | '-' Primary                  {num = -num; strcpy($$,$2);}
         | '+' Primary                  {strcpy($$,$2);}
         | ArrayNotation                {strcpy($$,$1);}
         | FunctionCall                 {       if(!checkAncestors($1))
                                                        printUndecVarErr(lineNo, $1);
                                                else 
                                                        strcpy($$,checkAncestors($1)->tokenType);
                                        }
         | PP ID                        {if(!checkAncestors($2)){
                                                printUndecVarErr(lineNo, $2);
                                        }
                                        else if(checkAncestors($2)->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,$2);
                                        else{
                                                 strcpy($$,checkAncestors($2)->tokenType);
                                         }}
         | ID PP                        {if(!checkAncestors($1)){
                                                printUndecVarErr(lineNo, $1);
                                        }
                                        else if(checkAncestors($1)->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,$1);
                                        else{
                                                 strcpy($$,checkAncestors($1)->tokenType);
                                         }}
         | MM ID                        {if(!checkAncestors($2)){
                                                printUndecVarErr(lineNo, $2);
                                        }
                                        else if(checkAncestors($2)->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,$2);
                                        else{
                                                 strcpy($$,checkAncestors($2)->tokenType);
                                         }}
         | ID MM                        {if(!checkAncestors($1)){
                                                printUndecVarErr(lineNo, $1);
                                        }
                                        else if(checkAncestors($1)->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,$1);
                                        else{
                                                 strcpy($$,checkAncestors($1)->tokenType);
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
ReturnStatement: RETURN Expr ';'   { strcpy(returnType, $2); }
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
                                                else if(!isCorrectParams(params,lookUpSymbolItem($1)->paramList,$1)){
                                                        //printWrongParamError(lineNo, $1);
                                                }
                                                 pCount = 0;
                                                 strcpy($$,$1);
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