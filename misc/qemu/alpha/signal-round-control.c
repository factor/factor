/* Native NetBSD/Alpha diagnostic. No Factor image or kernel changes. */
#include <machine/sysarch.h>
#include <stdint.h>
#include <stdio.h>
#include <signal.h>
#include <ucontext.h>
#include <string.h>
#include <assert.h>
static uint64_t read_fpcr(void) {
    uint64_t v;
    __asm__ volatile("excb\n\tmf_fpcr %0\n\texcb" : "=f"(v) : : "memory");
    return v;
}
static void write_fpcr(uint64_t v) {
    __asm__ volatile("excb\n\tmt_fpcr %0\n\texcb" : : "f"(v) : "memory");
}
static uint64_t read_control(void) {
    struct alpha_fp_c_args a;
    assert(sysarch(ALPHA_GET_FP_C, &a) == 0);
    return a.fp_c;
}
static void write_control(uint64_t v) {
    struct alpha_fp_c_args a = {v};
    assert(sysarch(ALPHA_SET_FP_C, &a) == 0);
}
static volatile sig_atomic_t seen;
static volatile uint64_t handler_fpcr, context_fpcr;
static void handler(int sig, siginfo_t *info, void *context) {
    (void)sig; (void)info;
    handler_fpcr = read_fpcr();
    context_fpcr = ((ucontext_t *)context)->uc_mcontext.__fpregs.__fp_fpcr;
    seen = 1;
}
int main(void) {
    uint64_t saved = read_fpcr(), control = read_control();
    struct sigaction action, old;
    memset(&action, 0, sizeof(action));
    action.sa_sigaction = handler; action.sa_flags = SA_SIGINFO;
    sigemptyset(&action.sa_mask);
    assert(sigaction(SIGUSR1, &action, &old) == 0);
    int changed = 0;
    for (unsigned mode = 0; mode != 4; ++mode) {
        uint64_t requested = (saved & ~(UINT64_C(3) << 58)) | ((uint64_t)mode << 58);
        write_fpcr(requested);
        uint64_t before = read_fpcr();
        seen = 0;
        assert(raise(SIGUSR1) == 0 && seen);
        uint64_t after = read_fpcr();
        unsigned actual = (unsigned)((after >> 58) & 3);
        changed += actual != mode;
        printf("mode=%u before=%016llx handler=%016llx context=%016llx after=%016llx actual=%u\n",
            mode, (unsigned long long)before, (unsigned long long)handler_fpcr,
            (unsigned long long)context_fpcr, (unsigned long long)after, actual);
    }
    assert(sigaction(SIGUSR1, &old, 0) == 0);
    write_fpcr(saved); write_control(control);
    uint64_t restored = read_fpcr();
    printf("changed=%d restored=%016llx saved=%016llx control=%016llx\n",
        changed, (unsigned long long)restored, (unsigned long long)saved,
        (unsigned long long)read_control());
    return changed ? 1 : 0;
}
