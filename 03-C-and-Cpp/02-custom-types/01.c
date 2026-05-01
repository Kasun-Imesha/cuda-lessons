// size_t = size type for memory allocation
// size_t is an unsigned integer data type used to represent the size of objects in bytes. 
// It is guaranteed to be big enough to contain the size of the biggest object the host system can handle.
// i.e. size_t  can hold 2^64 values (8 bytes -> 64 bits) whch is a really large value

// in vscode, ctrl + right click or F12 to see the definition of a function or a type
// nothing special about size_t, it's just a typedef for unsigned long long int


#include <stdio.h>
#include <stdlib.h>

int main(){
    int arr[] = {10, 20, 30, 40, 50};

    // size_t
    size_t size = sizeof(arr) / sizeof(arr[0]);
    printf("Size of arr: %zu\n", size);  // Output: 5
    printf("size of size_t: %zu\n", sizeof(size_t));  // Output: 8 (bytes) -> 64 bits which is memory safe
    printf("int size in bytes: %zu\n", sizeof(int)); // Output: 4 (bytes) -> 32 bits

    // z -> size_t
    // u -> unsigned int
    // %zu -> size_t
    // src: https://cplusplus.com/reference/cstdio/printf/

    return 0;
}