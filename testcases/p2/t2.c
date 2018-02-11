//T2
/*
Errors include :
 - Missing semicolon
 - Missing operator
- Invalid function call
*/

#include <stdio.h>
 
int binarySearch(int arr[], int l, int r, int x)
{
   if (r >= l)
   {
        int mid;
        mid = l*(r - l)/2;   //Missing operator
 
        if (arr[mid] == x)  
            return mid ;         // No Semicolon
 
        if (arr[mid] > x) 
            return binarySearch(arr, l, mid-1, x);
 
        return binarySearch(arr, mid+1, r, x);
   }

   return -1;
}
 
int main()
{
   int arr[10];
   int n, x, result;
   n =  sizeof(arr)/ sizeof(arr[0]);
   x = 10;
   result = binarySearch(arr, 0, n-1, x);        //No comma
   if(result == -1) printf("Element is not present in array");
   else
    printf("Element is present at index %d", result);
   return 0;
}