int fn(int a,float b,char h){   // Duplicate Declaration of ID

    int dummy;
    return dummy; // Wrong Return
                // Missing return

}
int main(){
    int a,b,c;
    int x;         // Void variable
    int arr[20];    // Array size less than 1
    float floatVar;
    floatVar = 6.0;

    int h = fn(2,2.6,'h'); // Wrong parameters
    fn(a,floatVar,'a');                  // Wrong number of parameters

    int y = 8;
    //int a;          // Duplicate Declaration

    arr[1] = 18;       // Array id has no subscript
    b = 5;       // Normal variable has array subscript
    arr[4] = 6;   // Float array subscript

    a = b + 6;   // Wrong expression
    //dummy = 6.8;        // Variable not declared in scope

    if(1){
        int intVarInScope;
        intVarInScope = 42;
    }
    //intVarInScope = 2;    //Variable out of scope

    //Missing return
    return 0;
}