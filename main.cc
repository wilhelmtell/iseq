#include <iostream>
#include <string>
#include <algorithm>
#include <fstream>

using namespace std;

template <class Ch, class Tr>
int process(basic_istream<Ch,Tr>& in, basic_ostream<Ch,Tr>& out)
{
    string compare_with;
    getline(in, compare_with);
    string line;
    while( getline(in, line) ) {
        if( line != compare_with ) { // FIXME: performance, reading line twice
            out << "no" << endl;
            return 0;
        }
    }
    if( in.bad() ) {
        cerr << "Error processing input\n";
        return 1;
    }
    out << "yes" << endl;
    return 0;
}

int main(int argc, char* argv[])
{
    fstream fin, fout;
    if( argc > 1 && argv[1] != "-" )
        fin.open(argv[1], ios::in);
    if( argc > 2 && argv[2] != "-" )
        fout.open(argv[2], ios::out);
    return process(fin.is_open()  ? fin  : cin,
                   fout.is_open() ? fout : cout);
}
