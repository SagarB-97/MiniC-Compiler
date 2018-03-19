rm compiler
yacc -d miniC.y -Wnone
lex miniC.l
gcc lex.yy.c y.tab.c -o compiler -ll
./compiler testcases/p3/test_correct.c