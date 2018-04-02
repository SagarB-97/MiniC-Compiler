#include <stdio.h>

void hello(int x, float y)
{   
    float a;
    a = x + y;
}

int main()
{
    int a,b,c,d;

    b = 5;
    c = 4 + 3;
    a = b + c;
    d = 6;

    while(a>5)
    {
        a = a * b * c;
        while(b>d || a>c){
            hello(5,5.36);
        }
    }



    return 0;
}