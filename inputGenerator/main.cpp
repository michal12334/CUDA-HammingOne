#include <iostream>
#include <vector>
#include <ctime>
#include <cstdlib>

using namespace std;

string generateRandomString(int len) {
    string result;
    for(int i = 0; i < len; i++) {
        int r = rand() % 2;
        if(r == 0)
            result = result + "0";
        else
            result = result + "1";
    }
    return result;
}

bool doesExist(const vector<string>& v, const string& str) {
    for(const auto& s : v) {
        if(s == str)
            return true;
    }
    return false;
}

string generatePair(const vector<string>& v) {
    int i = rand() % v.size();
    int j = rand() % v[i].size();
    string result = v[i];
    result[j] = result[j] == '0' ? '1' : '0';
    return result;
}

int main(int argc, char** argv) {
    srand(time(NULL));
    int n = atoi(argv[1]);
    int l = atoi(argv[2]);
    int minNumberOfPairs = atoi(argv[3]);
    vector<string> result;

    for(int i = 0; i < n; i++) {
        if(i < n - minNumberOfPairs) {
            string newStr = generateRandomString(l);
            while(doesExist(result, newStr)) {
                newStr = generateRandomString(l);
            }
            result.push_back(newStr);
        } else {
            string newStr = generatePair(result);
            while(doesExist(result, newStr)) {
                newStr = generatePair(result);
            }
            result.push_back(newStr);
        }
    }

    cout << n << " " << l << "\n";
    for(const auto& str : result) {
        cout << str << "\n";
    }
    return 0;
}
