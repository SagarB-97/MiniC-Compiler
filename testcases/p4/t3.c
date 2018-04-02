#include <stdio.h>


int main()
{
    int a,b,c,d;

    b = 5;
    c = 4 + 3;
    a = b + c * b;

    if(a>5)
    {
        if(b>3)
        {
            if(c > 4)
            {
                a = 5;
            }
            c = 9;
            a = 7;
        }
        a = 8;
    }
    d = 8;

    return 0;
}