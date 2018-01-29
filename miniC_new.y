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
%token NUM ID
%token INCLUDE

%right '='
%left AND OR
%left LE GE EQ NE LT GT 
%left '+' '-' '*' '/' '%' '^' '!' '&' '.'
%start start

%% 
start:	Function 
	    | Declaration
        | Include
        | start Function
        | start Declaration
	    ;





