int find(int x, char z, float t)
{
    int y;
    y = x+5;
    return y;
}

void hello(int x, float y)
{   
    float a;
    a = x + y;
}


int main()
{

    int a,b,c,d;
    int arr[100];

    a = 0;
    d = 6;
    do {
        a = a + arr[a * 2];
        do{
            d = d + 1;
        } while(d<6);
    } while(a<5 && d<6) ;

    // a = 18;
    // while(a<3){
    //     a = a + 2;
    //     while(d<6){
    //         d = d + 9;
    //         if(d == 2 || a == 3){
    //             b++;
    //         }
    //     }
    //     a = 4;
    // }


    find(5,'c', 5.5);
    return 0;
}