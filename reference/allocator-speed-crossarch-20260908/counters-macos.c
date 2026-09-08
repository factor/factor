#include <mach/mach.h>
#include <mach/thread_info.h>
#include <pthread.h>
#include <spawn.h>
#include <stdio.h>
#include <sys/wait.h>
extern char **environ;
#include <stdint.h>
#include <time.h>
#include <unistd.h>
#include <libproc.h>
#include <sys/resource.h>
uint64_t compiler_instructions(void) {
  struct rusage_info_v4 usage;
  if (proc_pid_rusage(getpid(), RUSAGE_INFO_V4, (rusage_info_t *)&usage)) return 0;
  return usage.ri_instructions;
}
double compiler_cpu_seconds(void) {
  struct timespec t;
  clock_gettime(CLOCK_THREAD_CPUTIME_ID, &t);
  return t.tv_sec + t.tv_nsec * 1e-9;
}

int compiler_background(void) {
  thread_extended_info_data_t info;
  mach_msg_type_number_t count = THREAD_EXTENDED_INFO_COUNT;
  if (thread_info(pthread_mach_thread_np(pthread_self()), THREAD_EXTENDED_INFO,
                  (thread_info_t)&info, &count) != KERN_SUCCESS) return 1;
  return info.pth_priority < 20;
}
// macOS distinguishes internal and externally imposed background policy.
// A helper process is necessary to clear the latter, just like taskpolicy -B.
int compiler_foreground(void) {
  if (!compiler_background()) return 0;
  char pid[32]; snprintf(pid, sizeof(pid), "%d", getpid());
  char *args[] = {"/usr/sbin/taskpolicy", "-B", "-p", pid, NULL};
  pid_t child; int status;
  int error = posix_spawn(&child, args[0], NULL, NULL, args, environ);
  if (error) return error;
  if (waitpid(child, &status, 0) != child || !WIFEXITED(status) || WEXITSTATUS(status)) return 1;
  pthread_set_qos_class_self_np(QOS_CLASS_USER_INITIATED, 0);
  return compiler_background();
}
