#include <stdio.h>

typedef struct{
    float x;
    float y;
} Point;

int main(){
    Point p = {1.5, 2.3};
    printf("(y, y): (%.1f, %.1f)\n", p.x, p.y);
    // printf("(y, y): (%f, %f)\n", p.x, p.y);
    printf("size of Point: %zu\n", sizeof(Point));  // Output: 8 bytes = 4 bytes (float x) + 4 bytes (float y)
}