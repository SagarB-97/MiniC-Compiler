yacc -d miniC_new.y -v -Wnone
lex miniC_new.l
gcc lex.yy.c y.tab.c -o compiler