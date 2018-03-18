#include <stdio.h>

float fn(int a,char c){
    a = 4;
    int arr[4];

    void f;
    arr = 5;
    c = 'a';

    int i;
    for(i=0;i<=a;i++){
        a++;
    }    
    a = a%i;
    
    float b;
    b = 4.5;
    return b;
}
int main(){
    float res;
    int a;
    char c;

    a = 5;
    c = 'h';
    a = fn(a,c);

    float myVar;

    myVar = fn(a,c) + 7.5 + fn(a,c);

    return 0;
}
