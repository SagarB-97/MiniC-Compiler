yacc -d miniC_new.y
lex miniC_new.l
gcc lex.yy.c y.tab.c -o compiler
./compiler testcases/p2/t1.c