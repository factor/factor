#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>

extern "C" {
    const char *getBuild() { //Get current architecture, detectx nearly every architecture. Coded by Freak
        #if defined(__x86_64__) || defined(_M_X64)
        return "x86_64";
        #elif defined(i386) || defined(__i386__) || defined(__i386) || defined(_M_IX86)
        return "x86_32";
        #elif defined(__ARM_ARCH_2__)
        return "ARM2";
        #elif defined(__ARM_ARCH_3__) || defined(__ARM_ARCH_3M__)
        return "ARM3";
        #elif defined(__ARM_ARCH_4T__) || defined(__TARGET_ARM_4T)
        return "ARM4T";
        #elif defined(__ARM_ARCH_5_) || defined(__ARM_ARCH_5E_)
        return "ARM5"
        #elif defined(__ARM_ARCH_6T2_) || defined(__ARM_ARCH_6T2_)
        return "ARM6T2";
        #elif defined(__ARM_ARCH_6__) || defined(__ARM_ARCH_6J__) || defined(__ARM_ARCH_6K__) || defined(__ARM_ARCH_6Z__) || defined(__ARM_ARCH_6ZK__)
        return "ARM6";
        #elif defined(__ARM_ARCH_7__) || defined(__ARM_ARCH_7A__) || defined(__ARM_ARCH_7R__) || defined(__ARM_ARCH_7M__) || defined(__ARM_ARCH_7S__)
        return "ARM7";
        #elif defined(__ARM_ARCH_7A__) || defined(__ARM_ARCH_7R__) || defined(__ARM_ARCH_7M__) || defined(__ARM_ARCH_7S__)
        return "ARM7A";
        #elif defined(__ARM_ARCH_7R__) || defined(__ARM_ARCH_7M__) || defined(__ARM_ARCH_7S__)
        return "ARM7R";
        #elif defined(__ARM_ARCH_7M__)
        return "ARM7M";
        #elif defined(__ARM_ARCH_7S__)
        return "ARM7S";
        #elif defined(__aarch64__) || defined(_M_ARM64)
        return "ARM64";
        #elif defined(mips) || defined(__mips__) || defined(__mips)
        return "MIPS";
        #elif defined(__sh__)
        return "SUPERH";
        #elif defined(__powerpc) || defined(__powerpc__) || defined(__powerpc64__) || defined(__POWERPC__) || defined(__ppc__) || defined(__PPC__) || defined(_ARCH_PPC)
        return "POWERPC";
        #elif defined(__PPC64__) || defined(__ppc64__) || defined(_ARCH_PPC64)
        return "POWERPC64";
        #elif defined(__sparc__) || defined(__sparc)
        return "SPARC";
        #elif defined(__m68k__)
        return "M68K";
        #else
        return "UNKNOWN";
        #endif
    }
}

void print_prot_bits(int prot) {
    printf((prot & PROT_READ) == 0 ? "-" : "R");
    printf((prot & PROT_WRITE) == 0 ? "-" : "W");
    printf((prot & PROT_EXEC) == 0 ? "-" : "X");
}
void *try_mmap_jit(size_t size, int prot) {
    int map_flags = MAP_ANON | MAP_PRIVATE | MAP_JIT;
    printf("Try mmap with MAP_JIT: ");
    print_prot_bits(prot);
    void *mem = mmap(NULL, size, prot, map_flags, -1, 0);
    if (mem == MAP_FAILED || mem == NULL) {
        printf(" FAIL: %s", strerror(errno));
        int map_flags = MAP_ANON | MAP_PRIVATE ;
        printf(" mmap without MAP_JIT: ");
        mem = mmap(NULL, size, prot, map_flags, -1, 0);
        
        if (mem == MAP_FAILED || mem == NULL) {
            printf(" FAIL: %s", strerror(errno));
            return NULL;
        }
    }
    printf(" PASS: %p", mem);
    return mem;
}
void try_mprotect(void *mem, size_t size, int prot) {
    printf("Try mprotect: %p ", mem);
    print_prot_bits(prot);
    int status = mprotect(mem, size, prot);
    if (status)
        printf(" FAIL: %s", strerror(errno));
    else
        printf(" PASS");
}

void try_mmap_jit_and_mprotect(size_t size, int prot_mmap, int prot_mprotect) {
    void *addr = try_mmap_jit(size, prot_mmap);
    printf(" -> ");
    if (addr) {
        try_mprotect(addr, size, prot_mprotect);
    }
    putchar('\n');
}

void trymmap() {
    const char *arch = getBuild();
    printf("ARCH: %s\n", arch);
    printf("Using map flags MAP_ANON | MAP_PRIVATE\n");
    for (int prot_mmap = 0; prot_mmap < 8; prot_mmap++) {
        for (int prot_mprotect = 0; prot_mprotect < 8; prot_mprotect++) {
            try_mmap_jit_and_mprotect(4096, prot_mmap, prot_mprotect);
        }
    }
}

#include "master.hpp"
int main(int argc, char** argv) {
//    trymmap();
    factor::init_mvm();
    factor::start_standalone_factor(argc, argv);
    return 0;
}

