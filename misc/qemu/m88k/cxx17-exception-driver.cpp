// Link with the guest's native C++ runtime after cross compilation succeeds.
#include <cassert>
#include <cstdio>
extern "C" int m88k_cxx17_exceptions(int);
int main() {
    assert(m88k_cxx17_exceptions(0) == 0);
    assert(m88k_cxx17_exceptions(42) == 42);
    assert(m88k_cxx17_exceptions(-7) == -7);
    std::puts("m88k C++17 native exception gate PASS: throw catch");
    return 0;
}
