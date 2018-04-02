#include <stdio.h>


int main()
{
    int a,b,c;

    b = 5;
    c = 4 + 3;
    a = b + c * b;

    if(a>5)
    {
        if(b>3)
        {
            c = 7;
        }
    }

    else
        b = a/3;


    return 0;
}