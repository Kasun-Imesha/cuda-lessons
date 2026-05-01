// void pointers
#include <stdio.h>

int main(){
    int num = 10;
    float fnum = 3.14;
    void* vptr;

    vptr = &num;
    printf("Integer: %d\n", *(int*)vptr); 
    // void pointer can hold pointer to any datatype.
    // but we can't dereference a void pointer directly.
    // first we need to cast it to corresponding datatype pointer and then dereference that pointer
    // (int*) -> cast to int pointer

    vptr = &fnum;
    printf("Float: %.2f\n", *(float*)vptr);
    // void pointers are used when we don't know the data type of the memory address
    // fun fact: malloc() returns a void pointer but we see it as a pointer to a specific data type after the cast (int*)malloc(4) or (float*)malloc(4) etc.
}