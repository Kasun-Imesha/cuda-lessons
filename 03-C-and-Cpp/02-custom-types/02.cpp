// exact same as 02.c

 #include <iostream>

using namespace std;

struct Point{
    float x;
    float y;
};

int main(){
    Point p = {1.512, 2.355};
    cout << "(x, y): (" << p.x << ", " << p.y << ")\n";
    cout << "size of Point:" << sizeof(Point) << endl;
}