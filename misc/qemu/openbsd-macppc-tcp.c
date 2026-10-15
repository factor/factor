#include <sys/socket.h>
#include <sys/wait.h>
#include <netinet/in.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
int main(void) {
 int s=socket(AF_INET,SOCK_STREAM,0), status;
 struct sockaddr_in a={0}; socklen_t n=sizeof a;
 a.sin_len=sizeof a;a.sin_family=AF_INET;a.sin_addr.s_addr=htonl(INADDR_LOOPBACK);
 if(s<0||bind(s,(void*)&a,sizeof a)||getsockname(s,(void*)&a,&n)||listen(s,1))return 1;
 pid_t p=fork();if(p<0)return 2;
 if(!p){int c=socket(AF_INET,SOCK_STREAM,0);char b[4]={0};close(s);if(c<0||connect(c,(void*)&a,sizeof a)||write(c,"PPC",3)!=3||read(c,b,3)!=3||memcmp(b,"BSD",3))_exit(3);close(c);_exit(0);}
 int c=accept(s,0,0);char b[4]={0};if(c<0||read(c,b,3)!=3||memcmp(b,"PPC",3)||write(c,"BSD",3)!=3)return 4;
 close(c);close(s);if(waitpid(p,&status,0)!=p||!WIFEXITED(status)||WEXITSTATUS(status))return 5;
 printf("TCP_LOOPBACK_PASS port=%u parent=%ld child=%ld\n",ntohs(a.sin_port),(long)getpid(),(long)p);return 0;
}
