/* Linux x86-64 libc ABI used by Factor's FFI. Run with both glibc and musl. */
#define _GNU_SOURCE
#include <assert.h>
#include <dirent.h>
#include <dlfcn.h>
#include <errno.h>
#include <netdb.h>
#include <stddef.h>
#include <spawn.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/statvfs.h>
#include <sys/vfs.h>
#include <time.h>

#if !defined(__linux__) || !defined(__x86_64__)
#error "This probe validates Linux x86-64 only"
#endif

_Static_assert(sizeof(struct stat) == 144, "stat size");
_Static_assert(offsetof(struct stat, st_nlink) == 16, "stat nlink");
_Static_assert(offsetof(struct stat, st_mode) == 24, "stat mode");
_Static_assert(offsetof(struct stat, st_size) == 48, "stat size field");
_Static_assert(offsetof(struct stat, st_atim) == 72, "stat timestamp");
_Static_assert(sizeof(time_t) == 8, "time_t");
_Static_assert(sizeof(struct dirent) == 280, "dirent size");
_Static_assert(offsetof(struct dirent, d_name) == 19, "dirent name");
_Static_assert(sizeof(struct addrinfo) == 48, "addrinfo size");
_Static_assert(offsetof(struct addrinfo, ai_addr) == 24, "addrinfo address");
_Static_assert(offsetof(struct addrinfo, ai_canonname) == 32, "addrinfo name");
_Static_assert(sizeof(posix_spawnattr_t) == 336, "spawn attributes storage");
_Static_assert(sizeof(posix_spawn_file_actions_t) == 80, "spawn actions storage");
_Static_assert(sizeof(sigset_t) == 128, "signal set storage");
_Static_assert(sizeof(struct statfs) == 120, "statfs storage");
_Static_assert(sizeof(struct statvfs) == 112, "statvfs storage");

int main(void) {
  void *process = dlopen(NULL, RTLD_NOW);
  assert(process);
  const char *required[] = {"open", "readdir", "readdir_r", "statfs", "statvfs"};
  for (size_t i = 0; i < sizeof(required) / sizeof(required[0]); ++i)
    assert(dlsym(process, required[i]));
  int (*error_string)(int, char *, size_t) =
      (int (*)(int, char *, size_t))dlsym(process, "__xpg_strerror_r");
  assert(error_string);
  char text[1024];
  assert(error_string(EPERM, text, sizeof(text)) == 0);
  assert(strcmp(text, "Operation not permitted") == 0);
  assert(error_string(EPERM, text, 1) == ERANGE);

  int (*path_stat)(const char *, struct stat *) =
      (int (*)(const char *, struct stat *))dlsym(process, "stat");
  int (*path_lstat)(const char *, struct stat *) =
      (int (*)(const char *, struct stat *))dlsym(process, "lstat");
  int (*fd_stat)(int, struct stat *) =
      (int (*)(int, struct stat *))dlsym(process, "fstat");
  assert(path_stat && path_lstat && fd_stat);
  struct stat s;
  assert(path_stat("/", &s) == 0 && S_ISDIR(s.st_mode));
  assert(path_lstat("/", &s) == 0 && S_ISDIR(s.st_mode));
  FILE *file = tmpfile();
  assert(file);
  assert(fwrite("factor", 1, 6, file) == 6 && fflush(file) == 0);
  assert(fd_stat(fileno(file), &s) == 0 && s.st_size == 6);
  assert(fclose(file) == 0);
  struct statfs fs;
  struct statvfs vfs;
  assert(statfs("/", &fs) == 0 && fs.f_bsize > 0);
  assert(statvfs("/", &vfs) == 0 && vfs.f_bsize > 0);

  struct addrinfo hints = {0}, *addresses = NULL;
  hints.ai_family = AF_INET;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_flags = AI_NUMERICHOST | AI_NUMERICSERV;
  assert(getaddrinfo("127.0.0.1", "80", &hints, &addresses) == 0);
  assert(addresses && addresses->ai_addr && addresses->ai_family == AF_INET);
  freeaddrinfo(addresses);
  dlclose(process);
  puts("Linux x86-64 libc FFI layout and symbol probe: PASS");
  return 0;
}
