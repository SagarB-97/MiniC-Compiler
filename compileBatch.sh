yacc -d miniC.y -Wnone
lex miniC.l
gcc lex.yy.c y.tab.c -o compiler