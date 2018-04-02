int main(){
    int a,b,c,d;

    a = 4;
    b = 6;
    c = 8;
    d = 10;
    
    // d = a+b*c+d;
    // d = (a+b)*(c+d);

    // d = a>b||c>d;
    d = a>(b||c)>d;
    return 0;
}