#define _GNU_SOURCE
#include <sys/stat.h>
#include <sys/epoll.h>
#include <spawn.h>
#include <stddef.h>
#include <stdio.h>
#define F(s,f) printf(#s "." #f "=%zu,%zu\n",offsetof(struct s,f),sizeof(((struct s*)0)->f))
int main(void){
printf("pointer_bits=%zu stat=%zu,%zu stat64=%zu,%zu nlink=%zu\n",8*sizeof(void*),sizeof(struct stat),_Alignof(struct stat),sizeof(struct stat64),_Alignof(struct stat64),sizeof(nlink_t));
F(stat64,st_dev);F(stat64,st_ino);F(stat64,st_mode);F(stat64,st_nlink);F(stat64,st_uid);F(stat64,st_gid);F(stat64,st_rdev);F(stat64,st_size);F(stat64,st_blksize);F(stat64,st_blocks);F(stat64,st_atim);F(stat64,st_mtim);F(stat64,st_ctim);F(stat64,__glibc_reserved4);F(stat64,__glibc_reserved5);
printf("epoll=%zu,%zu,data=%zu actions=%zu attr=%zu\n",sizeof(struct epoll_event),_Alignof(struct epoll_event),offsetof(struct epoll_event,data),sizeof(posix_spawn_file_actions_t),sizeof(posix_spawnattr_t));
struct stat64 b;int r=stat64("/dev/null",&b);printf("stat64_call=%d mode=%o size=%lld nlink=%lu\n",r,b.st_mode,(long long)b.st_size,(unsigned long)b.st_nlink);return r!=0;
}
