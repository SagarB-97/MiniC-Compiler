%token ID NUM

%{
    #include <stdio.h>
%}

%%
    ED: E {printf("Valid Expression\n\n");}
    ;
    E:    E '+' E
        | E '*' E
        | E '/' E
        | E '-' E
        | '(' E ')'
        | ID
        | NUM
        ;
%%

void yyerror()
{
    printf("Invalid expression\n\n");
}

int main()
{
    printf("Enter expression: ");
    yyparse();
}
