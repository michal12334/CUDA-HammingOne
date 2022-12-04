#include <iostream>

#define WORD_MAX_SIZE 32

using namespace std;

int hammingDistance(int *a , int *b) {
    int result = 0;
    for(int i = 0; i < WORD_MAX_SIZE; i++) {
        int temp = a[i] ^ b[i];
        result += __builtin_popcount(temp);
    }
    return result;
}

int main() {
    int n, l;
    cin >> n >> l;
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
                cin.get(a);
            } while(isspace(a));
            mem[j / 32 + i * WORD_MAX_SIZE] *= 2;
            if(a == '1')
                mem[j / 32 + i * WORD_MAX_SIZE]++;
        }
    }

    for(int i = 0; i < n; i++) {
        for(int j = i + 1; j < n; j++) {
            if(hammingDistance(mem + i*WORD_MAX_SIZE, mem + j*WORD_MAX_SIZE) == 1) {
                cout << i << " " << j << "\n";
            }
        }
    }

    delete[] mem;
    return 0;
}
