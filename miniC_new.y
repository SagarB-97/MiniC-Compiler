%{
#include <stdio.h>
#include <stdlib.h>



int yyparse (void);
int yylex();
void yyerror(const char * s);


extern FILE *yyin, *yyout;

extern char *yytext;

extern int lineNo;

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
           | IncludeStatement Include
           ;

FunctionDef: Type ID OPEN_PAR FormalParamList CLOSE_PAR CompoundStatement       {printf("FUNCTION DEF CALLED 1\n");}
             ;
FormalParamList: Type ID                                        {printf("FLIST Call 1\n");}
                | Type '*' ID                                   {printf("FLIST Call 2\n");}
                | Type ArrayNotation                            {printf("FLIST Call 3\n");}
                | Type ID ',' FormalParamList                   {printf("FLIST Call 4\n");}
                | Type '*' ID ',' FormalParamList               {printf("FLIST Call 5\n");}
                | Type ArrayNotation ',' FormalParamList        {printf("FLIST Call 6\n");}
                |
                ;


Declaration:  Type IDList ';'    {printf("DECLARATION CALLED 3\n");}
        ;

Type: INT | FLOAT | VOID | CHAR | DOUBLE | 
        Modifiers INT | Modifiers FLOAT | Modifiers DOUBLE | Modifiers CHAR
        ;
Modifiers: SHORT | LONG | UNSIGNED | SIGNED
        ;

ArrayNotation: ID '[' ']'
            | ID '[' Expr ']'
            ;
IDList: ArrayNotation
        | ID ',' IDList
        | '*' ID ',' IDList
        | ArrayNotation ',' IDList
        | ID 
        | '*' ID
        | DefineAssign ',' IDList
        | DefineAssign 
        ;

DefineAssign: ID '=' Expr                   {printf("Assignment Rule 1 called\n");}
            | ID PAS Expr  
            | ID SAS Expr  
            | ID MAS Expr  
            | ID DAS Expr  
            | '*' ID '=' Expr           
            | '*' ID PAS Expr  
            | '*' ID SAS Expr  
            | '*' ID MAS Expr  
            | '*' ID DAS Expr
            | ArrayNotation '=' Expr                   
            | ArrayNotation PAS Expr  
            | ArrayNotation SAS Expr  
            | ArrayNotation MAS Expr  
            | ArrayNotation DAS Expr
            ;


ParamList: ArrayNotation
        | ID ',' ParamList
        | '*' ID ',' ParamList
        | '&' ID ',' ParamList
        | ArrayNotation ',' ParamList
        | STRING ',' ParamList
        | NUM ',' ParamList
        | ID | NUM | STRING | '*' ID
        | Expr
        | Expr ',' ParamList
        ;

Assignment: ID '=' Expr                   {printf("Assignment Rule 1 called\n");}
            | ID PAS Expr  
            | ID SAS Expr  
            | ID MAS Expr  
            | ID DAS Expr  
            | '*' ID '=' Expr           
            | '*' ID PAS Expr  
            | '*' ID SAS Expr  
            | '*' ID MAS Expr  
            | '*' ID DAS Expr
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
                     ;
Primary: OPEN_PAR Expr CLOSE_PAR
         | NUM | FLOATNUM | CHARCONST   
         | ID                           {printf("Primary Identifier\n");}
         | '*' ID                       {printf("Pointer Identifier\n");}
         | '&' ID                       {printf("Address of Identifier\n");}
         | '-' Primary
         | ArrayNotation
         | FunctionCall
         | PP ID
         | ID PP
         | MM ID
         | ID MM
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
	| FunctionCall  ';'  
        | Assignment    ';'
        | ReturnStatement                              
	| ';'
        ; 
ReturnStatement: RETURN Expr ';'   {printf("Return Statement Call\n");}
                 | RETURN FunctionCall ';'
                 ;

WhileStatement: WHILE OPEN_PAR Expr CLOSE_PAR Statement                                                        
                | WHILE OPEN_PAR Expr CLOSE_PAR CompoundStatement
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

FunctionCall: ID OPEN_PAR ParamList CLOSE_PAR           {printf("Function Call\n");} 
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
         
void yyerror(const char *s) {
	printf("%d : %s %s\n", lineNo, s, yytext );
}