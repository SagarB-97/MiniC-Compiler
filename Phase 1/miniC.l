%{
  int braces = 0, string = 0, comment = 0, lineNo = 1;
  int lastBraceOpen = 1, lastCommentOpen = 1, lastBraceClosed = 1, lastCommentClosed = 1;
  int stringError = 1;
%}
keyword int|float|short|long|unsigned|signed|main|while|for|break|case|if|else|continue|default|do|goto|return|void|struct|switch
number [0-9]
letter [a-zA-Z]
operator [+-<>*=/%,.]

%%
#(.*) printf("PREPROCESSOR\nDIRECTIVE\t\t%s\n\n",yytext);
[\n] {lineNo++;
      printf("%s",yytext);
     }
[{] { braces++;
      printf("LEFT BRACE\t\t%s\n\n",yytext);
      lastBraceOpen=lineNo;
    }
[}] { braces--;
      printf("RIGHT BRACE\t\t%s\n\n",yytext);
      lastBraceClosed=lineNo;
    }
[/][*] {  comment++;
          printf("OPEN COMMENT\t\t%s\n\n",yytext);
          lastCommentOpen = lineNo;
        }
[*][/] {  comment--;
          printf("CLOSE COMMENT\t\t%s\n\n",yytext);
          lastCommentClosed = lineNo;
       }
\"[^"\n]*["\n] {  if(yytext[yyleng-1]!='"'){
                    string = 1;
                    stringError = lineNo;
                    printf("Error : Quote unbalanced at line number %d\n",stringError);
                  }
                  printf("STRING\t\t\t%s\n\n",yytext);
               }
{keyword} printf("KEYWORD\t\t\t%s\n\n",yytext);
\/\/ {;}
[(] printf("OPEN PARANTHESIS\t%s\n\n",yytext);
[)] printf("CLOSE PARANTHESIS\t%s\n\n",yytext);
[\t\n ] ;
[;] {printf("SEMICOLON\t\t%s\n\n",yytext);}
{number}+ {printf("NUMBER\t\t\t%s\n\n",yytext);}
(_|{letter})({letter}|{number}|_)* {printf("IDENTIFIER\t\t%s\n\n",yytext);}
{operator} printf("OPERATOR\t\t%s\n\n",yytext);
%%

int yywrap(){
  return 1;
}

int main(){
  yyin = fopen("samp_input.c", "r");
  printf("\n\nToken Type\t\tToken Value\n");
  printf("-------------------------------------\n\n");
  yylex();
  if(braces>0)
    printf("Error : Brace at line Number %d not balanced\n",lastBraceOpen);
  if(braces<0)
    printf("Error : Extra right brace at line number %d\n",lastBraceClosed);
  if(comment>0)
    printf("Error : Comment opened at Line Number %d not closed\n", lastCommentOpen);
  if(comment<0)
    printf("Error : Extra comment close at Line number %d\n", lastCommentClosed);

  printf("\n\n");
  return 0;
}
