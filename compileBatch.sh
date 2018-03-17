rm compiler
yacc -d miniC.y 
lex miniC.l
gcc lex.yy.c y.tab.c -o compiler -ll
./compiler testcases/p3/t1.c