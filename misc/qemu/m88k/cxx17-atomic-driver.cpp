// Link with the guest's native C++ compiler after cross compilation succeeds.
#include <cassert>
#include <cstdio>
extern "C" unsigned m88k_cxx17_atomic_load(volatile unsigned *);
extern "C" void m88k_cxx17_atomic_store(volatile unsigned *, unsigned);
extern "C" bool m88k_cxx17_atomic_cas(volatile unsigned *, unsigned, unsigned);
int main() {
    volatile unsigned value = 7;
    assert(m88k_cxx17_atomic_load(&value) == 7);
    m88k_cxx17_atomic_store(&value, 42);
    assert(m88k_cxx17_atomic_load(&value) == 42);
    assert(!m88k_cxx17_atomic_cas(&value, 7, 99) && value == 42);
    assert(m88k_cxx17_atomic_cas(&value, 42, 99) && value == 99);
    std::puts("m88k C++17 native atomic gate PASS: load store CAS; concurrent publication separate");
    return 0;
}
