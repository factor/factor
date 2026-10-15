#define _GNU_SOURCE
#define _LARGEFILE64_SOURCE
#include <stdio.h>
#include <stddef.h>
#include <sys/stat.h>
#include <sys/statfs.h>
#include <sys/statvfs.h>
#include <sys/epoll.h>
#include <sys/socket.h>
#include <fcntl.h>
#include <signal.h>
#include <spawn.h>
#include <netdb.h>
#include <utmpx.h>
#include <dirent.h>
#define SZ(t) printf("sizeof %s %zu align %zu\n",#t,sizeof(t),_Alignof(t))
#define OF(t,f) printf("offset %s.%s %zu width %zu\n",#t,#f,offsetof(t,f),sizeof(((t*)0)->f))
#define CO(x) printf("constant %s %ld\n",#x,(long)x)
int main(void) {
 SZ(struct stat64); SZ(struct statfs64); SZ(struct statvfs64);SZ(struct epoll_event);SZ(sigset_t);SZ(posix_spawnattr_t);SZ(struct dirent64);SZ(struct utmpx);
 OF(struct stat64,st_dev);OF(struct stat64,st_ino);OF(struct stat64,st_mode);OF(struct stat64,st_nlink);OF(struct stat64,st_uid);OF(struct stat64,st_gid);OF(struct stat64,st_rdev);OF(struct stat64,st_size);OF(struct stat64,st_atim);OF(struct stat64,st_mtim);OF(struct stat64,st_ctim);OF(struct stat64,st_blksize);OF(struct stat64,st_blocks);
 OF(struct statfs64,f_type);OF(struct statfs64,f_blocks);OF(struct statfs64,f_fsid);OF(struct statfs64,f_namelen);OF(struct statfs64,f_frsize);OF(struct statfs64,f_flags);OF(struct statfs64,f_spare);
 OF(struct statvfs64,f_fsid);OF(struct statvfs64,f_flag);OF(struct statvfs64,f_namemax);OF(struct epoll_event,data);OF(posix_spawnattr_t,__sd);OF(posix_spawnattr_t,__sp);OF(struct dirent64,d_name);OF(struct utmpx,ut_session);OF(struct utmpx,ut_tv);OF(struct addrinfo,ai_addr);OF(struct addrinfo,ai_canonname);
 SZ(dev_t);SZ(ino_t);SZ(nlink_t);SZ(blksize_t);SZ(blkcnt_t);SZ(time_t);
 CO(O_CREAT);CO(O_EXCL);CO(O_NOCTTY);CO(O_TRUNC);CO(O_APPEND);CO(O_NONBLOCK);CO(O_CLOEXEC);CO(SOL_SOCKET);CO(SOCK_STREAM);CO(SOCK_DGRAM);CO(SOCK_RAW);CO(SO_DEBUG);CO(SO_REUSEADDR);CO(SO_TYPE);CO(SO_ERROR);CO(SO_DONTROUTE);CO(SO_BROADCAST);CO(SO_SNDBUF);CO(SO_RCVBUF);CO(SO_KEEPALIVE);CO(SO_OOBINLINE);CO(SO_SNDTIMEO);CO(SO_RCVTIMEO);CO(EPOLL_CLOEXEC);
 struct stat64 st; if(stat64("/",&st))return 1;printf("stat64 root mode %o size %lld\n",st.st_mode,(long long)st.st_size);return 0;
}
