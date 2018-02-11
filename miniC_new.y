%{
#include <stdio.h>
#include <stdlib.h>



extern int yyparse (void);

extern FILE *yyin, *yyout;

extern int yylineno;

extern yylineno;

extern char *yytext;

extern lineNo;

%}


%token INT FLOAT CHAR DOUBLE VOID RETURN
%token SIGNED UNSIGNED LONG SHORT
%token SWITCH BREAK CONTINUE CASE DEFAULT  
%token FOR WHILE DO
%token IF ELSE 
%token STRUCT 
%token NUM ID FLOATNUM STRING CHARCONST
%token INCLUDE
%token OPEN_PAR CLOSE_PAR

%right '=' PAS MAS DAS SAS            //Last four not defined
%left AND OR NOT
%left LE GE EQ NE LT GT                        // LE <= GE >= EQ == NE != LT < GT >
%left '+' '-' '*' '/' '%' '^' '!' '&' '.'  
%start start

%% 
start:	FunctionDef
	| Declaration
        | Include
        | FunctionDef start
        | Declaration start
        | Include FunctionDef start
        | Include start
	;

IncludeStatement: '#' INCLUDE LT ID GT
                  | '#' INCLUDE LT ID '.' ID GT
                  ;
Include:   IncludeStatement
           | IncludeStatement Include
           ;

FunctionDef: Type ID OPEN_PAR DeclarationList CLOSE_PAR CompoundStatement       {printf("FUNCTION DEF CALLED\n");}
            | Type ID OPEN_PAR CLOSE_PAR CompoundStatement                   {printf("FUNCTION DEF2 CALLED\n");}
            ;
DeclarationList: Type ID                        {printf("DECLIST Cal\n");}
                | Type ID ',' DeclarationList   {printf("DECLIST Cal 2\n");}
                ;


Declaration:    Type ID ';'  {printf("DECLARATION CALLED\n");}   
        | Type IDList ';'    {printf("DECLARATION CALLED 2\n");}
        ;

Type: INT {printf("Type called\n");}| FLOAT | VOID | CHAR | DOUBLE | 
        Modifiers INT | Modifiers FLOAT | Modifiers DOUBLE | Modifiers CHAR
        ;
Modifiers: SHORT | LONG | UNSIGNED | SIGNED
        ;

ArrayNotation: ID '[' NUM ']'
            | ID '[' ']'
            ;
IDList: ArrayNotation
        | ID ',' IDList
        | ArrayNotation ',' IDList
        | STRING ',' IDList
        | NUM ',' IDList
        | ID | NUM | STRING
        ;

Assignment: ID '=' Expr ';'          {printf("Assignment Rule 1 called\n");}
            | ID PAS Expr  ';'
            | ID SAS Expr  ';'
            | ID MAS Expr  ';'
            | ID DAS Expr  ';'
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
                     ;
Primary: OPEN_PAR Expr CLOSE_PAR
         | NUM | FLOATNUM | CHARCONST   
         | ID                           {printf("Primary Identifier\n");}
         | '-' Primary
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
	| FunctionCall     
        | Assignment
        | ReturnStatement                              
	| ';'
        ; 
ReturnStatement: RETURN Expr ';'   {printf("Return Statement Call\n");}

WhileStatement: WHILE OPEN_PAR Expr CLOSE_PAR Statement                                                        
                | WHILE OPEN_PAR Expr CLOSE_PAR CompoundStatement
                ;

ForStatement: FOR OPEN_PAR Expr ';' Expr ';' Expr CLOSE_PAR Statement 
              | FOR OPEN_PAR Expr ';' Expr ';' Expr CLOSE_PAR CompoundStatement 
              ;

IfStatement: IF OPEN_PAR Expr CLOSE_PAR Statement ElseStatement
             | IF OPEN_PAR Expr CLOSE_PAR CompoundStatement ElseStatement
             ;

ElseStatement: ELSE CompoundStatement
               | ELSE Statement
               |
               ;

FunctionCall: ID OPEN_PAR IDList CLOSE_PAR ';'        {printf("Function Call\n");} 
                ;

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
	printf("%d : %s %s\n", lineNo, s, yytext );
}
   
            











