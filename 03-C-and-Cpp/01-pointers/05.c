#include <stdio.h>

int main(){
    int arr[] = {1, 5, 8, 2, 6};
    printf("arr: %p\n", arr);  // arr alone (if we do not index) is just a pointer pointing to the 1st element of the array

    int* ptr = arr;  // ptr points to the first element of arr (default in C)

    for(int i=0; i < 5; i++) {
        printf("%d\t", *ptr);
        printf("%p\n", ptr);
        ptr++;
    }

    /* output:
    arr: 0x7fff044316c0
    1       0x7fff044316c0
    5       0x7fff044316c4
    8       0x7fff044316c8
    2       0x7fff044316cc
    6       0x7fff044316d0
    */

    // notice that the pointer is incremented by 4 bytes (size of int = 4 bytes * 8 bits/bytes = 32 bits = int32) each time. 
    // ptrs are 64 bits in size (8 bytes). 2**32 = 4,294,967,296 ~ 4GB -> can represent memory addresses of only upto 4GB RAM, which is too small given how much memory we typically have.
    // arrays are layed out in memory in a contiguous manner (one after the other rather than at random locations in the memory grid)
}