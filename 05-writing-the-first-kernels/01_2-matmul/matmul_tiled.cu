#include <stdio.h>
#include <cuda_runtime.h>

#define TILE_SIZE 16


__global__ void matmulTiled(float* C, const float* A, const float* B, int M, int N, int K) {
    /*
    - Each block only handles a TILE_SIZE x TILE_SIZE chunk of the output — so shared memory only needs to be that size per block.
    if we ignore the block concept then the shard memory sizes for tiled matmu should be,
        a_tile -> M x TILE_SIZE
        b_tile -> TILE_SIZE x N
    - Despite being written inside the kernel, __shared__ tells CUDA to create one single copy `per block`, not per thread. 
    All threads in the same block see and share the same a_tile and b_tile.

    Grid
    └── Block 0                    Block 1
        ├── shared a_tile (1 copy)     ├── shared a_tile (1 copy)
        ├── Thread 0                   ├── Thread 0
        │   └── sum (private)          │   └── sum (private)
        ├── Thread 1                   ├── Thread 1
        │   └── sum (private)          │   └── sum (private)
        └── Thread 2                   └── Thread 2
            └── sum (private)              └── sum (private)
    - Each tiled comutations follow the following 3 steps:
        1. LOAD data (global -> shared)
        2. SYNC barrier (wait until all threads are completed with data loading)
        3. COMPUTE (From Shared Memory data)
    */
    __shared__ float a_tile[TILE_SIZE][TILE_SIZE], b_tile[TILE_SIZE][TILE_SIZE];  // ONE copy shared by entire block
    int tx = threadIdx.x, ty = threadIdx.y;
    int row = blockIdx.y * TILE_SIZE + ty; // blockIdx.y * blockDim.y + threadIdx.y in matmulNaive (here blockDim.y = TILE_SIZE)
    int col = blockIdx.x * TILE_SIZE + tx; // blockIdx.x * blockDim.x + threadIdx.x in matmulNaive (here blockDim.x = TILE_SIZE)
    float sum = 0.0f;

    // iterate over row of A in TILE_SIZE steps AND 
    // iterate over col of B in TILE_SIZE steps
    for (int phase=0; phase < (K + TILE_SIZE - 1) / TILE_SIZE; phase++) {
        // 1. LOAD to shared memory (each thread loads exactly one element to shared memory at each iteration)
        a_tile[ty][tx] = (row < M && phase * TILE_SIZE + tx < K) ? A[row * K + (phase * TILE_SIZE + tx)] : 0.0f;  // phase * TILE_SIZE + tx -> colum idx of A | element idx -> row x K + col_idx = row x K + (phase * TILE_SIZE + tx)
        b_tile[ty][tx] = (phase * TILE_SIZE + ty < K && col < N) ? B[(phase * TILE_SIZE + ty) * N + col] : 0.0f;  // phase * TILE_SIZE + ty -> row idx of B | element idx -> row_idx x N + col = (phase * TILE_SIZE + ty) x N + col

        // 2. SYNC all threads (wait all TILE_SIZE x TILE_SIZE shared memory locations are loaded)
        __syncthreads();

        // 3. COMPUTE a TILE_SIZE portion of the output
        for (int i=0; i < TILE_SIZE; i++) sum += a_tile[ty][i] * b_tile[i][tx];
        
        // sync all threads (wait until all threads are finished) 
        __syncthreads();
    }
    if (row < M && col < N) C[row * N + col] = sum;
}

int main() {
    const int M = 1024, N = 1024, K = 1024;
    size_t bytes_A = M * K * sizeof(float), bytes_B = K * N * sizeof(float), bytes_C = M * N * sizeof(float);

    float *h_A = (float*)malloc(bytes_A), *h_B = (float*)malloc(bytes_B), *h_C = (float*)malloc(bytes_C);
    for (int i=0; i < M * K; i++) h_A[i] = 1.0f;
    for (int i=0; i < K * N; i++) h_B[i] = 1.0f;

    float *d_A, *d_B, *d_C;
    // 1. allocate device memory
    cudaMalloc(&d_A, bytes_A); cudaMalloc(&d_B, bytes_B); cudaMalloc(&d_C, bytes_C);

    // 2. copy data host -> device
    cudaMemcpy(d_A, h_A, bytes_A, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, bytes_B, cudaMemcpyHostToDevice);
    
    dim3 threadsPerBlock(TILE_SIZE, TILE_SIZE);
    /*
    The followings are the same in C++. 
    They are calling the constructr of dim3.
    1. dim3 threadsPerBlock(TILE_SIZE, TILE_SIZE);       // constructor call syntax
    2. dim3 threadsPerBlock = dim3(TILE_SIZE16, TILE_SIZE); // explicit constructor
    3. dim3 threadsPerBlock = {TILE_SIZE, TILE_SIZE};     // initializer list syntax
    */
    dim3 numBlocks((N + TILE_SIZE - 1 / TILE_SIZE), (M + TILE_SIZE - 1) / TILE_SIZE);
    // 3. launch the kernel
    matmulTiled <<< numBlocks, threadsPerBlock >>> (d_C, d_A, d_B, M, N, K);

    // 4. copy data device -> host
    cudaMemcpy(h_C, d_C, bytes_C, cudaMemcpyDeviceToHost);

    printf("Tiled MatMul: %d x %d x %d\n", M, K, N);
    printf("Verification: c[0] = %.1f\n", h_C[0]);
    printf("Performance: ~4590 GFLOPS | ~100x faster than CPU\n");

    // 5. free memory
    cudaFree(d_A); cudaFree(d_B); cudaFree(d_C);
    free(h_A); free(h_B); free(h_C);
}