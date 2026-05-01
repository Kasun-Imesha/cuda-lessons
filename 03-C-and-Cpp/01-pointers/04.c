#include <stdio.h>
#include <stdlib.h>

int main(){
    int* ptr = NULL;
    printf("1. Initial ptr value: %p\n", (void*)ptr);
    
    if(ptr == NULL){
        printf("2. ptr is NULL, cannot deference\n");
    }

    // allocate memory
    ptr = malloc(sizeof(int));
    if(ptr == NULL){
        printf("3. Memory allocation failed\n");
        return 1;
    }

    printf("4. After allocatio ptr value: %p\n", (void*)ptr);
    
    // safe to use ptr after NULL check
    *ptr = 42;
    printf("5. Value t ptr: %d\n", *ptr);

    // clean up
    free(ptr);
    ptr = NULL; // set to NULL after freeing

    printf("6. After freeing, ptr value: %p\n", (void*)ptr);

    if (ptr == NULL){
        printf("7. ptr is NULL, safely avoded use after freeing\n");
    }

    return 0;
}