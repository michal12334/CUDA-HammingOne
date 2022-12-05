#include <iostream>

#define WARP_SIZE 32
#define WORD_MAX_SIZE 32
#define NUMBER_OF_BANKS WARP_SIZE
#define WARP_WORDS_SIZE (WARP_SIZE*WORD_MAX_SIZE)
#define NUMBER_OF_THREADS 256
#define MAX_WORDS_IN_SHM 256

__global__ void compute(int* d_mem, int n, int l, int* d_pairs) {
    extern __shared__ int shm[];

    int gid = threadIdx.x + blockDim.x * blockIdx.x;
    int wid = threadIdx.x / WARP_SIZE;
    int idInWarp = threadIdx.x % WARP_SIZE;
    int minGid = blockIdx.x * NUMBER_OF_THREADS;
    int tid = threadIdx.x;

    if(gid >= n)
        return;

    int numberOfPairs = 0;

    int word[WORD_MAX_SIZE];

    for(int i = 0; i < WORD_MAX_SIZE; i++) {
        word[i] = d_mem[i + gid*WORD_MAX_SIZE];
    }

    for(int i = minGid + 1; i < n; i += MAX_WORDS_IN_SHM) {
        int s = min(MAX_WORDS_IN_SHM, n - i);
        __syncthreads();
        if(tid < s) {
            for(int j = 0; j < WORD_MAX_SIZE; j++) {
                shm[j*NUMBER_OF_BANKS + idInWarp + wid*WARP_WORDS_SIZE] = d_mem[j + (tid + i) * WORD_MAX_SIZE];
            }
        }
        for(int j = 0; j < s; j++) {
            if(gid < j + i) {
                int distance = 0;
                for(int k = 0; k < WORD_MAX_SIZE; k++) {
                    int temp = word[k] ^ shm[k*NUMBER_OF_BANKS + (j%WARP_SIZE) + (j/WARP_SIZE)*WARP_WORDS_SIZE];
                    int cd = __popc(temp);
                    distance += cd;
                }
                if(distance == 1) {
                    d_pairs[numberOfPairs + l*gid] = i + j;
                    numberOfPairs++;
                }
            }
        }
    }
}

int main() {
    int n, l;
    std::cin >> n >> l;

    const int NUMBER_OF_BLOCKS = n / NUMBER_OF_THREADS + 1;

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
            mem[j / (8*sizeof(int)) + i * WORD_MAX_SIZE] *= 2;
            if(a == '1')
                mem[j / (8*sizeof(int)) + i * WORD_MAX_SIZE]++;
        }
    }
    int* d_mem;
    int* d_pairs;
    cudaMalloc(&d_mem, WORD_MAX_SIZE * n * sizeof(int));
    cudaMalloc(&d_pairs, l * n * sizeof(int));
    cudaMemcpy(d_mem, mem, WORD_MAX_SIZE * n * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemset(d_pairs, 0, l * n * sizeof(int));

    size_t shmSize = WORD_MAX_SIZE * MAX_WORDS_IN_SHM * sizeof(int);
    compute<<<NUMBER_OF_BLOCKS, NUMBER_OF_THREADS, shmSize>>>(d_mem, n, l, d_pairs);

    int* pairs = new int[n * l];

    cudaMemcpy(pairs, d_pairs, n * l * sizeof(int), cudaMemcpyDeviceToHost);

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
