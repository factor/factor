#define _GNU_SOURCE
#include <errno.h>
#include <linux/perf_event.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/syscall.h>
#include <sys/resource.h>
#include <time.h>
#include <unistd.h>
static int counter_fd = -1;
static int counter_errno;
__attribute__((constructor)) static void init_counter(void) {
  struct perf_event_attr attr = {0};
  attr.type = PERF_TYPE_HARDWARE;
  attr.size = sizeof(attr);
  attr.config = PERF_COUNT_HW_INSTRUCTIONS;
  attr.exclude_kernel = 1;
  attr.exclude_hv = 1;
  counter_fd = syscall(SYS_perf_event_open, &attr, 0, -1, -1, 0);
  if (counter_fd < 0) counter_errno = errno;
}
uint64_t compiler_instructions(void) {
  uint64_t count = 0;
  if (counter_fd < 0 || read(counter_fd, &count, sizeof(count)) != sizeof(count)) abort();
  return count;
}
int compiler_counter_error(void) { return counter_errno; }
double compiler_cpu_seconds(void) {
  struct timespec t;
  clock_gettime(CLOCK_THREAD_CPUTIME_ID, &t);
  return t.tv_sec + t.tv_nsec * 1e-9;
}
int compiler_background(void) { return getpriority(PRIO_PROCESS, 0) > 0; }
int compiler_foreground(void) { return compiler_background(); }
