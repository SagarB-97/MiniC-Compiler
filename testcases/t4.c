#include<stdio.h>

// T4
/*
Suppport extended for :
    - Combined declaration and definition of arrays
    - Array subscript operator ([])
Errors :
    - Unbalanced braces
    - Extra comment closing token
*/
*/

int main()
{
    int arr[3] = {-1,0,9};
    {
        printf("t4s");

    int search;
    printf("Enter a number to search : ");
    scanf("%d", &search);

    int l = 0,r = 2;
    while(l<=r){
        int mid = (l+r)/2;
        if(arr[mid] == search)
            break;
        else if(arr[mid]<search)
            r = mid - 1;
        else
            l = mid + 1;
    }
    return 0;
}