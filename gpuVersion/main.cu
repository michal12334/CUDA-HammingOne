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

__global__ void compute(char* d_mem, int n, int l, bool* d_isAnswer) {
    int tid = threadIdx.x + blockIdx.x;
    for(int i = tid + 1; i < n; i++) {
        auto hd = hammingDistance(d_mem + tid*l, d_mem + i*l, l);
        if(hd.x == 1) {
            d_isAnswer[tid * l + hd.y] = true;
        }
    }
}

int main() {
    int n, l;
    std::cin >> n >> l;
    const int NUMBER_OF_THREADS = 1024;
    const int NUMBER_OF_BLOCKS = n / 1024 + 1;
    char* mem = new char[n * l + 1];
    bool* isAnswer = new bool[n * l];
    for(int i = 0; i < n; i++)
        std::cin >> (mem + i * l);
    char* d_mem;
    bool* d_isAnswer;
    cudaMalloc(&d_mem, n * l * sizeof(char));
    cudaMalloc(&d_isAnswer, n * l * sizeof(bool));
    cudaMemcpy(d_mem, mem, n * l * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemset(d_isAnswer, 0, n * l * sizeof(bool));

    compute<<<NUMBER_OF_BLOCKS, NUMBER_OF_THREADS>>>(d_mem, n, l, d_isAnswer);

    cudaMemcpy(isAnswer, d_isAnswer, n * l * sizeof(bool), cudaMemcpyDeviceToHost);

    for(int i = 0; i < n; i++) {
        for(int j = 0; j < l; j++) {
            if(isAnswer[i * l + j]) {
                for(int k = 0; k < l; k++) {
                    std::cout << mem[i*l + k];
                }
                std::cout << " ";
                for(int k = 0; k < l; k++) {
                    if(k == j) {
                        std::cout << (mem[i*l + k] == '1' ? '0' : '1');
                        continue;
                    }
                    std::cout << mem[i*l + k];
                }
                std::cout << "\n";
            }
        }
    }

    delete[] mem;
    return 0;
}
