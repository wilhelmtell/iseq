#include <iostream>
#include <string>
#include <algorithm>

using namespace std;

int main(int argc, char* argv[])
{
    string compare_with;
    getline(cin, compare_with);
    string line;
    while( getline(cin, line) ) {
        if( line != compare_with ) { // FIXME: performance, reading line twice
            cout << "no" << endl;
            return 0;
        }
    }
    if( cin.bad() ) {
        cerr << "Error processing input\n";
        return 1;
    }
    cout << "yes" << endl;
    return 0;
}
