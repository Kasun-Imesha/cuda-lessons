#include <stdio.h>
#include <cuda_runtime.h>

// device code
__global__ void addKernal(int* c, const int* a, const int* b, int size){
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < size) c[idx] = a[idx] + b[idx];
}

// host code
int main(){
    /*
    Should contain the following 5 steps:
    -------------------------------------
    1. Allocate memory on the device (GPU)
    2. Copy data from host to device 
     - cudaMemcpy can kill the performance due to slow PCIe bandwidth compare to GPU global and shared memory bandwidths.
     - So try to minimize cudaMemcpy data transfers as much as possible and reuse the copied values as much as possible.
     - Try to send the data to GPU once, run many kernels and only copy the final result back.
    3. Launch the kernel
    4. Copy results from device to host
    5. Free GPU memory
    */
    const int size = 1000000, bytes = size * sizeof(int);

    // host memory allocation
    int *h_a = (int*)malloc(bytes), *h_b = (int*)malloc(bytes), *h_c = (int*)malloc(bytes);
    
    for (int i=0; i < size; i++){
        h_a[i] = i;
        h_b[i] = 2 * i;
    }

    // initialize device (gpu) varables
    int *dev_a, *dev_b, *dev_c;

    // device memory allocation
    cudaMalloc(&dev_a, bytes);  // &dev_a — the address of your pointer. cudaMalloc writes the allocated GPU memory `address` into dev_a
    cudaMalloc(&dev_b, bytes);
    cudaMalloc(&dev_c, bytes);

    // copy data from host -> device
    cudaMemcpy(dev_a, h_a, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dev_b, h_b, bytes, cudaMemcpyHostToDevice);

    int threadsPerBlock = 256, blocksPerGrid = (size + threadsPerBlock - 1) / threadsPerBlock;
    // launch the kernel
    addKernal<<<blocksPerGrid, threadsPerBlock>>>(dev_c, dev_a, dev_b, size);

    // cpy results back to host (data copy device -> host)
    cudaMemcpy(h_c, dev_c, bytes, cudaMemcpyDeviceToHost);

    printf("Vector addition of %d elements\n", size);
    printf("Verification: c[0] = %d, c[999999] = %d\n", h_c[0], h_c[999999]);

    // free memory
    cudaFree(dev_a); cudaFree(dev_b); cudaFree(dev_c);
    free(h_a); free(h_b); free(h_c);

    return 0;
}