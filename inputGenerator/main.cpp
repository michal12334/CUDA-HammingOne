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

int main() {
    srand(time(NULL));
    int n, l;
    cin >> n >> l;
    vector<string> result;

    for(int i = 0; i < n; i++) {
        string newStr = generateRandomString(l);
        while(doesExist(result, newStr)) {
            newStr = generateRandomString(l);
        }
        result.push_back(newStr);
    }

    cout << n << " " << l << "\n";
    for(const auto& str : result) {
        cout << str << "\n";
    }
    return 0;
}
