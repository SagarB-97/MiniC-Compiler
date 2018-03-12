%{

    #define DEBUG 0

    #if defined(DEBUG) && DEBUG > 0
        #define DEBUG_PRINT(fmt, args...) fprintf(stderr, fmt, ##args)
    #else
        #define DEBUG_PRINT(fmt, args...) /* Don't do anything in release builds */
    #endif

    #define RED   "\x1B[31m"
    #define RESET "\x1B[0m"
    #define GRN   "\x1B[32m"
    #define BLU   "\x1B[34m"

    #include "y.tab.h"

    void insertScope(int*);
    int findParentScope(int);
    int lineNo = 1;
    int comment = 0;
    int curScope = 0;
%}

keyword         char|int|float|short|long|unsigned|signed|main|while|for|break|case|if|else|continue|default|do|return|void|struct|switch
number          [0-9]
letter          [a-zA-Z]
operator        [+-<>*=/!%^&.]
function        (_|{letter})({letter}|{number}|_)*"()"


%%
\/\/(.)*[\n]                        {lineNo++;}

[/][*]                              { DEBUG_PRINT("%-20s%20s%20d\n", "OPEN COMMENT",yytext, lineNo); comment++; }
[*][/]                              { DEBUG_PRINT("%-20s%20s%20d\n", "CLOSE COMMENT",yytext, lineNo); comment--; }


#                                   { if(!comment){ 
                                            DEBUG_PRINT("%-20s%20s%20d\n","PREPROCESSOR", yytext, lineNo);
                                            return *yytext;  
                                        }
                                    }

include                             { if(!comment){ 
                                            DEBUG_PRINT("%-20s%20s%20d\n","PREPROCESSOR", yytext, lineNo);
                                            return INCLUDE;  
                                        }
                                    }

[\n]                                { lineNo++; }

[{]                                 { if(!comment){
                                            DEBUG_PRINT("%-20s%20s%20d\n","LEFT BRACE", yytext, lineNo);
                                            insertScope(&curScope);
                                            return *yytext;
                                        }  
                                    }
[}]                                 { if(!comment){
                                            DEBUG_PRINT("%-20s%20s%20d\n","RIGHT BRACE", yytext, lineNo);
                                            curScope = findParentScope(curScope);
                                            return *yytext;
                                        }  
                                    }

\"[^"\n]*["\n]                      { if(!comment) {
                                        if(yytext[yyleng-1]!='"'){
                                            DEBUG_PRINT(RED "Error : Quote unbalanced at line number %d\n" RESET,lineNo);
                                            lineNo++;
                                        }
                                        DEBUG_PRINT("%-20s%20s%20d\n", "STRING", yytext, lineNo);
                                        // strcpy(yylval, yytext);
                                        //insertSymbolItem(yytext, "STRING", lineNo, 1);
                                        return STRING;
                                      }
                                    }

int                                 { if(!comment){
                                        DEBUG_PRINT("%-20s%20s%20d\n", "KEYWORD", yytext, lineNo);
										strcpy(yylval.id, yytext);
                                        return INT;
                                      }
                                    }

float                              { if(!comment){
                                        DEBUG_PRINT("%-20s%20s%20d\n", "KEYWORD", yytext, lineNo);
										strcpy(yylval.id, yytext);
                                        return FLOAT;
                                      }
                                    }
char                               { if(!comment){
                                        DEBUG_PRINT("%-20s%20s%20d\n", "KEYWORD", yytext, lineNo);
										strcpy(yylval.id, yytext);
                                        return CHAR;
                                      }
                                    }
double                             { if(!comment){
                                        DEBUG_PRINT("%-20s%20s%20d\n", "KEYWORD", yytext, lineNo);
										strcpy(yylval.id, yytext);
                                        return DOUBLE;
                                      }
                                    }
void                               { if(!comment){
                                        DEBUG_PRINT("%-20s%20s%20d\n", "KEYWORD", yytext, lineNo);
										strcpy(yylval.id, yytext);
                                        return VOID;
                                      }
                                    }
signed                             { if(!comment){
                                        DEBUG_PRINT("%-20s%20s%20d\n", "KEYWORD", yytext, lineNo);
                                        return SIGNED;
                                      }
                                    }
unsigned                           { if(!comment){
                                        DEBUG_PRINT("%-20s%20s%20d\n", "KEYWORD", yytext, lineNo);
                                        return UNSIGNED;
                                      }
                                    }
long                               { if(!comment){
                                        DEBUG_PRINT("%-20s%20s%20d\n", "KEYWORD", yytext, lineNo);
                                        return LONG;
                                      }
                                    }
short                              { if(!comment){
                                        DEBUG_PRINT("%-20s%20s%20d\n", "KEYWORD", yytext, lineNo);
                                        return SHORT;
                                      }
                                    }
switch                             { if(!comment){
                                        DEBUG_PRINT("%-20s%20s%20d\n", "KEYWORD", yytext, lineNo);
                                        return SWITCH;
                                      }
                                    }
break                              { if(!comment){
                                        DEBUG_PRINT("%-20s%20s%20d\n", "KEYWORD", yytext, lineNo);
                                        return BREAK;
                                      }
                                    }
continue                           { if(!comment){
                                        DEBUG_PRINT("%-20s%20s%20d\n", "KEYWORD", yytext, lineNo);
                                        return CONTINUE;
                                      }
                                    }
case                               { if(!comment){
                                        DEBUG_PRINT("%-20s%20s%20d\n", "KEYWORD", yytext, lineNo);
                                        return CASE;
                                      }
                                    }
default                           { if(!comment){
                                        DEBUG_PRINT("%-20s%20s%20d\n", "KEYWORD", yytext, lineNo);
                                        return DEFAULT;
                                      }
                                    }
for                                { if(!comment){
                                        DEBUG_PRINT("%-20s%20s%20d\n", "KEYWORD", yytext, lineNo);
                                        return FOR;
                                      }
                                    }
while                              { if(!comment){
                                        DEBUG_PRINT("%-20s%20s%20d\n", "KEYWORD", yytext, lineNo);
                                        return WHILE;
                                      }
                                    }
do                                 { if(!comment){
                                        DEBUG_PRINT("%-20s%20s%20d\n", "KEYWORD", yytext, lineNo);
                                        return DO;
                                      }
                                    }
if                                 { if(!comment){
                                        DEBUG_PRINT("%-20s%20s%20d\n", "KEYWORD", yytext, lineNo);
                                        return IF;
                                      }
                                    }
else                               { if(!comment){
                                        DEBUG_PRINT("%-20s%20s%20d\n", "KEYWORD", yytext, lineNo);
                                        return ELSE;
                                      }
                                    }
struct                             { if(!comment){
                                        DEBUG_PRINT("%-20s%20s%20d\n", "KEYWORD", yytext, lineNo);
                                        return STRUCT;
                                      }
                                    }
return                             { if(!comment){
                                        DEBUG_PRINT("%-20s%20s%20d\n", "KEYWORD", yytext, lineNo);
                                        return RETURN;
                                      }
                                    }
                                                                                                            

[(]                                 { if(!comment) {
                                            DEBUG_PRINT("%-20s%20s%20d\n", "OPEN PARANTHESIS", yytext, lineNo);
                                            return OPEN_PAR;
                                        }
                                    }

[)]                                 { if(!comment) {
                                            DEBUG_PRINT("%-20s%20s%20d\n", "CLOSE PARANTHESIS", yytext, lineNo);
                                            return CLOSE_PAR;
                                        }
                                    }
[\[]                                { if(!comment) {
                                            DEBUG_PRINT("%-20s%20s%20d\n", "SQUARE BRACKETS", yytext, lineNo);
                                            return *yytext;
                                        } 
                                    }

[\]]                                { if(!comment) {
                                            DEBUG_PRINT("%-20s%20s%20d\n", "SQUARE BRACKETS", yytext, lineNo);
                                            return *yytext;
                                        } 
                                    }

[,]                                 { if(!comment) {
                                            DEBUG_PRINT("%-20s%20s%20d\n", "COMMA", yytext, lineNo);
                                            return *yytext;
                                        } 
                                    } 


[\t ]                               { ; }

[;]                                 { if(!comment) {
                                            DEBUG_PRINT("%-20s%20s%20d\n", "SEMI COLON", yytext, lineNo);
                                            return *yytext;
                                        } 
                                    }

\'.\'                               { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "CHARACTER", yytext, lineNo); 
                                        //insertSymbolItem(yytext, "CHARACTER", lineNo, 1);
                                        // strcpy(yylval, yytext);
                                        return CHARCONST;
                                        }
                                    }

{number}+(\.{number}+)?e{number}+    { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "FLOAT EXP FORM", yytext, lineNo); 
                                        //insertSymbolItem(yytext, "FLOAT", lineNo, 1);
                                        // yylval = atof(yytext);
                                        return FLOATNUM;
                                        }
                                    } 

{number}+\.{number}+                { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "FLOAT NUMBER", yytext, lineNo); 
                                        //insertSymbolItem(yytext, "FLOAT", lineNo, 1);
                                        //yylval = atof(yytext);
                                        return FLOATNUM;
                                        }
                                    } 


{number}+                           { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "NUMBER", yytext, lineNo); 
                                        //insertSymbolItem(yytext, "INTEGER", lineNo, 1);
                                       // yylval = atoi(yytext);
                                        return NUM;
                                        }
                                    }    

(_|{letter})({letter}|{number}|_)*  { if(!comment){
                                        DEBUG_PRINT("%-20s%20s%20d\n", "IDENTIFIER", yytext, lineNo);
                                        /*if(!lookUpSymbolItem(yytext))
                                            insertSymbolItem(yytext, "IDENTIFIER", lineNo, 0);*/
									
                                        strcpy(yylval.id, yytext);
                                        return ID;
                                      }
                                    }

"+"                                 { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return *yytext;
                                        }                   
                                    }
"-"                                 { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return *yytext;
                                        }                   
                                    }
"*"                                 { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return *yytext;
                                        }                   
                                    }
"/"                                 { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return *yytext;
                                        }                   
                                    }

"%"                                 { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return *yytext;
                                        }                   
                                    }

"^"                                 { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return *yytext;
                                        }                   
                                    }

"&"                                 { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return *yytext;
                                        }                   
                                    }
"."                                 { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return *yytext;
                                        }                   
                                    }
"=="                                 { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return EQ;
                                        }                   
                                    }
"="                                 { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return *yytext;
                                        }                   
                                    }
"!="                                 { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return NE;
                                        }                   
                                    }
"<"                                 { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return LT;
                                        }                   
                                    }
">"                                 { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return GT;
                                        }                   
                                    }
"<="                                 { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return LE;
                                        }                   
                                    }

"+="                                { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return PAS;
                                        }                   
                                    }

"-="                                { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return SAS;
                                        }                   
                                    }

"*="                                { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return MAS;
                                        }                   
                                    }
                                    
"/="                                { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return DAS;
                                        }                   
                                    }
">="                                 { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return GE;
                                        }                   
                                    }
"&&"                                 { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return AND;
                                        }                   
                                    }
"||"                                 { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return OR;
                                        }                   
                                    }
"!"                                 { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return NOT;
                                        }                   
                                    }
  
"++"                                 { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return PP;
                                        }                   
                                    }  
"--"                                 { if(!comment) {
                                        DEBUG_PRINT("%-20s%20s%20d\n", "OPERATOR", yytext, lineNo); 
                                        return MM;
                                        }                   
                                    }  
                                                                      



{number}({letter}|{number}|_)+      { if(!comment) DEBUG_PRINT(RED "Error : Invalid Token %s at Line %d\n" RESET, yytext, lineNo); }

.                                   { if(!comment) DEBUG_PRINT(RED "Error : Invalid Token %s at Line %d\n" RESET, yytext, lineNo); }

%%


int yywrap(){
  return 1;
}
/*
int main(int argc, char** argv){
    if(argc < 2){
        DEBUG_PRINT(RED "Pass input file as command line argument\n" RESET);
        exit(0);
    }
    initSymbolTable();
    yyin = fopen(argv[1], "r");
    DEBUG_PRINT("\n\n-----------------------------------------------------------------\n");
    DEBUG_PRINT(BLU "%-20s%20s%24s\n", "TOKEN VALUE", "TOKEN TYPE", "LINE NUMBER" RESET);
    DEBUG_PRINT("-----------------------------------------------------------------\n");
    yylex();

    if(comment)
        DEBUG_PRINT(RED "Error : Error in parsing comments" RESET);

    DEBUG_PRINT(GRN "\n\nSYMBOL TABLE" RESET);
    showSymbolTable();
    DEBUG_PRINT(GRN "\n\nCONSTANT TABLE" RESET);
    showConstantTable();
    DEBUG_PRINT("\n\n");
}
*/

