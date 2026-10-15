#include <sys/epoll.h>
#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include <unistd.h>
int main(void) {
 int fd=epoll_create1(EPOLL_CLOEXEC); if(fd<0){perror("native EPOLL_CLOEXEC");return 1;}
 int flags=fcntl(fd,F_GETFD);printf("EPOLL_CLOEXEC=%#x O_CLOEXEC=%#x fdflags=%#x\n",EPOLL_CLOEXEC,O_CLOEXEC,flags);
 if(!(flags&FD_CLOEXEC))return 2;close(fd);
 errno=0;fd=epoll_create1(02000000);int e=errno;printf("generic flag negative fd=%d errno=%d\n",fd,e);if(fd>=0){close(fd);return 3;}if(e!=EINVAL)return 4;
 puts("HPPA native epoll_create1/CLOEXEC and generic-flag negative passed");return 0;
}
