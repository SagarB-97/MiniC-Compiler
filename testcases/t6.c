#include <stdio.h>

// T6
/*
Support extended for :
    - Nested while loops
    - If conditional statements
    - Nested conditional statemets
*/


int main()
{
    short int f = 5, g = 5;

    while(f>0)
    {
        g = 5;
        while(g > 0)
        {
            g--;
        }
        f--;
    }
    if(f==5){
        g++;
        if(g==6){
            f++;
        }
        else{
            g++;
        }
    }
    return 0;
}