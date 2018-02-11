// T3

/*
    Errors include:
-   Missing paranthesis
-   Missing brace
-   Missing square bracket
-   Invalid operator

*/


#include <stdio.h>
#include <math.h>
 
void insertionSort(int arr[], int n )        //Missing paranthesis
{
   int i, key, j;
   for (i = 1; i < n; i+=1)
   {
       key = arr[i];
       j = i-1;
 
       while (j >= 0 && arr[j] > key)
        {                                    //Missing brace
           arr[j+1] = arr[j];
           j = j-1;
       }
       arr[j+1] = key;                       //Missing square bracket
   }
}
 
void printArray(int arr[], int n)
{
   int i;
   for (i=0; i < n; i+=1)                   //Invalid operator
       printf("%d ", arr[i]);
   printf("\n");
}
 
int main()
{
    int arr[10],n = 5 + x/2 - z--;
    n = sizeof(arr)/sizeof(arr[0]);
 
    insertionSort(arr, n);
    printArray(arr, n);
 
    return 0;
}