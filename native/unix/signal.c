#include "../factor.h"
#include "mach_signal.h"

void signal_handler(int signal, siginfo_t* siginfo, void* uap)
{
	if(nursery.here > nursery.limit)
	{
		fprintf(stderr,"Nursery space exhausted\n");
		factorbug();
	}
	else if(compiling.here + sizeof(CELL) > compiling.limit)
	{
		fprintf(stderr,"Code space exhausted\n");
		factorbug();
	}
	else
		signal_error(signal);
}

static void sigaction_safe(int signum, const struct sigaction *act, struct sigaction *oldact)
{
	int ret;
	do
	{
		ret = sigaction(signum, act, oldact);
	} while(ret == -1 && errno == EINTR);
}

void init_signals(void)
{
	struct sigaction custom_sigaction;
	struct sigaction ign_sigaction;
	
	sigemptyset(&custom_sigaction.sa_mask);
	custom_sigaction.sa_sigaction = signal_handler;
	custom_sigaction.sa_flags = SA_SIGINFO;
	sigaction_safe(SIGABRT,&custom_sigaction,NULL);
	sigaction_safe(SIGFPE,&custom_sigaction,NULL);
	sigaction_safe(SIGBUS,&custom_sigaction,NULL);
	sigaction_safe(SIGQUIT,&custom_sigaction,NULL);
	sigaction_safe(SIGSEGV,&custom_sigaction,NULL);
	
	sigemptyset(&ign_sigaction.sa_mask);
	ign_sigaction.sa_handler = SIG_IGN;
	sigaction_safe(SIGPIPE,&ign_sigaction,NULL);

#ifdef __APPLE__
	mach_initialize();
#endif
}
