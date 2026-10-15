#define _GNU_SOURCE
#include <stdio.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <errno.h>
#include <signal.h>
#include <termios.h>
#include <stddef.h>
#define P(x) printf(#x "=%ld\n",(long)(x))
int main(void) {
P(sizeof(void*)); P(O_CREAT);P(O_EXCL);P(O_TRUNC);P(O_APPEND);P(O_NONBLOCK);P(O_NDELAY);P(O_NOCTTY);
P(SOL_SOCKET);P(SO_REUSEADDR);P(SO_TYPE);P(SO_ERROR);P(SO_SNDTIMEO);P(SO_RCVTIMEO);P(TIOCGWINSZ);
P(EAGAIN);P(EINPROGRESS);P(ENOSYS);P(EOVERFLOW);P(SIGBUS);P(SIGUSR1);P(SIGUSR2);P(SIG_BLOCK);P(SIG_SETMASK);
P(NCCS);P(sizeof(struct termios));P(offsetof(struct termios,c_cc));P(offsetof(struct termios,c_ispeed));P(VMIN);P(VTIME);
sigset_t one, empty, previous, current;
sigemptyset(&one); sigaddset(&one,SIGUSR1); sigemptyset(&empty);
if(sigprocmask(SIG_BLOCK,&one,&previous))return 20;
if(sigprocmask(2,&empty,0))return 21;
if(sigprocmask(SIG_BLOCK,0,&current) || sigismember(&current,SIGUSR1)!=1)return 22;
if(sigprocmask(SIG_SETMASK,&empty,0))return 23;
if(sigprocmask(SIG_BLOCK,0,&current) || sigismember(&current,SIGUSR1)!=0)return 24;
if(sigprocmask(SIG_SETMASK,&previous,0))return 25;
puts("OLD-MASK-NEGATIVE NEW-MASK-PASS");
char path[128];snprintf(path,sizeof(path),"/tmp/factor-sparc-io-%ld",(long)getpid());unlink(path);
int bad=open(path,0x40|O_WRONLY,0600);int e=errno;if(bad>=0){close(bad);unlink(path);return 10;}if(e!=ENOENT)return 11;
int fd=open(path,O_CREAT|O_EXCL|O_RDWR,0600);if(fd<0)return 12;if(write(fd,"abc",3)!=3)return 13;close(fd);unlink(path);
int s=socket(AF_INET,SOCK_STREAM,0),v=1;if(s<0)return 14;if(setsockopt(s,SOL_SOCKET,SO_REUSEADDR,&v,sizeof v))return 15;
if(!setsockopt(s,1,2,&v,sizeof v))return 16;close(s);puts("OLD-NEGATIVE NEW-FILE-SOCKET-PASS");return 0;
}
