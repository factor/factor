#define _GNU_SOURCE
#if defined(__powerpc__) && !defined(__powerpc64__)
#undef _TIME_BITS
#define _TIME_BITS 32
#undef _FILE_OFFSET_BITS
#define _FILE_OFFSET_BITS 64
#endif
#include <sys/stat.h>
#include <fcntl.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <assert.h>
#define FIELD(x) printf("%s %zu %zu\n",#x,offsetof(struct stat64,x),sizeof(((struct stat64*)0)->x))
int main(void) {
 printf("stat64 %zu %zu pointer %zu time_t %zu timespec %zu\n",sizeof(struct stat64),_Alignof(struct stat64),sizeof(void*),sizeof(time_t),sizeof(struct timespec));
 FIELD(st_dev);FIELD(st_ino);FIELD(st_mode);FIELD(st_nlink);FIELD(st_uid);FIELD(st_gid);FIELD(st_rdev);FIELD(st_size);FIELD(st_blksize);FIELD(st_blocks);FIELD(st_atim);FIELD(st_mtim);FIELD(st_ctim);
 char name[]="/tmp/factor-ppc-stat-XXXXXX";int fd=mkstemp(name);assert(fd>=0);
 off64_t size=((off64_t)5<<30)+17;assert(ftruncate64(fd,size)==0);
 struct timespec ts[2]={{1700000000,123456789},{1700000001,987654321}};assert(futimens(fd,ts)==0);
 struct stat64 a,b,c;assert(stat64(name,&a)==0);assert(fstat64(fd,&b)==0);assert(lstat64(name,&c)==0);
 assert(a.st_size==size && b.st_size==size && c.st_size==size);assert(a.st_ino==b.st_ino && b.st_ino==c.st_ino);assert(S_ISREG(a.st_mode));assert(a.st_mtim.tv_sec==1700000001 && a.st_mtim.tv_nsec==987654321);
 assert(close(fd)==0);assert(unlink(name)==0);puts("PPC stat64 native wide-size and timestamp calls passed");return 0;
}
