// Audit the legacy libc symbols bound by unix.stat.linux.m68k.32. New GCC
// distributions enable time64 header redirects by default; Factor binds the
// unchanged stat64 symbol and its explicitly declared 32-bit timespec layout.
#ifdef _TIME_BITS
#undef _TIME_BITS
#endif
#define _TIME_BITS 32
#define _LARGEFILE64_SOURCE
#include <sys/stat.h>
#include <stddef.h>
#include <stdio.h>

#define OFFSET(field, expected) \
  _Static_assert(offsetof(struct stat64, field) == expected, #field)
_Static_assert(sizeof(struct stat64) == 92, "stat64 size");
_Static_assert(_Alignof(struct stat64) == 2, "stat64 alignment");
OFFSET(st_dev, 0);
OFFSET(__st_ino, 10);
OFFSET(st_mode, 14);
OFFSET(st_nlink, 18);
OFFSET(st_uid, 22);
OFFSET(st_gid, 26);
OFFSET(st_rdev, 30);
OFFSET(st_size, 40);
OFFSET(st_blksize, 48);
OFFSET(st_blocks, 52);
OFFSET(st_atim, 60);
OFFSET(st_mtim, 68);
OFFSET(st_ctim, 76);
OFFSET(st_ino, 84);

int main(void) {
  struct stat64 data;
  if (stat64("/tmp", &data) != 0 || !S_ISDIR(data.st_mode))
    return 1;
  puts("m68k libc stat64 layout and native call: PASS");
  return 0;
}
