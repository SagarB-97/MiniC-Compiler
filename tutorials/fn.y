%token ID NUM

%{
    #include <stdio.h>
%}

%%
    ED: E {printf("Valid Expression: ");}
    ;
    E:    E '+' E
        | E '*' E
        | E '/' E
        | '(' E ')'
        | ID
        | NUM
        ;
%%

void yyerror()
{
    printf("Invalid expression");
}

int main()
{
    printf("Enter expression: ");
    yyparse();
}
