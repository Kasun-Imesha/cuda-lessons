#include <stdio.h>
#include <cuda_runtime.h>

__global__ void matmulNaive(float* C, const float* A, const float* B, int M, int N, int K) {
    int row = blockIdx.y * blockDim.y + threadIdx.y; 
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    if (row < M && col < N) {
        float sum = 0.0f;
        for (int k=0; k < K; k++) {
            sum += A[row * K + k] * B[k * N + col];
        }
        C[row * N + col] = sum;
    }
}


int main() {
    /*
    A -> M x K , B -> K x N
    */
    const int M = 1024, N = 1024, K = 1024;
    size_t bytes_A = M * K * sizeof(float), bytes_B = K * N * sizeof(float), bytes_C = M * N * sizeof(float);
    
    float *h_A = (float*)malloc(bytes_A), *h_B = (float*)malloc(bytes_B), *h_C = (float*)malloc(bytes_C);
    for (int i = 0; i < M * K; i++) h_A[i] = 1.0f;
    for (int i = 0; i < K * N; i++) h_B[i] = 1.0f;

    float *d_A, *d_B, *d_C;
    // device (GPU) memory allocation
    cudaMalloc(&d_A, bytes_A); // cudaMalloc writes the allocated GPU memory `address` into dev_a
    cudaMalloc(&d_B, bytes_B);
    cudaMalloc(&d_C, bytes_C);

    // data copy host -> device
    cudaMemcpy(d_A, h_A, bytes_A, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, bytes_B, cudaMemcpyHostToDevice);

    dim3 threadsPerBlock(16, 16);
    /*
    The followings are the same in C++. 
    They are calling the constructr of dim3.
    1. dim3 threadsPerBlock(16, 16);       // constructor call syntax
    2. dim3 threadsPerBlock = dim3(16, 16); // explicit constructor
    3. dim3 threadsPerBlock = {16, 16};     // initializer list syntax
    */
    dim3 numBlocks((N + 15) / 16, (M + 15) / 16);
    // launch the kernel
    matmulNaive <<< numBlocks, threadsPerBlock >>> (d_C, d_A, d_B, M, N, K);

    // data copy device -> host
    cudaMemcpy(h_C, d_C, bytes_C, cudaMemcpyDeviceToHost);

    printf("Naive MatMul: %d x %d x %d\n", M, K, N);
    printf("Verification: c[0] = %.1f\n", h_C[0]);


    // free memory
    cudaFree(d_A); cudaFree(d_B); cudaFree(d_C);
    free(h_A); free(h_B); free(h_C);

}