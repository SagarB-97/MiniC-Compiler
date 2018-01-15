%{
    #include "y.tab.h"
%}

letter  [a-zA-Z]
digit   [0-9]
ID      {letter}({letter}|{digit})*
num     {digit}

%%
{ID}    return ID;
{num}   return NUM;
.       return yytext[0];
\n      return 0;
%%

