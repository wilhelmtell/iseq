#include <iostream>
#include <string>
#include <algorithm>
#include <fstream>

template <class Ch, class Tr>
int process(std::basic_istream<Ch,Tr>& in, std::basic_ostream<Ch,Tr>& out)
{
    std::string compare_with;
    std::getline(in, compare_with);
    std::string line;
    while( std::getline(in, line) ) {
        if( line != compare_with ) { // FIXME: performance, already read line
            out << "no\n";
            return 0;
        }
    }
    if( in.bad() ) {
        std::cerr << "Error processing input\n";
        return 1;
    }
    out << "yes\n";
    return 0;
}

int main(int argc, char* argv[])
{
    std::fstream fin, fout;
    if( argc > 1 && argv[1] != "-" ) {
        fin.open(argv[1], std::ios::in);
        if( ! fin.is_open() ) {
            std::cerr << "Error openning input file " << argv[1] << '\n';
            return 1;
        }
    }
    if( argc > 2 && argv[2] != "-" ) {
        fout.open(argv[2], std::ios::out);
        if( ! fout.is_open() ) {
            std::cerr << "Error openning output file " << argv[2] << '\n';
            return 1;
        }
    }
    return process(fin.is_open() ? fin : std::cin,
                   fout.is_open() ? fout : std::cout);
}
