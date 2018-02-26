yacc -d miniC.y 
lex miniC.l
gcc lex.yy.c y.tab.c -o compiler -ll