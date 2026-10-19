#include <sys/stat.h>
#include <sys/epoll.h>
#include <cstddef>
#include <cassert>
#include <cstdio>

// Independently checked against glibc's native System z declarations.
static_assert(sizeof(struct stat) == 144);
static_assert(offsetof(struct stat, st_dev) == 0);
static_assert(offsetof(struct stat, st_ino) == 8);
static_assert(offsetof(struct stat, st_nlink) == 16);
static_assert(offsetof(struct stat, st_mode) == 24);
static_assert(offsetof(struct stat, st_uid) == 28);
static_assert(offsetof(struct stat, st_gid) == 32);
static_assert(offsetof(struct stat, st_rdev) == 40);
static_assert(offsetof(struct stat, st_size) == 48);
static_assert(offsetof(struct stat, st_atim) == 56);
static_assert(offsetof(struct stat, st_mtim) == 72);
static_assert(offsetof(struct stat, st_ctim) == 88);
static_assert(offsetof(struct stat, st_blksize) == 104);
static_assert(offsetof(struct stat, st_blocks) == 112);
static_assert(sizeof(epoll_event) == 16);
static_assert(offsetof(epoll_event, data) == 8);

int main() {
  FILE* file = tmpfile();
  assert(file);
  assert(fputs("abc", file) >= 0);
  assert(!fflush(file));
  struct stat status;
  assert(!fstat(fileno(file), &status));
  assert(status.st_size == 3);
  assert(S_ISREG(status.st_mode));
  assert(status.st_mtim.tv_sec > 0);
  fclose(file);
  puts("s390x glibc stat144/epoll16 and real file metadata PASS");
}
