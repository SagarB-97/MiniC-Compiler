rm compiler
yacc -d miniC.y -Wnone
lex miniC.l
g++ lex.yy.c y.tab.c -o compiler -ll
./compiler testcases/p4/t1.c