#define _GNU_SOURCE
#include <sys/stat.h>
#include <stddef.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>
#include <stdint.h>
#include <dlfcn.h>
#define P(f) printf(#f "=%zu\n",offsetof(struct stat64,f));
struct binding_stat {
uint64_t st_dev; unsigned int pad1; unsigned long oldino;
unsigned int st_mode,st_nlink,st_uid,st_gid;uint64_t st_rdev;
unsigned int pad2; int64_t st_size;long st_blksize;int64_t st_blocks;
struct timespec atim,mtim,ctim;uint64_t st_ino;
};
#define CHECK(a,b) _Static_assert(offsetof(struct binding_stat,a)==offsetof(struct stat64,b), #a)
CHECK(st_dev,st_dev);CHECK(pad1,__pad1);CHECK(oldino,__st_ino);CHECK(st_mode,st_mode);CHECK(st_nlink,st_nlink);CHECK(st_uid,st_uid);CHECK(st_gid,st_gid);CHECK(st_rdev,st_rdev);CHECK(pad2,__pad2);CHECK(st_size,st_size);CHECK(st_blksize,st_blksize);CHECK(st_blocks,st_blocks);CHECK(atim,st_atim);CHECK(mtim,st_mtim);CHECK(ctim,st_ctim);CHECK(st_ino,st_ino);
_Static_assert(sizeof(struct binding_stat)==sizeof(struct stat64),"size");
_Static_assert(_Alignof(struct binding_stat)==_Alignof(struct stat64),"align");
int main(void){
printf("size=%zu align=%zu\n",sizeof(struct stat64),_Alignof(struct stat64));
P(st_dev);P(__pad1);P(__st_ino);P(st_mode);P(st_nlink);P(st_uid);P(st_gid);P(st_rdev);P(__pad2);P(st_size);P(st_blksize);P(st_blocks);P(st_atim);P(st_mtim);P(st_ctim);P(st_ino);
struct stat64 s,l,f; char path[]="/tmp/io-binding-stat-XXXXXX";int fd=mkstemp(path);assert(fd>=0);assert(write(fd,"binding",7)==7);assert(stat64(path,&s)==0);assert(lstat64(path,&l)==0);assert(fstat64(fd,&f)==0);assert(s.st_size==7&&l.st_size==7&&f.st_size==7);assert(s.st_ino==f.st_ino&&s.st_ino==l.st_ino);printf("roundtrip=PASS size=%lld ino=%llu mode=%o\n",(long long)s.st_size,(unsigned long long)s.st_ino,s.st_mode);struct {struct binding_stat value; uint64_t guard;} bs={.guard=0x0123456789abcdef},bl={.guard=0x0123456789abcdef},bf={.guard=0x0123456789abcdef};
int (*stat_call)(const char*,struct binding_stat*)=dlsym(RTLD_DEFAULT,"stat64");
int (*lstat_call)(const char*,struct binding_stat*)=dlsym(RTLD_DEFAULT,"lstat64");
int (*fstat_call)(int,struct binding_stat*)=dlsym(RTLD_DEFAULT,"fstat64");
assert(stat_call&&lstat_call&&fstat_call);assert(stat_call(path,&bs.value)==0);assert(lstat_call(path,&bl.value)==0);assert(fstat_call(fd,&bf.value)==0);
assert(bs.value.st_size==7&&bl.value.st_size==7&&bf.value.st_size==7);
assert(bs.value.st_ino==s.st_ino&&bl.value.st_ino==s.st_ino&&bf.value.st_ino==s.st_ino);
assert(bs.value.st_mode==s.st_mode&&bs.value.atim.tv_sec==s.st_atim.tv_sec);
assert(bs.guard==0x0123456789abcdef&&bl.guard==bs.guard&&bf.guard==bs.guard);
printf("binding-mirror=PASS symbols=stat64,lstat64,fstat64 guard=PASS\n");close(fd);unlink(path);return 0;}
