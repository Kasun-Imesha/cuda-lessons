#include <stdio.h>

int main() {
    float f = 66.78;
    printf("f: %.2f\n", f);
    int i = (int)f;  // rounded down since decimal is truncated
    printf("i: %d\n", i);

    char c = (char)i;
    printf("c: %c\n", c);   // Outputs ASCII value of i -> https://www.asciitable.com/
}