#include <stdio.h>

// examples for eah conditional macor
// #if
// # ifdef
// ifndef
// #elif
// #else
// #endif

#define PI 3.14159
#define AREA(r) (PI * r * r)

// if-else
#ifndef radius  // if condition
// #define radius 12  // if True
// #define radius 7  // if True
#define radius 2  // if True
#endif  // end of if

// if-elid-else
#if radius > 10  // if
#define radius 10
#elif radius < 5  // else if
#define radius 5
#else  // else
#define radius 7
#endif


int main(){
    printf("Area of circle with radius %d: %f\n", radius, AREA(radius));
}
