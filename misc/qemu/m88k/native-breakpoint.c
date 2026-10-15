#include <assert.h>
#include <signal.h>
#include <stdio.h>
#include <sys/resource.h>
#include <sys/wait.h>
#include <unistd.h>
int main(void) {
  int status; pid_t child=fork(); assert(child>=0);
  if(child==0) {
    struct rlimit limit={0,0}; assert(setrlimit(RLIMIT_CORE,&limit)==0);
    raise(SIGTRAP); _exit(1);
  }
  assert(waitpid(child,&status,0)==child);
  assert(WIFSIGNALED(status) && WTERMSIG(status)==SIGTRAP);
  puts("m88k debugger breakpoint gate PASS: native SIGTRAP"); return 0;
}
