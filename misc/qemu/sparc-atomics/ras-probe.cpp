#include <sys/types.h>
#include <sys/ras.h>
#include <sys/sysctl.h>
#include <sys/time.h>
#include <pthread.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <unistd.h>
#include "../../../vm/atomic-netbsd-sparc.hpp"
static uint32_t factor_ras_add(volatile uint32_t* ptr, uint32_t n) {
 return factor::atomic::ras::fetch_add(ptr, n);
}
static volatile uint32_t total;
static __thread volatile sig_atomic_t events;
static unsigned observed[5];
static void sample(int) { ++events; factor_ras_add(&total, 1); }
static void* worker(void* arg) {
 if (!factor::atomic::ras::initialize()) abort();
 for (unsigned i = 0; i < 200000; ++i) {
  factor_ras_add(&total, 3);
  factor_ras_add(&total, uint32_t(-2));
 }
 sigset_t mask; sigemptyset(&mask); sigaddset(&mask, SIGALRM);
 pthread_sigmask(SIG_BLOCK, &mask, 0);
 observed[(uintptr_t)arg] = events;
 return 0;
}
static void* initialize_vm(void*) {
 return factor::atomic::ras::initialize() ? nullptr : (void*)1;
}
int main() {
 int mib[] = {CTL_HW, HW_NCPU}, cpus; size_t len = sizeof(cpus);
 if (sysctl(mib, 2, &cpus, &len, 0, 0) || cpus != 1) return 77;
 pthread_t constructors[8];
 for (auto& thread : constructors)
  if (pthread_create(&thread, nullptr, initialize_vm, nullptr)) return 1;
 for (auto& thread : constructors) {
  void* unavailable;
  if (pthread_join(thread, &unavailable)) return 1;
  if (unavailable) return 77;
 }
 if (!factor::atomic::ras::available()) return 1;
 volatile uint32_t cas_value = 1;
 if (!factor::atomic::ras::cas(&cas_value, 1, 2) || cas_value != 2 ||
     factor::atomic::ras::cas(&cas_value, 1, 3) || cas_value != 2) return 1;
 pid_t child = fork();
 if (child < 0) return 1;
 if (child == 0) {
  bool ok = factor::atomic::ras::initialize() &&
      factor_ras_add(&cas_value, 3) == 2 && cas_value == 5;
  _exit(ok ? 0 : 1);
 }
 int status; if (waitpid(child, &status, 0) != child ||
                 !WIFEXITED(status) || WEXITSTATUS(status)) return 1;
 struct sigaction sa = {}; sa.sa_handler = sample; sigemptyset(&sa.sa_mask);
 if (sigaction(SIGALRM, &sa, 0)) return 1;
 struct itimerval timer = {}; timer.it_value.tv_usec = 100;
 timer.it_interval.tv_usec = 100;
 if (setitimer(ITIMER_REAL, &timer, 0)) return 1;
 pthread_t threads[4];
 for (uintptr_t i = 0; i < 4; ++i)
  if (pthread_create(&threads[i], 0, worker, (void*)i)) return 1;
 worker((void*)4);
 for (auto& thread : threads) if (pthread_join(thread, 0)) return 1;
 timer = {}; if (setitimer(ITIMER_REAL, &timer, 0)) return 1;
 sigset_t mask; sigemptyset(&mask); sigaddset(&mask, SIGALRM);
 pthread_sigmask(SIG_BLOCK, &mask, 0);
 observed[4] = events;
 unsigned signals = 0; for (auto n : observed) signals += n;
 printf("RAS total=%u expected=%u signals=%u\n", unsigned(total),
        1000000 + signals, signals);
 return total != 1000000 + signals || signals == 0;
}
