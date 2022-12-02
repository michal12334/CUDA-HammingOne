#include <iostream>
#include <thrust/device_vector.h>
#include <stdio.h>

#define WARP_SIZE 32
#define WORD_MAX_SIZE 32
#define NUMBER_OF_BANKS WARP_SIZE
#define WARP_WORDS_SIZE (WARP_SIZE*WORD_MAX_SIZE)

__device__ int countBits(int a) {
    int result = 0;
    while(a) {
        result += a & 1;
        a>>= 1;
    }
    return result;
}

__global__ void compute(int* d_mem, int n, int l, int* d_pairs) {
    extern __shared__ int shm[];

    int gid = threadIdx.x + blockDim.x * blockIdx.x;
    int tid = threadIdx.x;
    int wid = threadIdx.x / WARP_SIZE;
    int idInWarp = threadIdx.x % WARP_SIZE;

    if(gid >= n)
        return;

    for(int i = 0; i < WORD_MAX_SIZE; i++) {
        shm[i*NUMBER_OF_BANKS + idInWarp + wid*WARP_WORDS_SIZE] = d_mem[i + gid*WORD_MAX_SIZE];
    }

    int numberOfPairs = 0;

    for(int i = gid + 1; i < n; i++) {
        int distance = 0;
        for(int j = 0; j < WORD_MAX_SIZE; j++) {
            int temp = d_mem[j + i*WORD_MAX_SIZE] ^ shm[j*NUMBER_OF_BANKS + idInWarp + wid*WARP_WORDS_SIZE];
            int cd = countBits(temp);
            distance += cd;
        }
        if(distance == 1) {
            d_pairs[numberOfPairs + l*gid] = i;
            numberOfPairs++;
        }
    }
}

int main() {
    int n, l;
    std::cin >> n >> l;

    const int NUMBER_OF_THREADS = 1024;
    const int NUMBER_OF_BLOCKS = n / 1024 + 1;

    int* mem = new int[WORD_MAX_SIZE * n];
    for(int i = 0; i < n; i++) {
        for(int j = 0; j < WORD_MAX_SIZE; j++) {
            mem[j + i*WORD_MAX_SIZE] = 0;
        }
    }
    for(int i = 0; i < n; i++) {
        for(int j = 0; j < l; j++) {
            char a;
            do {
                std::cin.get(a);
            } while(isspace(a));
            mem[j / 32 + i * WORD_MAX_SIZE] *= 2;
            if(a == '1')
                mem[j / 32 + i * WORD_MAX_SIZE]++;
        }
    }
    int* d_mem;
    int* d_pairs;
    cudaMalloc(&d_mem, WORD_MAX_SIZE*n*sizeof(int));
    cudaMalloc(&d_pairs, l*n*sizeof(int));
    cudaMemcpy(d_mem, mem, WORD_MAX_SIZE*n*sizeof(int), cudaMemcpyHostToDevice);
    cudaMemset(d_pairs, 0, l*n*sizeof(int));

    size_t shmSize = 32 * 1024;
    compute<<<NUMBER_OF_BLOCKS, NUMBER_OF_THREADS, shmSize>>>(d_mem, n, l, d_pairs);

    int* pairs = new int[n * l];

    cudaMemcpy(pairs, d_pairs, n*l*sizeof(int), cudaMemcpyDeviceToHost);

    for(int i = 0; i < n; i++) {
        int j = 0;
        while(pairs[j + i*l] != 0 && j < l) {
            std::cout << i << " " << pairs[j + i*l] << "\n";
            j++;
        }
    }


    delete[] pairs;
    delete[] mem;
    cudaFree(d_mem);
    cudaFree(d_pairs);
    return 0;
}
