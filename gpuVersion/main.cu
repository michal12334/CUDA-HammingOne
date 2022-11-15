#include <iostream>
#include <thrust/device_vector.h>
#include <stdio.h>

struct Pair {
    int x;
    int y;
};

__device__ Pair hammingDistance(char* a, char* b, int l) {
    Pair result;
    result.x = 0;
    for(int i = 0; i < l; i++) {
        if(a[i] != b[i]) {
            result.x++;
            result.y = i;
        }
    }
    return result;
}

__global__ void compute(char* d_mem, int n, int l, int* d_pairs, int* d_numberOfPairs) {
    int tid = threadIdx.x + blockIdx.x * blockDim.x;
    for(int i = tid + 1; i < n; i++) {
        auto hd = hammingDistance(d_mem + tid*l, d_mem + i*l, l);
        if(hd.x == 1) {
            d_pairs[d_numberOfPairs[tid] + tid*l] = i;
            d_numberOfPairs[tid]++;
        }
    }
}

int main() {
    int n, l;
    std::cin >> n >> l;
    const int NUMBER_OF_THREADS = 1024;
    const int NUMBER_OF_BLOCKS = n / 1024 + 1;
    char* mem = new char[n * l + 1];
    int* pairs = new int[n * l];
    int* numberOfPairs = new int[n];
    for(int i = 0; i < n; i++)
        std::cin >> (mem + i * l);
    char* d_mem;
    int* d_pairs;
    int* d_numberOfPairs;
    cudaMalloc(&d_mem, n * l * sizeof(char));
    cudaMalloc(&d_pairs, n * l * sizeof(int));
    cudaMalloc(&d_numberOfPairs, n * sizeof(int));
    cudaMemcpy(d_mem, mem, n * l * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemset(d_numberOfPairs, 0, n * sizeof(int));

    compute<<<NUMBER_OF_BLOCKS, NUMBER_OF_THREADS>>>(d_mem, n, l, d_pairs, d_numberOfPairs);

    cudaMemcpy(pairs, d_pairs, n * l * sizeof(int), cudaMemcpyDeviceToHost);
    cudaMemcpy(numberOfPairs, d_numberOfPairs, n* sizeof(int), cudaMemcpyDeviceToHost);

    for(int i = 0; i < n; i++) {
        for(int j = 0; j < numberOfPairs[i]; j++) {
            for(int k = 0; k < l; k++)
                std::cout << mem[k + i*l];
            std::cout << " ";
            for(int k = 0; k < l; k++)
                std::cout << mem[k + pairs[j + i*l]*l];
            std::cout << "\n";
        }
    }

    delete[] mem;
    return 0;
}
