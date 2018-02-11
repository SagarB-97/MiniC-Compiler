yacc -d miniC_new.y -Wnone
lex miniC_new.l
gcc lex.yy.c y.tab.c -o compiler