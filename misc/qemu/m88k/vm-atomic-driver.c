// Reuse the same independent threaded/signal oracle for the VM wrappers.
#define main publication_main
#include "cxx17-publication-driver.c"
#undef main
#include <sys/resource.h>
#include <sys/wait.h>
#include <unistd.h>
extern unsigned m88k_publication_rmw_supported(void);
extern void m88k_publication_fence(void);
extern unsigned m88k_unavailable_add(volatile unsigned*);
extern unsigned m88k_unavailable_cas(volatile unsigned*);
static void expect_unavailable(unsigned (*operation)(volatile unsigned*)) {
    int status;
    pid_t child = fork();
    assert(child >= 0);
    if (child == 0) {
        volatile unsigned value = 0;
        struct rlimit limit = {0, 0};
        assert(setrlimit(RLIMIT_CORE, &limit) == 0);
        operation(&value);
        _exit(1);
    }
    assert(waitpid(child, &status, 0) == child);
    assert(WIFSIGNALED(status) && WTERMSIG(status) == SIGABRT);
}
int main(void) {
    assert(!m88k_publication_rmw_supported());
    m88k_publication_fence();
    expect_unavailable(m88k_unavailable_add);
    expect_unavailable(m88k_unavailable_cas);
    assert(publication_main() == 0);
    puts("m88k VM atomic wrappers PASS: publication and fence; unavailable arithmetic aborts");
    return 0;
}
