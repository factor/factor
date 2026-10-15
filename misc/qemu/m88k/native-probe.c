/* Native OpenBSD/m88k infrastructure gate, not a Factor VM test. */
#include <assert.h>
#include <dlfcn.h>
#include <signal.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/utsname.h>
#include <machine/reg.h>
#include <machine/psl.h>
#include <unistd.h>
#include "native-ffi.h"
extern const unsigned char m88k_code_start[], m88k_code_end[];
extern void m88k_cache_sync(void *, size_t);
extern const unsigned char m88k_fp_start[], m88k_fp_end[];
extern const unsigned char m88k_fsub_start[], m88k_fsub_end[];
extern const unsigned char m88k_fmul_start[], m88k_fmul_end[];
extern const unsigned char m88k_fdiv_start[], m88k_fdiv_end[];
extern const unsigned char m88k_fault_start[], m88k_fault_insn[], m88k_fault_resume[], m88k_fault_end[];
extern const unsigned char m88k_branch_start[], m88k_branch_end[];
extern const unsigned char m88k_call_start[], m88k_call_end[];
extern const unsigned char m88k_cond_start[], m88k_cond_end[];
extern unsigned m88k_atomic_exchange(volatile unsigned *, unsigned);
static uintptr_t expected_fault, expected_resume;
static volatile sig_atomic_t delivered, fault_delivered;
static void on_fault(int sig, siginfo_t *info, void *context) {
    struct sigcontext *sc = (struct sigcontext *)context;
    struct reg *regs = (struct reg *)sc->sc_regs;
    assert(sig == SIGSYS && info->si_signo == SIGSYS);
    assert((regs->sxip & XIP_ADDR) == expected_fault);
    assert(regs->r[31] != 0);
    regs->snip = expected_resume | NIP_V;
    regs->sfip = (expected_resume + 4) | FIP_V;
    fault_delivered++;
}
static void on_signal(int sig, siginfo_t *info, void *context) {
    struct sigcontext *sc = (struct sigcontext *)context;
    assert(sig == SIGUSR1 && info->si_signo == SIGUSR1);
    assert(sc != NULL && sc->sc_regs[31] != 0);
    delivered++;
}
static unsigned callback(unsigned a, unsigned b) { return a * 7 + b; }
int main(void) {
    struct utsname u;
    struct sigaction sa;
    unsigned endian = 0x01020304;
    volatile uint64_t a = 123456789, b = 987654321;
    volatile double x = 1.25, y = 2.5;
    volatile unsigned exchanged = 7;
    size_t pagesize = (size_t)sysconf(_SC_PAGESIZE);
    size_t codesize = (size_t)(m88k_code_end - m88k_code_start);
    void *code, *library;
    double (*fp)(double, double);
    unsigned (*cb)(unsigned (*)(unsigned, unsigned));
    struct native_record (*record)(struct native_record);
    double (*varargs)(unsigned,...);
    struct native_record input, result;
    FILE *file;
    char contents[32];
    const unsigned char branches[] = {0xc0,0,0,2,0xcb,0xff,0xff,0xfe,0xd0,0x41,0xff,0xfe};
    assert((size_t)(m88k_branch_end-m88k_branch_start) == sizeof(branches));
    assert(memcmp(m88k_branch_start, branches, sizeof(branches)) == 0);
    assert(sizeof(void *) == 4 && *(unsigned char *)&endian == 1);
    assert(a + b == UINT64_C(1111111110) && x * y == 3.125);
    assert(m88k_atomic_exchange(&exchanged, 42) == 7 && exchanged == 42);
    assert(m88k_atomic_exchange(&exchanged, 0) == 42 && exchanged == 0);
    puts("m88k atomic primitive gate PASS: xmem32 exchange userland pipeline barrier; concurrent CAS separate");
    library = dlopen("./libnative-ffi.so", RTLD_NOW);
    if (!library) { fprintf(stderr, "%s\n", dlerror()); return 1; }
    fp = (double (*)(double, double))dlsym(library, "native_fp");
    cb = (unsigned (*)(unsigned (*)(unsigned, unsigned)))dlsym(library, "native_callback");
    assert(fp && cb && fp(x, y) == 5.0 && cb(callback) == 42);
    record=(struct native_record (*)(struct native_record))dlsym(library,"native_record_roundtrip");
    varargs=(double (*)(unsigned,...))dlsym(library,"native_varargs");
    assert(record && varargs);
    input.tag=2; input.integer=UINT64_C(0x100000000); input.real=2.5;
    result=record(input);
    assert(result.tag==3 && result.integer==UINT64_C(0x223456789) && result.real==5.0);
    assert(varargs(3,1.25,2.5,3.75)==7.5);
    file = tmpfile();
    assert(file && fputs("m88k-file-io", file) >= 0);
    rewind(file);
    assert(fgets(contents, sizeof(contents), file));
    assert(strcmp(contents, "m88k-file-io") == 0 && fclose(file) == 0);
    memset(&sa, 0, sizeof(sa));
    sa.sa_sigaction = on_signal;
    sa.sa_flags = SA_SIGINFO;
    sigemptyset(&sa.sa_mask);
    assert(sigaction(SIGUSR1, &sa, NULL) == 0);
    assert(raise(SIGUSR1) == 0 && delivered == 1);
    code = mmap(NULL, pagesize, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANON, -1, 0);
    assert(code != MAP_FAILED && codesize > 0 && codesize <= pagesize);
    memcpy(code, m88k_code_start, codesize);
    m88k_cache_sync(code, codesize);
    assert(mprotect(code, pagesize, PROT_READ | PROT_EXEC) == 0);
    assert(((unsigned (*)(void))code)() == 42);
    assert(mprotect(code, pagesize, PROT_READ | PROT_WRITE) == 0);
    codesize = (size_t)(m88k_fp_end - m88k_fp_start);
    memcpy(code, m88k_fp_start, codesize);
    m88k_cache_sync(code, codesize);
    assert(mprotect(code, pagesize, PROT_READ | PROT_EXEC) == 0);
    assert(((double (*)(double))code)(2.5) == 5.0);
    {
        struct fp_program { const unsigned char *start, *end; double expected; };
        struct fp_program programs[] = {
            {m88k_fsub_start, m88k_fsub_end, -1.25},
            {m88k_fmul_start, m88k_fmul_end, 3.125},
            {m88k_fdiv_start, m88k_fdiv_end, 0.5}
        };
        unsigned i;
        for (i=0; i<sizeof(programs)/sizeof(programs[0]); ++i) {
            assert(mprotect(code, pagesize, PROT_READ | PROT_WRITE) == 0);
            codesize = (size_t)(programs[i].end - programs[i].start);
            memcpy(code, programs[i].start, codesize);
            m88k_cache_sync(code, codesize);
            assert(mprotect(code, pagesize, PROT_READ | PROT_EXEC) == 0);
            assert(((double (*)(double, double))code)(x,y) == programs[i].expected);
        }
    }
    {
        const unsigned char *starts[] = {m88k_call_start, m88k_cond_start};
        const unsigned char *ends[] = {m88k_call_end, m88k_cond_end};
        unsigned i;
        for (i=0; i<2; ++i) {
            assert(mprotect(code, pagesize, PROT_READ | PROT_WRITE) == 0);
            codesize = (size_t)(ends[i] - starts[i]);
            memcpy(code, starts[i], codesize);
            m88k_cache_sync(code, codesize);
            assert(mprotect(code, pagesize, PROT_READ | PROT_EXEC) == 0);
            assert(((unsigned (*)(unsigned))code)(41) == (i ? 43 : 42));
            assert(((unsigned (*)(unsigned))code)(40) == (i ? 42 : 41));
        }
    }
    sa.sa_sigaction = on_fault;
    assert(sigaction(SIGSYS, &sa, NULL) == 0);
    assert(mprotect(code, pagesize, PROT_READ | PROT_WRITE) == 0);
    codesize = (size_t)(m88k_fault_end - m88k_fault_start);
    expected_fault = (uintptr_t)code + (m88k_fault_insn - m88k_fault_start);
    expected_resume = (uintptr_t)code + (m88k_fault_resume - m88k_fault_start);
    memcpy(code, m88k_fault_start, codesize);
    m88k_cache_sync(code, codesize);
    assert(mprotect(code, pagesize, PROT_READ | PROT_EXEC) == 0);
    assert(((unsigned (*)(void))code)() == 42 && fault_delivered == 1);
    assert(munmap(code, pagesize) == 0 && dlclose(library) == 0);
    assert(uname(&u) == 0);
    printf("m88k native gate PASS: %s %s pointer=32 endian=big integer fp ffi callback aggregate varargs signal-context fault-resume cache-sync executable-code executable-fp executable-control-flow file-io\n", u.sysname, u.release);
    puts("Factor VM/bootstrap/compiler/tools.test gates remain separate.");
    return 0;
}
