int fn(int a,float b,char h){   // Duplicate Declaration of ID

    int dummy;
    return dummy; // Wrong Return
                // Missing return

}
int main(){
    int a,b,c;
    void x;         // Void variable
    int arr[2];    // Array size less than 1
    float floatVar;
    floatVar = 6.0;

    int h = fn(2,'h',2.6); // Wrong parameters
    fn(a);                  // Wrong number of parameters

    y = 8;
    int a;          // Duplicate Declaration

    arr = 18;       // Array id has no subscript
    b[8] = 5;       // Normal variable has array subscript
    arr[4.2] = 6;   // Float array subscript

    a = floatVar + 6;   // Wrong expression
    dummy = 6.8;        // Variable not declared in scope

    if(1){
        int intVarInScope;
        intVarInScope = 42;
    }
    intVarInScope = 2;    //Variable out of scope

    //Missing return
}