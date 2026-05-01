#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <cuda_runtime.h>

#define M 256
#define K 512
#define N 256
#define BLOCK_SIZE 32


void matmul_cpu(float *A, float *B, float *C, int m, int k, int n) {
    for (int i=0; i < m; i++) {
        for (int j=0; j < n; j++) {
            float sum = 0.0f;
            for (int l=0; l < k; l++) {
                sum += A[i * k + l] * B[l * n + j];
            }
            C[i * n + j] = sum;
        }
    }
}

__global__ void matmul_gpu(float *A, float *B, float *C, int m, int k, int n) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    if (row < m && col < n) {
        float sum = 0.0f;
        for (int l=0; l < k; l++) {
            sum += A[row * k + l] * B[l * n + col];
        }
        C[row * n + col] = sum;
    }
}

void init_matrix(float *mat, int rows, int cols) {
    for (int i=0; i < rows * cols; i++) {
        mat[i] = (float)rand() / RAND_MAX;
    }
}

double get_time() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);

    return ts.tv_sec + ts.tv_nsec * 1e-9;
}

int main() {
    float *h_A, *h_B, *h_C_cpu, *h_C_gpu;
    float *d_A, *d_B, *d_C;
    int size_A = M * K * sizeof(float);
    int size_B = K * N * sizeof(float);
    int size_C = M * N * sizeof(float);

    // allocate ost memory
    h_A = (float*)malloc(size_A);
    h_B = (float*)malloc(size_B);
    h_C_cpu = (float*)malloc(size_C);
    h_C_gpu = (float*)malloc(size_C);

    // initialize matrices
    srand(time(NULL));
    init_matrix(h_A, M, K);
    init_matrix(h_B, K, N);

    // allocate device memory
    cudaMalloc(&d_A, size_A);
    cudaMalloc(&d_B, size_B);
    cudaMalloc(&d_C, size_C);

    // copy data to device
    cudaMemcpy(d_A, h_A, size_A, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, size_B, cudaMemcpyHostToDevice);

    // define grid and block sizes
    dim3 blockDim(BLOCK_SIZE, BLOCK_SIZE);
    dim3 gridDim((N * BLOCK_SIZE - 1) / BLOCK_SIZE, (M + BLOCK_SIZE - 1) / BLOCK_SIZE);

    // warm-up runs
    printf("Performing warm-up runs...\n");
    for (int i=0; i < 3; i++) {
        matmul_cpu(h_A, h_B, h_C_cpu, M, K, N);
        matmul_gpu <<< gridDim, blockDim >>> (d_A, d_B, d_C, M, K, N);
        cudaDeviceSynchronize(); // sync barrier
    }

    // benchmarking CPU implementation
    printf("Benchmarking CPU implementation...\n");
    double total_cpu_time = 0.0;
    for (int i = 0; i < 20; i++) {
        double start_time = get_time();
        matmul_cpu(h_A, h_B, h_C_cpu, M, K, N);
        double end_time = get_time();
        total_cpu_time += (end_time - start_time);
    }
    double avg_cpu_time = total_cpu_time / 20.0;

    // benchmarking GPU implementation
    double total_gpu_time = 0.0;
    for (int i = 0; i < 20; i++) {
        double start_time = get_time();
        matmul_gpu <<< gridDim, blockDim >>> (d_A, d_B, d_C, M, K, N);
        cudaDeviceSynchronize();
        double end_time = get_time();
        total_gpu_time += (end_time - start_time);
    }
    double avg_gpu_time = total_gpu_time / 20.0;

    printf("CPU avg time: %f us\n", avg_cpu_time * 1e6f);
    printf("CPU avg time: %f us\n", avg_gpu_time * 1e6f);
    printf("Speedup: %fx\n", (avg_cpu_time / avg_gpu_time));

    // verify results
    cudaMemcpy(h_C_gpu, d_C, size_C, cudaMemcpyDeviceToHost);
    bool correct = true;
    for (int i = 0; i < M * N; i++) {
        if (fabs(h_C_cpu[i] - h_C_gpu[i]) > 1e-4) {
            printf("Index: %d - CPU: %f != GPU: %f\n", i, h_C_cpu[i], h_C_gpu[i]);
            correct = false;
            break;
        }
    }
    printf("The results are %s\n", correct ? "correct" : "incorrect");

    // free memory
    cudaFree(d_A); cudaFree(d_C); cudaFree(d_C); 
    free(h_A); free(h_B); free(h_C_cpu); free(h_C_gpu);
    
    return 0;
}