#include <iostream>

using namespace std;

int hammingDistance(char* a, char* b, int l) {
    int result = 0;
    for(int i = 0; i < l; i++) {
        if(a[i] != b[i])
            result++;
    }
    return result;
}

int main() {
    int n, l;
    char** numbers;
    cin >> n >> l;
    numbers = new char*[n];
    for(int i = 0; i < n; i++) {
        numbers[i] = new char[l + 1];
    }

    for(int i = 0; i < n; i++) {
        cin >> numbers[i];
    }

    for(int i = 0; i < n; i++) {
        for(int j = i + 1; j < n; j++) {
            if(hammingDistance(numbers[i], numbers[j], l) == 1) {
                cout << i << " " << j << "\n";
            }
        }
    }

    for(int i = 0; i < n; i++) {
        delete[] numbers[i];
    }
    delete[] numbers;
    return 0;
}
