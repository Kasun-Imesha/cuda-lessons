def matmul_tiled(A, B, M, N, K, TILE=2):
    C = [[0.0] * N for _ in range(M)]
    
    # iterate over tiles
    for t in range(K // TILE):
        # shared memory tiles
        shared_A = [[0.0] * TILE for _ in range(M)]
        shared_B = [[0.0] * N for _ in range(TILE)]
        
        # step 1: load a tile of A and B into shared emory
        for row in range(M):
            for d in range(TILE):
                shared_A[row][d] = A[row][t * TILE + d]
                
        for d in range(TILE):
            for col in range(N):
                shared_B[d][col] = B[t * TILE + d][col]
        
        # step 2: compute partial sums using the shared memory tiles
        for row in range(M):
            for col in range(N):
                for d in range(TILE):
                    C[row][col] += shared_A[row][d] * shared_B[d][col]  # reads from shared memory
                    
    return C

if __name__ == "__main__":
    M, N, K = 4, 4, 4
    A = [[1.0 * (i + j) for j in range(K)] for i in range(M)]
    B = [[1.0 * (i + j) for j in range(N)] for i in range(K)]
    
    C = matmul_tiled(A, B, M, N, K)
    
    print("Matrix A:")
    for row in A:
        print(row)
        
    print("\nMatrix B:")
    for row in B:
        print(row)
    
    print("\nMatrix C (A x B):")
    for row in C:
        print(row)