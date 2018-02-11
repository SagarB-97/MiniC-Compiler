%{
#include <stdio.h>
#include <stdlib.h>



extern int yyparse (void);

extern FILE *yyin, *yyout;

extern int yylineno;

extern yylineno;

extern char *yytext;

%}


%token INT FLOAT CHAR DOUBLE VOID
%token SIGNED UNSIGNED LONG SHORT
%token SWITCH BREAK CONTINUE CASE DEFAULT  
%token FOR WHILE DO
%token IF ELSE 
%token STRUCT 
%token NUM ID FLOATNUM STRING CHARCONST
%token INCLUDE

%right '=' PAS MAS DAS SAS            //Last four not defined
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

IncludeStatement: '#' INCLUDE LT ID GT
                  | '#' INCLUDE LT ID '.' ID GT
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
            | ID PAS Primary  ';'
            | ID SAS Primary  ';'
            | ID MAS Primary  ';'
            | ID DAS Primary  ';'
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
StatementList: Statement StatementList ;

Statement: WhileStatement
	| Declaration
	| ForStatement
	| IfStatement
	| FunctionCall                                  
	| ';'
        ; 

WhileStatement: WHILE '(' Expr ')' Statement            //NEED TO DEFINE Expr1 to include comparison operators                                            
                | WHILE '(' Expr ')' CompoundStatement
                ;

ForStatement: FOR '(' Expr ';' Expr ';' Expr ')' Statement 
              | FOR '(' Expr ';' Expr ';' Expr ')' CompoundStatement 
              ;

IfStatement: IF '(' Expr ')' Statement
             | IF '(' Expr ')' CompoundStatement
             ;

FunctionCall: ID '(' IDList ");" ;

%%
#include<ctype.h>
int count=0;

int main(int argc, char *argv[])
{
	yyin = fopen(argv[1], "r");
	
   if(!yyparse())
		printf("\nParsing complete\n");
	else
		printf("\nParsing failed\n");
	
	fclose(yyin);
    return 0;
}
         
yyerror(char *s) {
	printf("%d : %s %s\n", yylineno, s, yytext );
}
   
            











