#include <stdio.h>

// T5
/*
Errors include :
    - Unbalanced quotes
*/
void main()
{
    char x = 'g', y, z;
    scanf("%c %c",&x, &y);
    z = x + y;

    printf("Result = %c", z);
}