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
int tempVarCount = 0;
FILE * threeAddressFile = NULL;
int labelCount = 0;
char threeAddressLabelStack[100][100];
int threeAddressLabelStackTop = -1;

char threeAddressCode[1000][100];
char threeAddressCodeLineNo = 0;
int backPatchStack[100];
int backPatchStackTop = -1;
char tempCode[100];
char pVal[100][100];
int countPval = 0;

void pushBackPatchStack(int n){
        backPatchStackTop++;
        backPatchStack[backPatchStackTop] = n;
}
int popBackPatchStack(){
        int res = backPatchStack[backPatchStackTop];
        backPatchStackTop--;
        return res;
}
void addThreeAddressCode(char * str){
        strcpy(threeAddressCode[threeAddressCodeLineNo],str);
        threeAddressCodeLineNo++;
}

void pushThreeAddressLabelStack(char * label){
        strcpy(threeAddressLabelStack[++threeAddressLabelStackTop],label);
}
void popThreeAddressLabelStack(){
        threeAddressLabelStackTop--;
}

char * tempVarName() {
        char * buffer = (char*)malloc(10);
        sprintf(buffer,"T%d",tempVarCount);
        tempVarCount++;
        return buffer;
}
char * labelName() {
        char * buffer = (char*)malloc(10);
        sprintf(buffer,"Label_%d",labelCount);
        labelCount++;
        return buffer;
}
char * nextLabelName(){
        char * buffer = (char*)malloc(10);
        sprintf(buffer,"Label_%d",labelCount);
        return buffer;
}
char * nextnextLabelName(){
        char * buffer = (char*)malloc(10);
        sprintf(buffer,"Label_%d",labelCount + 1);
        return buffer;
}
char * integerToString(int a){
        char * buffer = (char*)malloc(100);
        sprintf(buffer, "%d", a);
        return buffer;
}
char * floatToString(float a){
        char * buffer = (char*)malloc(100);
        sprintf(buffer, "%f", a);
        return buffer;
}
char * charToString(char a){
        char * buffer = (char*)malloc(100);
        sprintf(buffer, "\'%c\'", a);
        return buffer;
}
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
        ScopeNode *node = findChild(root, curScope);
        while(node!=NULL)
        {
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
%token STRING
%token INCLUDE
%token OPEN_PAR CLOSE_PAR

%union {
	char id[100];
        int num;
        float floatNum;
        char charConst;
        struct{
                char type[100];
                char val[100];
        } symAttrib;
}
%token <floatNum> FLOATNUM
%token <charConst> CHARCONST
%token <id> ID
%token <id> INT
%token <id> CHAR
%token <id> FLOAT
%token <id> DOUBLE
%token <id> VOID
%token <num> NUM
%type <id> Type

%type <symAttrib> Expr
%type <symAttrib> Logical_Expr
%type <symAttrib> Primary
%type <symAttrib> Relational_Expr
%type <symAttrib> Additive_Expr
%type <symAttrib> Multiplicative_Expr
%type <symAttrib> ArrayNotation
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

FunctionDef: Type ID { sprintf(tempCode, "\nfunc begin %s :\n", $2); addThreeAddressCode(tempCode); }
                    OPEN_PAR FormalParamList CLOSE_PAR CompoundStatement       {
                                                                                        if(strcmp(returnType,$1)!=0)
                                                                                                printRetTypeError(lineNo, returnType, $1, $2);
                                                                                        else if(strcmp($1,"void")==0 && strcmp(returnType,"void")!=0)
                                                                                                printVoidFunctionReturningError(lineNo, returnType);
                                                                                        else{
                                                                                                insertFunctionItem($2,$1,lineNo,curScope,0,pList, pCount);
                                                                                                strcpy(pList, "");
                                                                                                pCount = 0;
                                                                                        }
                                                                                        if(strcmp(returnType, "void") == 0)
                                                                                                {
                                                                                                     sprintf(tempCode, "return\n"); addThreeAddressCode(tempCode);   
                                                                                                }
                                                                                        strcpy(returnType, "void");
                                                                                        sprintf(tempCode, "func end\n"); addThreeAddressCode(tempCode);
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
                | Type FuncArrayNotation ',' FormalParamList        {DEBUGY_PRINT("FLIST Call 6\n");}
                |
                ;


Declaration:  Type IDList ';'    {if(strcmp($1,"void")==0) printVoidVariableError(lineNo);}
        ;

Type:   INT                     {strcpy(type,$1);strcpy($$,$1);}
        | FLOAT                 {strcpy(type,$1);strcpy($$,$1);}
        | VOID                  {strcpy(type,$1);strcpy($$,$1);}
        | CHAR                  {strcpy(type,$1);strcpy($$,$1);}
        | DOUBLE                {strcpy(type,$1);strcpy($$,$1);} 
        | Modifiers INT         {strcpy(type,$2);}
        | Modifiers FLOAT       {strcpy(type,$2);}
        | Modifiers DOUBLE      {strcpy(type,$2);}
        | Modifiers CHAR        {strcpy(type,$2);}
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
ArrayNotation: ID '[' Expr ']'   {
                                  strcpy($$.type,"none");
                                  if(!checkAncestors($1))
                                        printUndecVarErr(lineNo, $1);
                                  else if(checkAncestors($1)->arrayDim==-1)
                                        printWrongArrayUsageError(lineNo,$1);
                                  else if(strcmp($3.type,"int")!=0)
                                        printWrongArraySubscriptError(lineNo, $1);
                                  else if(num<0)
                                        printIllArrayError(lineNo,$1,num);
                                  else{
                                        strcpy($$.type,checkAncestors($1)->tokenType);
                                        char * tempVarIndex = tempVarName();
                                        char * tempVarAddress = tempVarName();
                                        char * tempVarValue = tempVarName();
                                        sprintf(tempCode, "%s = addr(%s)\n", tempVarAddress, $1);addThreeAddressCode(tempCode);
                                        sprintf(tempCode, "%s = %s * 4\n", tempVarIndex, $3.val);addThreeAddressCode(tempCode);
                                        sprintf(tempCode, "%s = %s[%s]\n", tempVarValue, tempVarAddress, tempVarIndex);addThreeAddressCode(tempCode);
                                        strcpy($$.val,tempVarValue);
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

        | DefArrayNotation ',' IDList
        | ID                                   {
                                                if(lookUpSymbolItem_scope($1,curScope))
                                                        printReDecError(lineNo, $1);
                                                else
                                                        insertSymbolItem($1,type,lineNo,curScope,0);
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

            | DefArrayNotation '=' Expr
            | DefArrayNotation PAS Expr
            | DefArrayNotation SAS Expr
            | DefArrayNotation MAS Expr
            | DefArrayNotation DAS Expr
            ;


ParamList: Expr                 {addToParamList($1.type, pCount); pCount++; strcpy(pVal[countPval++], $1.val);}
        | Expr ',' ParamList    {addToParamList($1.type, pCount); pCount++; strcpy(pVal[countPval++], $1.val);}
        | 
        ;

Assignment: ID '=' Expr                   {if(!checkAncestors($1))
                                                printUndecVarErr(lineNo, $1);
                                           else if(strcmp(checkAncestors($1)->tokenType,$3.type)!=0)
                                                  printMismatchError(lineNo,checkAncestors($1)->tokenType,$3.type);
                                           else if(checkAncestors($1)->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,$1);
                                           else
                                           {
                                                   //printf("Assignment executed\n");
                                                   sprintf(tempCode, "%s = %s\n", $1, $3.val);addThreeAddressCode(tempCode);
                                           }
                                          }
            | ArrayNotation '=' Expr      {if(strcmp($1.type,$3.type)!=0){
                                                  printMismatchError(lineNo,checkAncestors($1.val)->tokenType,$3.type);
                                          }
                                          else{
                                                  sprintf(tempCode, "%s = %s\n",$1.val,$3.val);addThreeAddressCode(tempCode);
                                          }
                                          }

            | Primary
            ;

Expr: Logical_Expr { strcpy($$.type, $1.type); strcpy($$.val,$1.val);}
      ;


Logical_Expr: Relational_Expr { strcpy($$.type, $1.type); strcpy($$.val,$1.val);}
              | Logical_Expr AND Relational_Expr { strcpy($$.type, "int");
                                                   strcpy($$.val, tempVarName());
                                                   sprintf(tempCode, "%s = %s & %s\n", $$.val, $1.val,$3.val);addThreeAddressCode(tempCode);
                                                 }
              | Logical_Expr OR Relational_Expr  { strcpy($$.type, "int");
                                                   strcpy($$.val, tempVarName());
                                                   sprintf(tempCode, "%s = %s | %s\n", $$.val, $1.val,$3.val);addThreeAddressCode(tempCode);
                                                 }
              | NOT Relational_Expr {   strcpy($$.type, "int");
                                        strcpy($$.val, tempVarName());
                                        sprintf(tempCode, "%s = !(%s)\n", $$.val, $2.val);addThreeAddressCode(tempCode);
                                    }
              ;

Relational_Expr: Additive_Expr { strcpy($$.type, $1.type); strcpy($$.val,$1.val);}
                 | Relational_Expr GT Additive_Expr {   strcpy($$.type, "int");
                                                        strcpy($$.val, tempVarName());
                                                        sprintf(tempCode, "%s = (%s > %s)\n", $$.val, $1.val,$3.val);addThreeAddressCode(tempCode);
                                                    }
                 | Relational_Expr LT Additive_Expr {   strcpy($$.type, "int");
                                                        strcpy($$.val, tempVarName());
                                                        sprintf(tempCode, "%s = (%s < %s)\n", $$.val, $1.val,$3.val);addThreeAddressCode(tempCode);
                                                    }
                 | Relational_Expr GE Additive_Expr {   strcpy($$.type, "int");
                                                        strcpy($$.val, tempVarName());
                                                        sprintf(tempCode, "%s = (%s >= %s)\n", $$.val, $1.val,$3.val);addThreeAddressCode(tempCode);
                                                    }
                 | Relational_Expr LE Additive_Expr {   strcpy($$.type, "int");
                                                        strcpy($$.val, tempVarName());
                                                        sprintf(tempCode, "%s = (%s <= %s)\n", $$.val, $1.val,$3.val);addThreeAddressCode(tempCode);
                                                    }
                 | Relational_Expr EQ Additive_Expr {   strcpy($$.type, "int");
                                                        strcpy($$.val, tempVarName());
                                                        sprintf(tempCode, "%s = (%s == %s)\n", $$.val, $1.val,$3.val);addThreeAddressCode(tempCode);
                                                    }
                 | Relational_Expr NE Additive_Expr {   strcpy($$.type, "int");
                                                        strcpy($$.val, tempVarName());
                                                        sprintf(tempCode, "%s = (%s != %s)\n", $$.val, $1.val,$3.val);addThreeAddressCode(tempCode);
                                                    }
                 ;


Additive_Expr: Multiplicative_Expr { strcpy($$.type, $1.type); strcpy($$.val,$1.val);}
               | Additive_Expr '+' Multiplicative_Expr { if(isHigherPri($1.type,$3.type)) strcpy($$.type,$1.type);
                                                         else { strcpy($$.type,$3.type);
                                                                strcpy($$.val, tempVarName());
                                                                sprintf(tempCode, "%s = %s + %s\n", $$.val, $1.val,$3.val);addThreeAddressCode(tempCode);
                                                              }
                                                        }
               | Additive_Expr '-' Multiplicative_Expr { if(isHigherPri($1.type,$3.type)) strcpy($$.type,$1.type);
                                                         else { strcpy($$.type,$3.type);
                                                                strcpy($$.val, tempVarName());
                                                                sprintf(tempCode, "%s = %s - %s\n", $$.val, $1.val,$3.val);addThreeAddressCode(tempCode);
                                                              }
                                                        }
               ;
Multiplicative_Expr: Primary { strcpy($$.type, $1.type); strcpy($$.val, $1.val); }
                     | Multiplicative_Expr '*' Primary { if(isHigherPri($1.type,$3.type)) strcpy($$.type,$1.type);
                                                         else { strcpy($$.type,$3.type);
                                                                strcpy($$.val, tempVarName());
                                                                sprintf(tempCode, "%s = %s * %s\n", $$.val, $1.val,$3.val);addThreeAddressCode(tempCode); }
                                                        }
                     | Multiplicative_Expr '/' Primary { if(isHigherPri($1.type,$3.type)) strcpy($$.type,$1.type);
                                                         else { strcpy($$.type,$3.type);
                                                                strcpy($$.val, tempVarName());
                                                                sprintf(tempCode, "%s = %s / %s\n", $$.val, $1.val,$3.val);
                                                                addThreeAddressCode(tempCode); }

                                                        }
                     | Multiplicative_Expr '%' Primary { if(strcmp($1.type,"int")!=0 || strcmp($3.type,"int")!=0){
                                                                printf(RED "Error : Modulus operator expects int\n" RESET);
                                                                strcpy($$.type, "int");
                                                        }
                                                        else{
                                                                strcpy($$.type, "int");
                                                                strcpy($$.val, tempVarName());
                                                                sprintf(tempCode, "%s = %s %% %s\n", $$.val, $1.val,$3.val);
                                                                addThreeAddressCode(tempCode);
                                                        }
                                                        }
                     ;
Primary: OPEN_PAR Expr CLOSE_PAR                        { strcpy($$.type, $2.type); strcpy($$.val, $2.val); }
         | NUM                                          {num = $1; strcpy($$.type,"int"); strcpy($$.val, integerToString($1));}
         | FLOATNUM                                     { strcpy($$.type,"float"); strcpy($$.val, floatToString($1));}
         | CHARCONST                                    { strcpy($$.type,"char"); strcpy($$.val, charToString($1));}
         | STRING                                       { strcpy($$.type,"string"); }
         | ID                           {if(!checkAncestors($1)){
                                                printUndecVarErr(lineNo, $1);
                                         }
                                        else if(checkAncestors($1)->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,$1);
                                         else{
                                                 strcpy($$.type,checkAncestors($1)->tokenType);
                                                 strcpy($$.val, $1);
                                         }
                                        }
         | '-' Primary                  {num = -num; strcpy($$.type,$2.type);}
         | '+' Primary                  {strcpy($$.type,$2.type);}
         | ArrayNotation                {       strcpy($$.type,$1.type);
                                                strcpy($$.val, $1.val);
                                        }
         | FunctionCall                 {       if(!checkAncestors($1))
                                                        printUndecVarErr(lineNo, $1);
                                                else 
                                                        strcpy($$.type,checkAncestors($1)->tokenType);
                                        }
         | PP ID                        {if(!checkAncestors($2)){
                                                printUndecVarErr(lineNo, $2);
                                        }
                                        else if(checkAncestors($2)->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,$2);
                                        else{
                                                 strcpy($$.type,checkAncestors($2)->tokenType);
                                                 strcpy($$.val, tempVarName());
                                                 sprintf(tempCode, "%s = %s + 1\n", $$.val, $2);addThreeAddressCode(tempCode);
                                                 sprintf(tempCode, "%s = %s\n", $2, $$.val);addThreeAddressCode(tempCode); }
                                         }
         | ID PP                        {if(!checkAncestors($1)){
                                                printUndecVarErr(lineNo, $1);
                                        }
                                        else if(checkAncestors($1)->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,$1);
                                        else{
                                                 strcpy($$.type,checkAncestors($1)->tokenType);
                                                 strcpy($$.val, tempVarName());
                                                 sprintf(tempCode, "%s = %s + 1\n", $$.val, $1); addThreeAddressCode(tempCode);
                                                 sprintf(tempCode, "%s = %s\n", $1, $$.val); addThreeAddressCode(tempCode);
                                         }}
         | MM ID                        {if(!checkAncestors($2)){
                                                printUndecVarErr(lineNo, $2);
                                        }
                                        else if(checkAncestors($2)->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,$2);
                                        else{
                                                 strcpy($$.type,checkAncestors($2)->tokenType);
                                                 strcpy($$.val, tempVarName());
                                                 sprintf(tempCode, "%s = %s - 1\n", $$.val, $2); addThreeAddressCode(tempCode);
                                                 sprintf(tempCode, "%s = %s\n", $2, $$.val);addThreeAddressCode(tempCode);
                                         }}
         | ID MM                        {if(!checkAncestors($1)){
                                                printUndecVarErr(lineNo, $1);
                                        }
                                        else if(checkAncestors($1)->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,$1);
                                        else{
                                                 strcpy($$.type,checkAncestors($1)->tokenType);
                                                 strcpy($$.val, tempVarName());
                                                 sprintf(tempCode, "%s = %s - 1\n", $$.val, $1);addThreeAddressCode(tempCode);
                                                 sprintf(tempCode, "%s = %s\n", $1, $$.val);addThreeAddressCode(tempCode);
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
ReturnStatement: RETURN Expr ';'   { strcpy(returnType, $2.type); 
                                     sprintf(tempCode, "return %s  \n", $2.val);addThreeAddressCode(tempCode);
                                  }
                 ;

WhileStatement: WHILE                           {       pushThreeAddressLabelStack(nextLabelName());
                                                        sprintf(tempCode, "\n%s : \n", labelName());addThreeAddressCode(tempCode);
                                                }
                OPEN_PAR Expr CLOSE_PAR         {       pushBackPatchStack(threeAddressCodeLineNo);
                                                        sprintf(tempCode, "IF (%s) GOTO %s\nGOTO ", $4.val, nextLabelName());addThreeAddressCode(tempCode);
                                                        sprintf(tempCode, "\n%s : \n", labelName());addThreeAddressCode(tempCode);
                                                }
                CompoundStatement               {       sprintf(tempCode, "GOTO %s\n", threeAddressLabelStack[threeAddressLabelStackTop]);addThreeAddressCode(tempCode);
                                                        popThreeAddressLabelStack();
                                                        char * newLabelName = labelName();
                                                        sprintf(tempCode, "\n%s :\n", newLabelName);addThreeAddressCode(tempCode);

                                                        char tempString[100];
                                                        sprintf(tempString, "%s\n", newLabelName);
                                                        strcat(threeAddressCode[popBackPatchStack()], tempString);
                                                }
                ;

DoWhileStatement: DO                            {       pushThreeAddressLabelStack(nextLabelName());
                                                        sprintf(tempCode, "\n%s : \n", labelName());addThreeAddressCode(tempCode);
                                                }
                CompoundStatement WHILE OPEN_PAR Expr CLOSE_PAR ';'     {       sprintf(tempCode, "IF (%s) GOTO %s\n", $6.val, threeAddressLabelStack[threeAddressLabelStackTop]);addThreeAddressCode(tempCode);
                                                                                popThreeAddressLabelStack();
                                                                        }
                  ;


ForStatement: FOR OPEN_PAR Assignment ';' Expr ';' Assignment CLOSE_PAR Statement
              | FOR OPEN_PAR Assignment ';' Expr ';' Assignment CLOSE_PAR CompoundStatement
              ;

IfStatement: IF OPEN_PAR Expr CLOSE_PAR         {       pushBackPatchStack(threeAddressCodeLineNo);
                                                        sprintf(tempCode, "IF (%s) GOTO %s\nGOTO ", $3.val, nextLabelName());addThreeAddressCode(tempCode);
                                                        sprintf(tempCode, "\n%s : \n", labelName());addThreeAddressCode(tempCode);
                                                }
                Statement                       {       char * newLabelName = labelName();
                                                        sprintf(tempCode, "\n%s : \n", newLabelName);addThreeAddressCode(tempCode);

                                                        char tempString[100];
                                                        sprintf(tempString, "%s\n", newLabelName);
                                                        strcat(threeAddressCode[popBackPatchStack()], tempString);
                                                }
                ElseStatement
                | IF OPEN_PAR Expr CLOSE_PAR    {       pushBackPatchStack(threeAddressCodeLineNo);
                                                        sprintf(tempCode, "IF (%s) GOTO %s\nGOTO ", $3.val, nextLabelName());addThreeAddressCode(tempCode);
                                                        sprintf(tempCode, "\n%s : \n", labelName());addThreeAddressCode(tempCode);
                                                }
                CompoundStatement               {       int prevTop = popBackPatchStack();
                                                        pushBackPatchStack(threeAddressCodeLineNo);
                                                        pushBackPatchStack(prevTop);
                                                        sprintf(tempCode, "GOTO "); addThreeAddressCode(tempCode);

                        
                                                        char * newLabelName = labelName();
                                                        sprintf(tempCode, "%s : \n", newLabelName);addThreeAddressCode(tempCode);

                                                        char tempString[100];
                                                        sprintf(tempString, "%s\n", newLabelName);
                                                        strcat(threeAddressCode[popBackPatchStack()], tempString);
                                                }
                ElseStatement                   {       char * newLabelName = labelName();
                                                        sprintf(tempCode, "%s : \n", newLabelName);addThreeAddressCode(tempCode);

                                                        char tempString[100];
                                                        sprintf(tempString, "%s\n", newLabelName);
                                                        strcat(threeAddressCode[popBackPatchStack()], tempString);       
                                                }
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
                                                else
                                                {
                                                        for(int i = countPval-1; i >=0; i--)
                                                        {
                                                                sprintf(tempCode, "Push param %s\n",pVal[i]);addThreeAddressCode(tempCode);
                                                        }
                                                        sprintf(tempCode, "CALL %s\n", $1);addThreeAddressCode(tempCode);
                                                        countPval = 0;
                                                }
                                                
                                                 pCount = 0;
                                                 strcpy($$,$1);
                                                }
                ;

%%
#include<ctype.h>

int count=0;

void writeThreeAddressCode(){
        for(int i=0;i<threeAddressCodeLineNo;i++){
                fprintf(threeAddressFile, "%s", threeAddressCode[i]);
        }
}
int main(int argc, char *argv[])
{
        initScope();
        yyin = fopen(argv[1], "r");
        threeAddressFile = fopen("threeAddressCode.txt","w");
        if(!yyparse())
                printf("\nParsing complete\n");
        else
                printf(RED "\nParsing failed\n" RESET);

        writeThreeAddressCode();
        fclose(yyin);
        fclose(threeAddressFile);

        //showSymbolTable();
        return 0;
}
         
void yyerror(const char *s) {
	printf(RED "%d : %s %s\n" RESET, lineNo, s, yytext );
}