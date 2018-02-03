#include <stdio.h>

// T3
/*
Extended support for datatypes :
    - short and long int
    - float
Added support for while loop
Errors include :
    - Unclosed comment
*/
int main()
{
    short int a = 10;
    long long b = 5, c;
    float floatVar1 = 2.3, floatVar2 = 2.5e3;
    c = a + b;

    while(a){
        printf("sum = %d\n", c);
        a = a-1;
    }

    printf("Enter a number : ");
    scanf("%d",&a);

    while(a){
        printf("%d\n",a);
        a = a - 1;
    }
}
/* Hello this is a sample comment