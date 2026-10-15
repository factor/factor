// Compile and run only with native Haiku x86_64 in the prospective QEMU guest.
// Public ABI check; this is not the independent native FP suite.
#include <cstddef>
#include <cstdio>
#include <sys/stat.h>
#include <sys/select.h>
#include <sys/time.h>
#include <sys/un.h>
#include <dirent.h>
#include <pwd.h>
#include <netdb.h>
#include <netinet/in.h>
#include <spawn.h>
#include <fs_info.h>
#include <time.h>
#include "../os-haiku-x86.64.hpp"
static_assert(sizeof(void*) == 8, "x86_64 lane");
static_assert(sizeof(dev_t) == 4 && sizeof(mode_t) == 4, "file scalar types");
static_assert(sizeof(suseconds_t) == 4 && sizeof(timeval) == 16, "timeval");
static_assert(sizeof(tm) == 48 && offsetof(tm, tm_gmtoff) == 36, "tm");
static_assert(sizeof(struct stat) == 128 && offsetof(struct stat, st_blocks) == 120, "stat");
static_assert(offsetof(dirent, d_name) == 26, "flexible dirent");
static_assert(sizeof(sockaddr_in) == 32, "IPv4 sockaddr");
static_assert(sizeof(sockaddr_in6) == 28, "IPv6 sockaddr");
static_assert(sizeof(sockaddr_un) == 128, "local sockaddr");
static_assert(sizeof(passwd) == 48 && offsetof(passwd, pw_gecos) == 40, "passwd");
static_assert(sizeof(addrinfo) == 48 && offsetof(addrinfo, ai_addr) == 32, "addrinfo");
static_assert(sizeof(fs_info) == 488, "mounted volume");
static_assert(sizeof(fd_mask) == 4 && sizeof(fd_set) == 128, "select masks");
static_assert(CLOCK_MONOTONIC == 0 && CLOCK_REALTIME == -1, "clock IDs");
static_assert(POSIX_SPAWN_SETSIGDEF == 0x10 && POSIX_SPAWN_SETSIGMASK == 0x20, "spawn flags");
int main() {
  ucontext_t context = {};
  context.uc_mcontext.fpu.fp_fxsave.status = 0x21;
  context.uc_mcontext.fpu.fp_fxsave.mxcsr = 0x1fa1;
  if ((factor::uap_fpu_status(&context) & 0x3f) != 0x21) return 1;
  factor::uap_clear_fpu_status(&context);
  if (context.uc_mcontext.fpu.fp_fxsave.status != 0 ||
      context.uc_mcontext.fpu.fp_fxsave.mxcsr != 0x1f80) return 2;
  puts("native Haiku x86_64 public ABI and saved FPU fields: PASS");
}
