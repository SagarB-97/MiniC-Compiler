rm lex.yy.c y.tab.h y.tab.c compiler

yacc -d miniC_new.y
lex miniC_new.l
gcc lex.yy.c y.tab.c -o compiler
./compiler testcases/p1/t1.c