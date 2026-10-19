/* Linux GNU SuperH legacy stat64 ABI. Compile with explicit -U_TIME_BITS
 * -D_TIME_BITS=32 -U_FILE_OFFSET_BITS -D_FILE_OFFSET_BITS=64: newer GNU
 * distributions default to different time64-redirection structs/symbols. */
#define _GNU_SOURCE 1
#include <sys/stat.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <assert.h>
#define FIELD(n) printf(#n "=%zu/%zu\n",offsetof(struct stat64,n),sizeof(((struct stat64*)0)->n))
_Static_assert(sizeof(struct stat64)==96,"legacy stat64 size");
_Static_assert(_Alignof(struct stat64)==4,"SH scalar alignment");
_Static_assert(offsetof(struct stat64,st_size)==44,"size offset");
_Static_assert(offsetof(struct stat64,st_blocks)==56,"blocks offset");
_Static_assert(offsetof(struct stat64,st_atim)==64,"time offset");
_Static_assert(offsetof(struct stat64,st_ino)==88,"inode offset");
int main(void){printf("stat64=%zu align=%zu time_t=%zu timespec=%zu\n",sizeof(struct stat64),_Alignof(struct stat64),sizeof(time_t),sizeof(struct timespec));FIELD(st_dev);FIELD(__pad1);FIELD(__st_ino);FIELD(st_mode);FIELD(st_nlink);FIELD(st_uid);FIELD(st_gid);FIELD(st_rdev);FIELD(__pad2);FIELD(st_size);FIELD(st_blksize);FIELD(st_blocks);FIELD(st_atim);FIELD(st_mtim);FIELD(st_ctim);FIELD(st_ino);struct stat64 s,l,f;const char*p="/tmp/sh4-stat-native-proof";int fd=open(p,O_CREAT|O_TRUNC|O_RDWR,0600);assert(fd>=0);assert(write(fd,"abcdefg",7)==7);assert(stat64(p,&s)==0);assert(fstat64(fd,&f)==0);assert(lstat64(p,&l)==0);assert(s.st_size==7&&f.st_size==7&&l.st_size==7);assert(s.st_ino==f.st_ino&&f.st_ino==l.st_ino);assert(S_ISREG(s.st_mode));close(fd);unlink(p);puts("SH4-NATIVE-STAT64-LAYOUT-SYMBOLS-PASS");}
