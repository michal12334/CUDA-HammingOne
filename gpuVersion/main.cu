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

__global__ void compute(char* d_mem, int n, int l, bool* d_pairs) {
    extern __shared__ char shm[];
    int mem1Offset = 32*l;

    int tidX = threadIdx.x;
    int tidY = threadIdx.y;
    int tid = tidX + tidY * 32;
    int bidX = blockIdx.x;
    int bidY = blockIdx.y;

    if(tidX >= n || tidY >= n)
        return;
    
    int a = bidX * 32 * n * l;
    int b = bidY * 32 * n * l;
    for(int i = tid; i < mem1Offset; i+= blockDim.x*blockDim.y) {
        int index = i;
        shm[index] = d_mem[a + index/32 + (i%32)*l];
        shm[index + mem1Offset] = d_mem[b + index/32 + (i%32)*l];
    }

    __syncthreads();

    if(tidX >= tidY)
        return;

    Pair hm;
    hm.x = 0;
    for(int i = 0; i < l; i++) {
        if(shm[tidX + 32*i] != shm[tidY + 32*i + mem1Offset]) {
            hm.x++;
            hm.y = i;
        }
    }
    if(hm.x == 1) {
        d_pairs[a + tidX*l + hm.y] = true;
    }
}

int main() {
    int n, l;
    std::cin >> n >> l;
    const int NUMBER_OF_THREADS = 1024;
    const int NUMBER_OF_BLOCKS = n / 1024 + 1;
    char* mem = new char[n * l + 1];
    bool* pairs = new bool[n * l];
    for(int i = 0; i < n; i++)
        std::cin >> (mem + i * l);
    char* d_mem;
    bool* d_pairs;
    cudaMalloc(&d_mem, n * l * sizeof(char));
    cudaMalloc(&d_pairs, n * l * sizeof(bool));
    cudaMemcpy(d_mem, mem, n * l * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemset(d_pairs, 0, n * l * sizeof(bool));

    size_t shmSize = (64*l) * sizeof(char);
    // size_t shmSize = 1e9;
    compute<<<dim3(sqrt(n)/32 + 1, sqrt(n)/32 + 1, 1), dim3(32, 32, 1), shmSize>>>(d_mem, n, l, d_pairs);

    cudaMemcpy(pairs, d_pairs, n * l * sizeof(bool), cudaMemcpyDeviceToHost);

    for(int i = 0; i < n; i++) {
        for(int j = 0; j < l; j++) {
            if(pairs[j + i*l]) {
                for(int k = 0; k < l; k++)
                    std::cout << mem[k + i*l];
                std::cout << " ";
                for(int k = 0; k < l; k++)
                    if(k == j)
                        std::cout << (mem[k + i*l] == '0' ? '1' : '0');
                    else
                        std::cout << mem[k + i*l];
                std::cout << "\n";
            }
        }
    }

    delete[] mem;
    return 0;
}
