#include <assert.h>
#include <sys/wait.h>
#include <unistd.h>
#include <signal.h>
#include <stdio.h>
void m88k_runtime_trap(void);
int main(void) { int s; pid_t p=fork(); assert(p>=0); if(!p){m88k_runtime_trap();_exit(1);} assert(waitpid(p,&s,0)==p); assert(WIFSIGNALED(s)&&WTERMSIG(s)==SIGABRT); puts("m88k runtime fatal trap PASS: child SIGABRT"); return 0; }
