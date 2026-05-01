#include <stdio.h>

int main(){
    int val = 42;
    int* ptr1 = &val;
    int** ptr2 = &ptr1;
    int*** ptr3 = &ptr2;

    printf("Value: %d\n", ***ptr3);
}