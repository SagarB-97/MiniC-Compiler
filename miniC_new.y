%{
#include <stdio.h>
#include <stdlib.h>
%}


%token INT FLOAT CHAR DOUBLE VOID
%token SIGNED UNSIGNED LONG SHORT
%token SWITCH BREAK CONTINUE CASE DEFAULT  
%token FOR WHILE DO
%token IF ELSE 
%token STRUCT 
%token NUM ID FLOATNUM STRING CHARCONST
%token INCLUDE

%right '=' '+=' '-=' '/=' '*='            //Last four not defined
%left AND OR
%left LE GE EQ NE LT GT                        // LE <= GE >= EQ == NE != LT < GT >
%left '+' '-' '*' '/' '%' '^' '!' '&' '.'  
%start start

%% 
start:	FunctionDef
	| Declaration
        | Include
        | start FunctionDef
        | start Declaration
	;

Declaration: Type IDList ';'
              ;

IncludeStatement: '#' INCLUDE LE ID GE
                  | '#' INCLUDE LE ID '.' ID GE
                  ;
Include:   IncludeStatement
           | IncludeStatement Include
           ;

FunctionDef: Type ID '(' DeclarationList ')' CompoundStatement
            | Type ID '(' ')' CompoundStatement
            ;
DeclarationList: Type ID
                | Type ID ',' DeclarationList
                ;

Type: INT | FLOAT | VOID | CHAR | DOUBLE | 
        Modifiers INT | Modifiers FLOAT | Modifiers DOUBLE | Modifiers CHAR
        ;
Modifiers: SHORT | LONG | UNSIGNED | SIGNED
        ;

ArrayNotation: ID '[' NUM ']'
            | ID '[' ']'
            ;
IDList: ID
        | ArrayNotation
        | ID ',' IDList
        | ArrayNotation ',' IDList
        ;

Assignment: ID '=' Primary ';'
            | ID "+=" Primary  ';'
            | ID "-=" Primary  ';'
            | ID "*=" Primary  ';'
            | ID "/=" Primary  ';'
            ;

Expr: Equality_Expr
      ;

Equality_Expr: Additive_Expr
              | Equality_Expr "==" Equality_Expr
              | Equality_Expr "!=" Equality_Expr
              ;
Additive_Expr: Multiplicative_Expr
               | Additive_Expr '+' Additive_Expr
               | Additive_Expr '-' Additive_Expr
               ;
Multiplicative_Expr: Primary
                     | Multiplicative_Expr '*' Multiplicative_Expr
                     | Multiplicative_Expr '/' Multiplicative_Expr
                     ;
Primary: '(' Expr ')'
         | NUM | FLOATNUM | CHARCONST
         | ID
         | '-' Primary
         | Expr
         ;

CompoundStatement: '{' StatementList '}'
	;
StmtList: StatementList Statement
	|
	;
Statement: WhileStatement
	| Declaration
	| ForStatement
	| IfStatement
	| FunctionCall                                  
	| ';'
        ; 

WhileStatement: WHILE '(' Expr1 ')' Statement            //NEED TO DEFINE Expr1 to include comparison operators                                            
                | WHILE '(' Expr1 ')' CompoundStatement
                ;

ForStatement: FOR '(' Expr ';' Expr ';' Expr ')' Statement 
              | FOR '(' Expr ';' Expr ';' Expr ')' CompoundStatement 
              ;

IfStatement: IF '(' Expr1 ')' Statement
             | IF '(' Expr1 ')' CompoundStatement
             ;

FunctionCall: ID '(' IDList ');' 
   
            











