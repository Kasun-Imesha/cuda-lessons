#include <stdio.h>

// matrix -> arr -> integers
// similar to 01.c but with arrays

int main() {
    int arr1[] = {4, 3, 2, 1};
    int arr2[] = {8, 7, 6, 5};

    int* ptr1 = arr1;
    int* ptr2 = arr2;

    int* matrix[] = {ptr1, ptr2};

    for(int i=0; i < 2; i++){
        for(int j=0; j < 4; j++){
            printf("%d", *matrix[i]++);
            // printf("%d", *(matrix[i] + j));  // this also does the same thing
        }
        printf("\n");
    }
}