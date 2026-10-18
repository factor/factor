#include "../master.hpp"
#include <setjmp.h>
#include <sys/wait.h>
#if defined(__FreeBSD__) || defined(__DragonFly__) || defined(__OpenBSD__) || defined(__NetBSD__)
#include <sys/sysctl.h>
#endif

static const char* executable_path;

using namespace factor;

namespace factor {
void memory_signal_handler(int, siginfo_t*, void*);
void synchronous_signal_handler(int, siginfo_t*, void*);
void enqueue_signal_handler(int, siginfo_t*, void*);
void fep_signal_handler(int, siginfo_t*, void*);
void sample_signal_handler(int, siginfo_t*, void*);
VM_C_API void factor_begin_ignore_console_signals();
VM_C_API void factor_end_ignore_console_signals();
#if defined(FACTOR_LOONGARCH64) || defined(FACTOR_NO_PTHREAD_CANCEL)
extern "C" {
extern int control_read, control_write, stdin_read, size_read;
extern bool stdin_thread_initialized_p;
extern pthread_mutex_t stdin_mutex;
}
#endif
}

static void check(bool condition, const char* message) {
  if (!condition) {
    std::cerr << message << std::endl;
    _exit(1);
  }
}

struct test_vm : factor_vm {
  test_vm() : factor_vm(pthread_self()) {
    std::fill(special_objects, special_objects + special_object_count,
              false_object);
    register_vm_with_thread(this);
  }
};

static void install_handler(int signal, void (*handler)(int, siginfo_t*, void*)) {
  struct sigaction action = {};
  sigemptyset(&action.sa_mask);
  action.sa_flags = SA_SIGINFO;
  action.sa_sigaction = handler;
  check(sigaction(signal, &action, NULL) == 0, "sigaction failed");
}

static void test_signal_pipe_errno() {
  test_vm vm;
  {
    jit_writable_scope writable;
    vm.code = new code_heap(deck_size);
  }
  int fds[2];
  check(pipe(fds) == 0, "pipe failed");
  check(fcntl(fds[1], F_SETFL, O_NONBLOCK) == 0, "fcntl failed");
  vm.signal_pipe_output = fds[1];
  int signal = SIGUSR1;
  while (write(fds[1], &signal, sizeof(signal)) == sizeof(signal)) {}
  check(errno == EAGAIN, "could not fill signal pipe");
  for (auto handler : {enqueue_signal_handler, sample_signal_handler,
                       fep_signal_handler}) {
    install_handler(SIGUSR1, handler);
    errno = EDOM;
    int result = raise(SIGUSR1);
    int saved_errno = errno;
    check(result == 0, "raise failed");
    check(saved_errno == EDOM, "full signal pipe overwrote errno");
  }
  check(factor::atomic::load(&vm.safepoint_fep_p), "full pipe lost debugger interrupt");
  check(read(fds[0], &signal, sizeof(signal)) == sizeof(signal), "read failed");
  close(fds[0]);
  close(fds[1]);
}

static void test_signal_pipe_fd_zero() {
  test_vm vm;
  int fds[2];
  check(pipe(fds) == 0, "pipe failed");
  check(dup2(fds[1], STDIN_FILENO) == STDIN_FILENO, "dup2 failed");
  close(fds[1]);
  check(fcntl(fds[0], F_SETFL, O_NONBLOCK) == 0, "fcntl failed");
  vm.signal_pipe_output = STDIN_FILENO;
  install_handler(SIGUSR1, enqueue_signal_handler);
  check(raise(SIGUSR1) == 0, "raise failed");
  int signal = 0;
  check(read(fds[0], &signal, sizeof(signal)) == sizeof(signal),
        "signal notification skipped fd zero");
  check(signal == SIGUSR1, "wrong signal notification");
  close(fds[0]);
  close(STDIN_FILENO);
}

static bool alarm_pending_soon() {
  sigset_t pending;
  for (int i = 0; i < 1000; i++) {
    check(sigpending(&pending) == 0, "sigpending failed");
    if (sigismember(&pending, SIGALRM) == 1)
      return true;
    usleep(100);
  }
  return false;
}

static void test_timer(fixnum rate, long seconds, long microseconds) {
  test_vm vm;
  // Block timer delivery while inspecting even a one-microsecond interval.
  sigset_t mask;
  sigemptyset(&mask);
  sigaddset(&mask, SIGALRM);
  check(pthread_sigmask(SIG_BLOCK, &mask, NULL) == 0, "sigmask failed");
  vm.samples_per_second = rate;
  vm.start_sampling_profiler_timer();
  struct itimerval timer;
  check(getitimer(ITIMER_REAL, &timer) == 0, "getitimer failed");
  // Linux may defer rearming an expired timer until its pending signal is
  // delivered, and macOS may not have posted it yet. The one-microsecond
  // case can already be pending here.
  bool armed = timer.it_value.tv_sec != 0 || timer.it_value.tv_usec != 0 ||
               alarm_pending_soon();
  vm.end_sampling_profiler_timer();
#if defined(__FreeBSD__) || defined(__DragonFly__) || defined(__OpenBSD__) || defined(__NetBSD__)
  // BSD interval timers round short requests to the kernel clock resolution.
  struct clockinfo clocks;
  size_t clock_size = sizeof(clocks);
#if defined(__FreeBSD__) || defined(__DragonFly__)
  check(sysctlbyname("kern.clockrate", &clocks, &clock_size, NULL, 0) == 0,
        "clockrate query failed");
#else
  int clock_mib[] = {CTL_KERN, KERN_CLOCKRATE};
  check(sysctl(clock_mib, 2, &clocks, &clock_size, NULL, 0) == 0,
        "clockrate query failed");
#endif
  check(clocks.tick > 0, "invalid kernel clock resolution");
  const long requested = seconds * 1000000L + microseconds;
  const long observed = timer.it_interval.tv_sec * 1000000L + timer.it_interval.tv_usec;
  check(observed >= requested && observed <= std::max(requested, (long)clocks.tick),
        "incorrect rounded profiler timer interval");
#else
  check(timer.it_interval.tv_sec == seconds &&
            timer.it_interval.tv_usec == microseconds,
        "incorrect profiler timer interval");
#endif
  check(armed, "profiler timer was not armed");
  check(getitimer(ITIMER_REAL, &timer) == 0, "getitimer failed");
  check(timer.it_value.tv_sec == 0 && timer.it_value.tv_usec == 0,
        "profiler timer did not stop");
}

static void* raise_alarm(void*) {
  check(current_vm_p() == NULL, "worker should not have a VM");
  errno = EDOM;
  int result = raise(SIGALRM);
  int saved_errno = errno;
  check(result == 0, "raise failed");
  check(saved_errno == EDOM, "foreign SIGALRM overwrote errno");
  return NULL;
}

static void test_foreign_alarm_without_vm() {
  install_handler(SIGALRM, sample_signal_handler);
  pthread_t thread;
  check(pthread_create(&thread, NULL, raise_alarm, NULL) == 0, "pthread_create failed");
  check(pthread_join(thread, NULL) == 0, "pthread_join failed");
}

static void test_foreign_alarm_profiling() {
  test_vm vm;
  {
    jit_writable_scope writable;
    vm.code = new code_heap(deck_size);
  }
  vm.samples_per_second = 1;
  factor::atomic::store(&vm.sampling_profiler_p, true);
  install_handler(SIGALRM, sample_signal_handler);
  vm.start_sampling_profiler_timer();
  pthread_t thread;
  check(pthread_create(&thread, NULL, raise_alarm, NULL) == 0, "pthread_create failed");
  check(pthread_join(thread, NULL) == 0, "pthread_join failed");
  factor::atomic::store(&vm.sampling_profiler_p, false);
  vm.end_sampling_profiler_timer();
  check(factor::atomic::load(&vm.current_sample.foreign_thread_sample_count) >= 1,
        "foreign sample did not reach the timer's VM");
  fixnum samples = factor::atomic::load(&vm.current_sample.sample_count);
  // A late alarm after profiling stops must not keep sampling the old owner.
  check(pthread_create(&thread, NULL, raise_alarm, NULL) == 0, "pthread_create failed");
  check(pthread_join(thread, NULL) == 0, "pthread_join failed");
  check(factor::atomic::load(&vm.current_sample.sample_count) == samples,
        "late alarm sampled a stopped profiler");
}

static int status_within(unsigned seconds, void (*body)()) {
  pid_t pid = fork();
  check(pid >= 0, "fork failed");
  if (pid == 0) {
    alarm(seconds);
    body();
    _exit(0);
  }
  int status;
  check(waitpid(pid, &status, 0) == pid, "waitpid failed");
  return status;
}

static int* volatile unmapped_address = NULL;

static void* fault_without_vm(void*) {
  *unmapped_address = 0;
  return NULL;
}

static void fault_on_foreign_thread() {
  install_handler(SIGSEGV, memory_signal_handler);
  install_handler(SIGBUS, memory_signal_handler);
#ifdef __APPLE__
  mach_initialize();
#endif
  pthread_t thread;
  check(pthread_create(&thread, NULL, fault_without_vm, NULL) == 0,
        "pthread_create failed");
  pthread_join(thread, NULL);
}

static int foreign_diagnostic_pipe[2];

static void fault_with_diagnostic_pipe() {
  close(foreign_diagnostic_pipe[0]);
  check(dup2(foreign_diagnostic_pipe[1], STDERR_FILENO) == STDERR_FILENO,
        "dup2 failed");
  close(foreign_diagnostic_pipe[1]);
  fault_on_foreign_thread();
}

static void test_foreign_fault_without_vm() {
  check(pipe(foreign_diagnostic_pipe) == 0, "pipe failed");
  int status = status_within(10, fault_with_diagnostic_pipe);
  close(foreign_diagnostic_pipe[1]);
  char diagnostic[256] = {};
  ssize_t count = read(foreign_diagnostic_pipe[0], diagnostic, sizeof(diagnostic) - 1);
  close(foreign_diagnostic_pipe[0]);
  check(WIFEXITED(status) && WEXITSTATUS(status) == 1,
        "foreign thread fault did not end in fatal_error");
  check(count > 0 && strstr(diagnostic, "fatal_error: Foreign thread received signal:") &&
            strstr(diagnostic, "; pc=0x"),
        "foreign thread fault lost its signal/PC diagnostic");
  check(strstr(diagnostic, "Native backtrace") == NULL,
        "foreign thread fault attempted native unwinding in a signal handler");
  std::cerr << diagnostic;
}

static void fatal_error_while_fatal_erroring() {
  test_vm vm;
  install_handler(SIGTRAP, memory_signal_handler);
  install_handler(SIGSEGV, memory_signal_handler);
  install_handler(SIGBUS, memory_signal_handler);
  install_handler(SIGILL, synchronous_signal_handler);
  factor_vm::fatal_erroring_p = true;
  fatal_error("fatal error while fatal erroring", 0);
}

static void test_fatal_error_reentry() {
  int status = status_within(10, fatal_error_while_fatal_erroring);
  check(WIFEXITED(status) && WEXITSTATUS(status) == 86,
        "re-entered fatal_error did not exit with status 86");
}

static void test_small_callstack_signal_stack() {
  test_vm vm;
  vm.callstack_size = getpagesize();
  vm.unix_init_signals();
  stack_t stack;
  check(sigaltstack(NULL, &stack) == 0, "sigaltstack query failed");
  check(stack.ss_size >= (size_t)SIGSTKSZ, "signal stack is below SIGSTKSZ");
}

static volatile sig_atomic_t interrupts = 0;

static void count_interrupt(int, siginfo_t*, void*) { interrupts++; }

static void test_waiting_shell_signals() {
  struct sigaction action = {}, before, after;
  sigemptyset(&action.sa_mask);
  sigaddset(&action.sa_mask, SIGUSR1);
  action.sa_sigaction = count_interrupt;
  action.sa_flags = SA_SIGINFO | SA_RESTART | SA_ONSTACK;
  check(sigaction(SIGINT, &action, NULL) == 0, "sigaction failed");
  check(sigaction(SIGINT, NULL, &before) == 0, "sigaction query failed");
  factor_begin_ignore_console_signals();
  factor_begin_ignore_console_signals();
  factor_end_ignore_console_signals();
  check(raise(SIGINT) == 0 && interrupts == 0, "nested suppression ended early");
  pid_t pid = fork();
  check(pid >= 0, "fork failed");
  if (pid == 0) {
    execl(executable_path, executable_path, "--raise-sigint", (char*)NULL);
    _exit(99);
  }
  int status;
  check(waitpid(pid, &status, 0) == pid, "waitpid failed");
  check(WIFSIGNALED(status) && WTERMSIG(status) == SIGINT,
        "exec child inherited ignored SIGINT");
  factor_end_ignore_console_signals();
  check(sigaction(SIGINT, NULL, &after) == 0, "sigaction query failed");
  check(after.sa_sigaction == before.sa_sigaction && after.sa_flags == before.sa_flags &&
            sigismember(&after.sa_mask, SIGUSR1) == 1,
        "shell did not restore the complete sigaction");
  check(raise(SIGINT) == 0 && interrupts == 1, "restored handler did not run");
}

// Probe the safepoint page: true if touching it faults (the page is armed).
static sigjmp_buf probe_env;
static void probe_segv_handler(int, siginfo_t*, void*) {
  siglongjmp(probe_env, 1);
}

static bool safepoint_armed(factor_vm& vm) {
  struct sigaction before_segv, before_bus;
  check(sigaction(SIGSEGV, NULL, &before_segv) == 0, "sigaction query failed");
  check(sigaction(SIGBUS, NULL, &before_bus) == 0, "sigaction query failed");
  install_handler(SIGSEGV, probe_segv_handler);
  install_handler(SIGBUS, probe_segv_handler);
  bool faulted = sigsetjmp(probe_env, 1) != 0;
  if (!faulted)
    (void)*(volatile cell*)vm.code->safepoint_page;
  check(sigaction(SIGSEGV, &before_segv, NULL) == 0, "sigaction restore failed");
  check(sigaction(SIGBUS, &before_bus, NULL) == 0, "sigaction restore failed");
  return faulted;
}

// After a sample is recorded the safepoint is disarmed so the program makes
// progress even when recording outlasts the timer interval. A debugger
// interrupt that arrived meanwhile has armed the same page and must survive.
static void test_disarm_safepoint_after_sample() {
  test_vm vm;
  {
    jit_writable_scope writable;
    vm.code = new code_heap(deck_size);
  }
  factor::atomic::store(&vm.sampling_profiler_p, true);
  vm.code->set_safepoint_guard(false);
  check(!safepoint_armed(vm), "safepoint page starts disarmed");

  // A timer tick during the sample re-armed the page: disarm it.
  vm.enqueue_samples(1, 0, false);
  check(safepoint_armed(vm), "enqueue_samples did not arm the safepoint");
  vm.disarm_safepoint_after_sample();
  check(!safepoint_armed(vm), "disarm kept the profiler's arming");

  // Ctrl-C during the sample: the page must stay armed.
  vm.enqueue_samples(1, 0, false);
  vm.enqueue_fep();
  vm.disarm_safepoint_after_sample();
  check(safepoint_armed(vm), "disarm lost a pending debugger interrupt");
  check(factor::atomic::load(&vm.safepoint_fep_p), "disarm cleared safepoint_fep_p");
  vm.code->set_safepoint_guard(false);
}

// Each test owns its process, handlers, timers, and descriptors. A regression
// that crashes a signal handler must not prevent the other checks from running.
static bool run_test(const char* name, void (*test)()) {
  pid_t pid = fork();
  check(pid >= 0, "fork failed");
  if (pid == 0) {
    init_mvm();
    test();
    _exit(0);
  }
  int status;
  pid_t result;
  do {
    result = waitpid(pid, &status, 0);
  } while (result < 0 && errno == EINTR);
  check(result == pid, "waitpid failed");
  bool passed = WIFEXITED(status) && WEXITSTATUS(status) == 0;
  std::cout << (passed ? "PASS " : "FAIL ") << name << std::endl;
  return passed;
}

#if defined(FACTOR_LOONGARCH64) || defined(FACTOR_NO_PTHREAD_CANCEL)
static void test_console_idle_shutdown() {
  // Bound a hung join independently of the suite's external deadline.
  alarm(10);
  open_console();
  close_console();
  check(!stdin_thread_initialized_p, "idle console worker did not stop");
  close_console();
  alarm(0);
}

static void test_console_disposed_input_shutdown() {
  alarm(10);
  open_console();
  // Factor's input stream owns these three descriptors and may dispose them
  // before the VM shuts down its console worker.
  check(close(stdin_read) == 0, "stdin reader close failed");
  check(close(size_read) == 0, "stdin size reader close failed");
  check(close(control_write) == 0, "stdin control writer close failed");
  close_console();
  check(!stdin_thread_initialized_p, "disposed console worker did not stop");
  close_console();
  alarm(0);
}

static void ignore_console_interrupt(int, siginfo_t*, void*) {}

static void test_console_input() {
  alarm(10);
  int input[2];
  check(pipe(input) == 0, "stdin pipe failed");
  check(dup2(input[0], STDIN_FILENO) == STDIN_FILENO, "stdin dup2 failed");
  close(input[0]);
  int flags = fcntl(STDIN_FILENO, F_GETFL);
  check(flags >= 0 && !(flags & O_NONBLOCK), "stdin was not blocking");
  open_console();
  check(write(input[1], "data", 4) == 4, "stdin data write failed");
  char request = 'X';
  check(write(control_write, &request, 1) == 1, "stdin request failed");
  ssize_t size = -1;
  check(read(size_read, &size, sizeof(size)) == sizeof(size) && size == 4,
        "stdin worker reported wrong size");
  char bytes[4];
  check(read(stdin_read, bytes, sizeof(bytes)) == sizeof(bytes) &&
            memcmp(bytes, "data", 4) == 0,
        "stdin worker lost input");
  close_console();
  check(fcntl(STDIN_FILENO, F_GETFL) == flags, "stdin flags changed");
  close(input[1]);
  alarm(0);
}

static void test_console_reader_shutdown(bool debugger_locked) {
  alarm(10);
  int input[2];
  check(pipe(input) == 0, "stdin pipe failed");
  check(dup2(input[0], STDIN_FILENO) == STDIN_FILENO, "stdin dup2 failed");
  close(input[0]);
  install_handler(SIGUSR2, ignore_console_interrupt);
  open_console();
  if (debugger_locked)
    lock_console();
  char request = 'X';
  check(write(control_write, &request, 1) == 1, "stdin request failed");
  // Let the worker consume the request and wait for stdin or the debugger.
  usleep(50000);
  close_console();
  check(!stdin_thread_initialized_p, "busy console worker did not stop");
  if (debugger_locked)
    check(pthread_mutex_unlock(&stdin_mutex) == 0, "debugger mutex cleanup failed");
  close(input[1]);
  alarm(0);
}
#endif

int main(int argc, char** argv) {
  executable_path = argv[0];
  if (argc == 2 && strcmp(argv[1], "--raise-sigint") == 0) {
    raise(SIGINT);
    return 17;
  }
  bool passed = true;
  passed &= run_test("signal pipe errno", test_signal_pipe_errno);
  passed &= run_test("signal pipe fd zero", test_signal_pipe_fd_zero);
  passed &= run_test("profiler 1 Hz", []() { test_timer(1, 1, 0); });
  passed &= run_test("profiler 1000 Hz", []() { test_timer(1000, 0, 1000); });
  passed &= run_test("profiler above timer resolution", []() { test_timer(1000001, 0, 1); });
  passed &= run_test("SIGALRM on a foreign thread without a VM", test_foreign_alarm_without_vm);
  passed &= run_test("foreign samples reach the active profiler", test_foreign_alarm_profiling);
  passed &= run_test("waiting shell signal suppression", test_waiting_shell_signals);
  passed &= run_test("disarming after a sample keeps a debugger interrupt", test_disarm_safepoint_after_sample);
  passed &= run_test("fault on a foreign thread without a VM", test_foreign_fault_without_vm);
  passed &= run_test("fatal error while fatal erroring", test_fatal_error_reentry);
  passed &= run_test("signal stack with a small callstack", test_small_callstack_signal_stack);
#if defined(FACTOR_LOONGARCH64) || defined(FACTOR_NO_PTHREAD_CANCEL)
  passed &= run_test("idle console shutdown", test_console_idle_shutdown);
  passed &= run_test("disposed stdin console shutdown", test_console_disposed_input_shutdown);
  passed &= run_test("console input preserves blocking stdin", test_console_input);
  passed &= run_test("stdin reader shutdown", []() { test_console_reader_shutdown(false); });
  passed &= run_test("debugger console shutdown", []() { test_console_reader_shutdown(true); });
#endif
  return passed ? 0 : 1;
}
