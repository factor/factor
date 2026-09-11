#include "../master.hpp"
#include <sys/wait.h>

using namespace factor;

namespace factor {
void enqueue_signal_handler(int, siginfo_t*, void*);
void fep_signal_handler(int, siginfo_t*, void*);
void sample_signal_handler(int, siginfo_t*, void*);
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
  vm.code = new code_heap(deck_size);
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
  check(atomic::load(&vm.safepoint_fep_p), "full pipe lost debugger interrupt");
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
  sigset_t pending;
  check(sigpending(&pending) == 0, "sigpending failed");
  vm.end_sampling_profiler_timer();
  check(timer.it_interval.tv_sec == seconds &&
            timer.it_interval.tv_usec == microseconds,
        "incorrect profiler timer interval");
  // Linux may defer rearming an expired timer until its pending signal is
  // delivered. The one-microsecond case can already be pending here.
  check(timer.it_value.tv_sec != 0 || timer.it_value.tv_usec != 0 ||
            sigismember(&pending, SIGALRM) == 1,
        "profiler timer was not armed");
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
  vm.code = new code_heap(deck_size);
  vm.samples_per_second = 1;
  atomic::store(&vm.sampling_profiler_p, true);
  install_handler(SIGALRM, sample_signal_handler);
  vm.start_sampling_profiler_timer();
  pthread_t thread;
  check(pthread_create(&thread, NULL, raise_alarm, NULL) == 0, "pthread_create failed");
  check(pthread_join(thread, NULL) == 0, "pthread_join failed");
  atomic::store(&vm.sampling_profiler_p, false);
  vm.end_sampling_profiler_timer();
  check(atomic::load(&vm.current_sample.foreign_thread_sample_count) >= 1,
        "foreign sample did not reach the timer's VM");
  fixnum samples = atomic::load(&vm.current_sample.sample_count);
  // A late alarm after profiling stops must not keep sampling the old owner.
  check(pthread_create(&thread, NULL, raise_alarm, NULL) == 0, "pthread_create failed");
  check(pthread_join(thread, NULL) == 0, "pthread_join failed");
  check(atomic::load(&vm.current_sample.sample_count) == samples,
        "late alarm sampled a stopped profiler");
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

int main() {
  bool passed = true;
  passed &= run_test("signal pipe errno", test_signal_pipe_errno);
  passed &= run_test("signal pipe fd zero", test_signal_pipe_fd_zero);
  passed &= run_test("profiler 1 Hz", []() { test_timer(1, 1, 0); });
  passed &= run_test("profiler 1000 Hz", []() { test_timer(1000, 0, 1000); });
  passed &= run_test("profiler above timer resolution", []() { test_timer(1000001, 0, 1); });
  passed &= run_test("SIGALRM on a foreign thread without a VM", test_foreign_alarm_without_vm);
  passed &= run_test("foreign samples reach the active profiler", test_foreign_alarm_profiling);
  return passed ? 0 : 1;
}
