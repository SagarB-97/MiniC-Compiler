#include <stdio.h>
 
int anyh(int arr, int l, int r, int z)
{
   if (r >= l)
   {
        int mid;
        mid = l*(r - l)/2;   // Missing Operator
 
        if (arr == z)  
            {
                return mid  ;      // No Semicolon
            }
 
        if (arr > z) 
            {
                return binarySearch(arr, l, mid-1, z);
            }
 
        return binarySearch(arr, mid+1, r, z);
   }

   return -1;
}
 
int main()
{
   int arr;
   int n, x, result;
   int x;
   //int n;
   n =  sizeof(arr)/ sizeof(arr);
   x = 10;
   y = 6;
   mid = 7;
   result = binarySearch(arr, 0, n-1, x);        //No comma
   if(result == -1) printf("Element is not present in array");
   else
    printf("Element is present at index %d", result);
   return 0;
}