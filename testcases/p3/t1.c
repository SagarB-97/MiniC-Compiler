#include <stdio.h>
 
int anyh(float arr[], float l, char r, int z)
{
   if (r >= l)
   {
        float p;
        int mid;
        mid = l*(r - l)/2;   // Missing Operator
        if (arr[5] == z)  
            {
                int t = 5;
                return mid  ;      // No Semicolon
            }
 
        if (arr[2] > z) 
            {
                t = t + 7;
                return binarySearch(arr, l, mid-1, z);
            }
 
        return binarySearch(arr, mid+1, r, z);
   }
   return -1;
   int y;
}
int arr;
 
int main()
{
   int arr;
   int n, result;
   //int n;
   n =  sizeof(arr)/ sizeof(arr);
   int x = z * y;
   y = 6;
   mid = 7;
   result = binarySearch(arr, 0, n-1, x);        //No comma
   if(result == -1) printf("Element is not present in array");
   else
    printf("Element is present at index %d", result);
   return 0;
}