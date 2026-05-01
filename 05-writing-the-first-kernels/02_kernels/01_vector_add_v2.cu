#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <cuda_runtime.h>
#include <math.h>
#include <iostream>

#define N 10000000 // vector size = 10 million
#define BLOCK_SIZE_1D 1024
#define BLOCK_SIZE_3D_X 16
#define BLOCK_SIZE_3D_Y 8
#define BLOCK_SIZE_3D_Z 8
// 16 x 8 x 8 = 1024

// cpu vector addition
void vector_add_cpu(float *a, float *b, float *c, int n){
    for (int i=0; i < n; i++) {
        c[i] = a[i] + b[i];
    }
}

// cuda kernel for 1D vector addition
__global__ void vector_add_gpu_1d(float *a, float *b, float *c, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    // one add, one multiply, one store
    if (i < n) {
        c[i] = a[i] + b[i];
        // one add, one store
    }
}

// cuda kernel for vector add 3D
__global__ void vector_add_gpu_3d(float *a, float *b, float *c, int nx, int ny, int nz) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;
    int k = blockIdx.z * blockDim.z + threadIdx.z;
    // 3 adds, 3 multiplies, 3 stores

    if (i < nx && j < ny && k < nz) {
        int idx = i + j * nx + k * nx * ny;
        if (idx < nx * ny * nz) {
            c[idx] = a[idx] + b[idx];
        }
    }
    // 3 adds, 5 multiplies, 2 stores
}

// initialize vectors with random values
void init_vector(float *vec, int n){
    for (int i=0; i < n; i++) {
        vec[i] = (float)rand() / RAND_MAX;
    }
}

// function to measure execution time
double get_time() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec + ts.tv_nsec * 1e-9;
}

int main() {
    float *h_a, *h_b, *h_c_cpu, *h_c_gpu_1d, *h_c_gpu_3d;
    float *d_a, *d_b, *d_c_1d, *d_c_3d;

    size_t size = N * (sizeof(float));

    // allocate host memory
    h_a = (float*)malloc(size);
    h_b = (float*)malloc(size);
    h_c_cpu = (float*)malloc(size);
    h_c_gpu_1d = (float*)malloc(size);
    h_c_gpu_3d = (float*)malloc(size);

    // initialize vectors
    srand(time(NULL)); // srand -.> seed random -> Use the current time as the seed for randomness
    // Without srand() -> same playlist every time
    init_vector(h_a, N);
    init_vector(h_b, N);

    // allocate device memory
    cudaMalloc(&d_a, size);
    cudaMalloc(&d_b, size);
    cudaMalloc(&d_c_1d, size);
    cudaMalloc(&d_c_3d, size);

    // copy data to device
    cudaMemcpy(d_a, h_a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, size, cudaMemcpyHostToDevice);

    // define grid and block demenstions for 1D
    int num_blocks_1d = (N + BLOCK_SIZE_1D - 1) / BLOCK_SIZE_1D;

    // define grid and block demenstions for 3D
    int nx = 100, ny = 100, nz = 1000; // N = 10000000 = 100 * 100 * 1000
    dim3 block_size_3d(BLOCK_SIZE_3D_X, BLOCK_SIZE_3D_Y, BLOCK_SIZE_3D_Z);
    // threads per block
    dim3 num_blocks_3d(
        (nx + BLOCK_SIZE_3D_X - 1) / BLOCK_SIZE_3D_X,
        (ny + BLOCK_SIZE_3D_Y - 1) / BLOCK_SIZE_3D_Y,
        (nz + BLOCK_SIZE_3D_Z - 1) / BLOCK_SIZE_3D_Z
    ); // blocks per grid

    // warm-up runs
    printf("Performaing warm-up runs...\n");
    for (int i=0; i < 3; i++) {
        vector_add_cpu(h_a, h_b, h_c_cpu, N);
        vector_add_gpu_1d <<< num_blocks_1d, BLOCK_SIZE_1D >>> (d_a, d_b, d_c_1d, N);
        vector_add_gpu_3d <<< num_blocks_3d, block_size_3d >>> (d_a, d_b, d_c_3d, nx, ny, nz);
        cudaDeviceSynchronize();  // synchronization barrier between the CPU (host) and GPU (device)
        // blocks the CPU until all previously launched CUDA work on the GPU is finished
    }

    // benchmark cpu implementation
    printf("Benchmarning CPU implementation...\n");
    double total_cpu_time = 0.0;
    for (int i = 0; i < 20; i ++) {
        double start_time = get_time();
        vector_add_cpu(h_a, h_b, h_c_cpu, N);
        double end_time = get_time();
        total_cpu_time += (end_time - start_time);
    }
    double avg_cpu_time = total_cpu_time / 20.0;

    // bnchmarking GPU 1D implementation
    printf("Benchmarking GPU 1D implementation...\n");
    double total_gpu_1d_time = 0.0;
    for (int i = 0; i < 20; i++) {
        double start_time = get_time();
        
        vector_add_gpu_1d <<< num_blocks_1d, BLOCK_SIZE_1D >>> (d_a, d_b, d_c_1d, N);
        cudaDeviceSynchronize();

        double end_time = get_time();
        total_gpu_1d_time += (end_time - start_time);
    }
    double avg_gpu_1d_time = total_gpu_1d_time / 20.0;

    // verify 1D results
    cudaMemcpy(h_c_gpu_1d, d_c_1d, size, cudaMemcpyDeviceToHost);
    bool correct_1d = true;
    for (int i = 0; i < N; i ++) {
        if (fabs(h_c_gpu_1d[i] - h_c_cpu[i]) > 1e-4) {
            correct_1d = false;
            std::cout << i << " cpu: " << h_c_cpu[i] << " != gpu: " << h_c_gpu_1d[i] << std::endl; 
            break;
        }
    }
    printf("1D results are %s\n", correct_1d ? "correct" : "incorrect");

    // benchmarking GPU 3D implementation
    printf("Benchmarking GPU 3D implementation...\n");
    double total_gpu_3d_time = 0.0;
    for (int i = 0; i < 20; i ++) { // try 100 iterations and averaage
        cudaMemset(d_c_3d, 0, size); // clear previous results
        double start_time = get_time();
        vector_add_gpu_3d <<< num_blocks_3d, block_size_3d >>> (d_a, d_b, d_c_3d, nx, ny, nz);
        cudaDeviceSynchronize();
        double end_time = get_time();
        total_gpu_3d_time += (end_time - start_time);
    }
    double avg_gpu_3d_time = total_gpu_3d_time / 20.0;

    // verify 3D results
    cudaMemcpy(h_c_gpu_3d, d_c_3d, size, cudaMemcpyDeviceToHost);
    bool correct_3d = true;
    for (int i = 0; i < N; i++) {
        if (fabs(h_c_gpu_3d[i] - h_c_cpu[i]) > 1e-4) {
            correct_3d = false;
            std::cout << i << " cpu: " << h_c_cpu[i] << " != gpu: " << h_c_gpu_3d[i] << std::endl;
            break;
        }
    }
    printf("3D results are %s\n", correct_3d ? "correct" : "incorrect");

    // print results
    printf("CPU avg time: %f ms\n", avg_cpu_time * 1000);
    printf("GPU 1D avg time: %f ms\n", avg_gpu_1d_time * 1000);
    printf("GPU 3D avg time: %f ms\n", avg_gpu_3d_time * 1000);
    printf("Speedup (CPU vs GPU 1D): %fx\n", avg_cpu_time / avg_gpu_1d_time);
    printf("Speedup (CPU vs GPU 3D): %fx\n", avg_cpu_time / avg_gpu_3d_time);
    printf("Speedup (GPU 1D vs GPU 3D): %fx\n", avg_gpu_1d_time / avg_gpu_3d_time);

    // free memory
    cudaFree(d_a); cudaFree(d_b); cudaFree(d_c_1d); cudaFree(d_c_3d);
    free(h_a); free(h_b); free(h_c_cpu); free(h_c_gpu_1d); free(h_c_gpu_3d);

    return 0;
}


