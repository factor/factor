/* Probe the literal legacy-time stat64/socket APIs that Factor binds.
   Current Debian GCC defaults to time64 redirects; disable those explicitly. */
#ifdef _TIME_BITS
#undef _TIME_BITS
#endif
#define _TIME_BITS 32
#ifdef _FILE_OFFSET_BITS
#undef _FILE_OFFSET_BITS
#endif
#define _FILE_OFFSET_BITS 64
#define _GNU_SOURCE
#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <unistd.h>
#define FIELD(f) printf("stat64.%s offset=%zu size=%zu\n",#f,offsetof(struct stat64,f),sizeof(((struct stat64*)0)->f))
#define CONSTANT(c) printf("%s=%d hex=%x\n",#c,c,c)
int main(void) {
 printf("pointer=%zu long=%zu timespec=%zu stat64=%zu align=%zu\n",sizeof(void*),sizeof(long),sizeof(struct timespec),sizeof(struct stat64),_Alignof(struct stat64));
 FIELD(st_dev);FIELD(__pad1);FIELD(__st_ino);FIELD(st_mode);FIELD(st_nlink);FIELD(st_uid);FIELD(st_gid);FIELD(st_rdev);FIELD(__pad2);FIELD(st_size);FIELD(st_blksize);FIELD(st_blocks);FIELD(st_atim);FIELD(st_mtim);FIELD(st_ctim);FIELD(st_ino);
 CONSTANT(O_CREAT);CONSTANT(O_EXCL);CONSTANT(O_NOCTTY);CONSTANT(O_TRUNC);CONSTANT(O_APPEND);CONSTANT(O_NONBLOCK);CONSTANT(SOL_SOCKET);CONSTANT(SO_DEBUG);CONSTANT(SO_REUSEADDR);CONSTANT(SO_TYPE);CONSTANT(SO_ERROR);CONSTANT(SO_DONTROUTE);CONSTANT(SO_BROADCAST);CONSTANT(SO_SNDBUF);CONSTANT(SO_RCVBUF);CONSTANT(SO_KEEPALIVE);CONSTANT(SO_OOBINLINE);CONSTANT(SO_SNDTIMEO);CONSTANT(SO_RCVTIMEO);CONSTANT(SOCK_STREAM);CONSTANT(SOCK_DGRAM);
 char dir[]="/tmp/factor-hppa-io-XXXXXX",file[128],link[128];assert(mkdtemp(dir));snprintf(file,sizeof(file),"%s/file",dir);snprintf(link,sizeof(link),"%s/link",dir);
 int fd=open(file,O_CREAT|O_EXCL|O_RDWR,0600);assert(fd>=0);assert(write(fd,"hppa!",5)==5);assert(symlink("file",link)==0);
 struct stat64 a,b,c;int(*sp)(const char*,struct stat64*)=dlsym(RTLD_DEFAULT,"stat64");int(*lp)(const char*,struct stat64*)=dlsym(RTLD_DEFAULT,"lstat64");int(*fp)(int,struct stat64*)=dlsym(RTLD_DEFAULT,"fstat64");assert(sp&&lp&&fp);assert(sp(file,&a)==0&&fp(fd,&b)==0&&lp(link,&c)==0);assert(a.st_size==5&&a.st_ino==b.st_ino&&S_ISREG(a.st_mode)&&S_ISLNK(c.st_mode));
 assert(fcntl(fd,F_SETFL,fcntl(fd,F_GETFL)|O_NONBLOCK)==0);assert(fcntl(fd,F_GETFL)&O_NONBLOCK);
 int sock=socket(AF_INET,SOCK_STREAM,0),one=1,type=0;assert(sock>=0);socklen_t len=sizeof(type);assert(setsockopt(sock,SOL_SOCKET,SO_REUSEADDR,&one,sizeof(one))==0);assert(getsockopt(sock,SOL_SOCKET,SO_TYPE,&type,&len)==0&&type==SOCK_STREAM);struct timeval timeout={1,123000},got;len=sizeof(got);assert(setsockopt(sock,SOL_SOCKET,SO_SNDTIMEO,&timeout,sizeof(timeout))==0);assert(getsockopt(sock,SOL_SOCKET,SO_SNDTIMEO,&got,&len)==0&&got.tv_sec==1);close(sock);close(fd);unlink(link);unlink(file);rmdir(dir);
 puts("native stat64/lstat64/fstat64 plabel + open/nonblock/socket timeout controls PASS");return 0;
}
