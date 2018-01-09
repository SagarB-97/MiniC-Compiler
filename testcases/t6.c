#include <stdio.h


int main()
{
    short int f = 5, g = 5;

    while(f>0)
    {
        {
        g = 5;
        while(g > 0)
        {
            g--;
        }
        f--;
    }

    return 0;
}