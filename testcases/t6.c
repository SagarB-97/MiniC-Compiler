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
            g=g-1;
        }
        f=f-1;
    }
    if(f){
        g=g-1;
        if(g){
            f=f+1;
        }
        else{
            g=g+1;
        }
    }
    return 0;
}