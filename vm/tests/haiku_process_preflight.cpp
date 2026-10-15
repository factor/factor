// NATIVE HAIKU ONLY. Build as a shared test library; the running Factor VM
// supplies the actual exported launcher APIs. Invoke in a fresh Factor process.
#ifdef NDEBUG
#error "Native Haiku preflight controls require active assertions; compile with -UNDEBUG"
#endif
#include <cassert>
#include <cerrno>
#include <cstdio>
#include <signal.h>
#include <sys/wait.h>
#include <unistd.h>
extern "C" int factor_haiku_prepare_process();
extern "C" int factor_haiku_watch_process(int);
extern "C" int factor_haiku_next_process_exit(int*, int*);
static void caught(int) {}
static void no_children() {
  int status = 0;
  errno = 0;
  assert(waitpid(-1, &status, WNOHANG) == -1 && errno == ECHILD);
}
static void check(void (*handler)(int), int flags, bool accepted) {
  struct sigaction action = {};
  action.sa_handler = handler;
  action.sa_flags = flags;
  assert(sigemptyset(&action.sa_mask) == 0);
  assert(sigaction(SIGCHLD, &action, NULL) == 0);
  no_children();
  errno = 0;
  int result = factor_haiku_prepare_process();
  int error = errno;
  assert(accepted ? result == 0 : result == -1 && error == ENOTSUP);
  // Preflight must neither spawn a child nor change the caller's disposition.
  no_children();
  struct sigaction after;
  assert(sigaction(SIGCHLD, NULL, &after) == 0);
  assert(after.sa_handler == handler);
  assert((static_cast<unsigned int>(after.sa_flags)
      & static_cast<unsigned int>(SA_NOCLDWAIT | SA_RESETHAND))
      == static_cast<unsigned int>(flags));
}
extern "C" int factor_test_haiku_process_preflight() {
  struct sigaction original;
  assert(sigaction(SIGCHLD, NULL, &original) == 0);
  no_children();
  for (int installed = 0; installed < 2; installed++) {
    check(SIG_DFL, 0, true);
    check(SIG_IGN, 0, false);
    check(caught, SA_NOCLDWAIT, false);
    check(caught, SA_RESETHAND, false);
    if (!installed) {
      check(SIG_DFL, 0, true);
      // Establish the real watcher's installed state with one owned native child.
      pid_t child = fork();
      assert(child >= 0);
      if (child == 0) _exit(0);
      assert(factor_haiku_watch_process(child) == 0);
      int pid = 0, status = 0, available = 0;
      for (int n = 0; n < 1000 && !available; n++) {
        available = factor_haiku_next_process_exit(&pid, &status);
        assert(available >= 0);
        if (!available) usleep(10000);
      }
      assert(available == 1 && pid == child);
      assert(WIFEXITED(status) && WEXITSTATUS(status) == 0);
      no_children();
    }
  }
  assert(sigaction(SIGCHLD, &original, NULL) == 0);
  puts("NATIVE HAIKU: preflight DFL/IGN/NOCLDWAIT/RESETHAND before-and-after-watch/no-child/disposition PASS");
  return 0;
}
