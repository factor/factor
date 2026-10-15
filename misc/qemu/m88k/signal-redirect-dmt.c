#include <sys/types.h>
#include <sys/wait.h>
#include <machine/reg.h>
#include <signal.h>
#include <stdio.h>
#include <unistd.h>
extern int redirect_fault(void);
extern char redirect_resume[];
static volatile sig_atomic_t clear_pending, hits, pending;
static void caught(int sig, siginfo_t *si, void *context) {
  struct sigcontext *sc = context;
  struct reg *regs = (struct reg *)&sc->sc_regs;
  if (sig != SIGSEGV || si->si_addr != (void *)36) _exit(90);
  pending = regs->dmt0;
  if (++hits > 3) _exit(77);
  regs->snip = (unsigned long)redirect_resume | 2;
  regs->sfip = ((unsigned long)redirect_resume + 4) | 2;
  if (clear_pending) regs->dmt0 = 0;
}
static int run(int clear) {
  pid_t p=fork(); int status;
  if (p < 0) return 1;
  if (!p) {
    struct sigaction action={0};
    clear_pending=clear; hits=0;
    action.sa_sigaction=caught; action.sa_flags=SA_SIGINFO;
    sigemptyset(&action.sa_mask);
    if(sigaction(SIGSEGV,&action,0)) _exit(91);
    alarm(3);
     { int value=redirect_fault();
      fprintf(stderr,"child clear=%d value=%d hits=%d pending=%x\n",clear,value,hits,pending);
      if(!clear && (value!=42 || hits!=1)) _exit(77);
      if(value!=42 || hits!=1) _exit(92);
    }
    _exit(0);
  }
  if(waitpid(p,&status,0)!=p || !WIFEXITED(status)) return 2;
  printf("redirect clear=%d exit=%d\n",clear,WEXITSTATUS(status));
  return WEXITSTATUS(status)==(clear?0:77)?0:3;
}
int main(void) {int a=run(0),b=run(1);printf("signal redirection pending DMT: failures=%d\n",a+b);return a+b;}
