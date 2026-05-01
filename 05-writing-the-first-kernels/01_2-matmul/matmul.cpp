#include<iostream>
#include <cstdlib>

using namespace std;


int main() {
    const int M = 3, N = 4, K = 2;
    size_t bytes_A = M * K * sizeof(float), bytes_B = K * N * sizeof(float), bytes_C = M * N * sizeof(float);

    float *h_A = (float*)malloc(bytes_A), *h_B = (float*)malloc(bytes_B), *h_C = (float*)malloc(bytes_C);
    
    for (int i=0; i < M * K; i++) h_A[i] = i * 1.0f;
    for (int i=0; i < K * N; i++) h_B[i] = 1.0f;

    for (int row=0; row<M; row++){
        for (int col=0; col<N; col++){
            float sum = 0.0f;
            for (int d=0; d<K; d++){
                // (row, d) x (d, col) -> (row x K + d) x (d x )
                sum += h_A[row * K + d] * h_B[d * N + col];  
            }
            h_C[row * N + col] = sum;
        }
    }

    for (int row=0; row<M; row++){
        for (int col=0; col<N; col++){
            cout << h_C[row * N + col] << " ";
        }
        cout << endl;
    }

    free(h_A); free(h_B); free(h_C);
    return 0;
}