#include "../factor.h"
#include "mach_signal.h"

void signal_handler(int signal, siginfo_t* siginfo, void* uap)
{
	if(nursery.here > nursery.limit)
	{
		fprintf(stderr,"Out of memory!\n");
		factorbug();
	}
	else
		signal_error(signal);
}

void init_signals(void)
{
	struct sigaction custom_sigaction;
	struct sigaction ign_sigaction;
	
	sigemptyset(&custom_sigaction.sa_mask);
	custom_sigaction.sa_sigaction = signal_handler;
	custom_sigaction.sa_flags = SA_SIGINFO;
	sigaction(SIGABRT,&custom_sigaction,NULL);
	sigaction(SIGFPE,&custom_sigaction,NULL);
	sigaction(SIGBUS,&custom_sigaction,NULL);
	sigaction(SIGQUIT,&custom_sigaction,NULL);
	sigaction(SIGSEGV,&custom_sigaction,NULL);
	
	sigemptyset(&ign_sigaction.sa_mask);
	ign_sigaction.sa_handler = SIG_IGN;
	sigaction(SIGPIPE,&ign_sigaction,NULL);

#ifdef __APPLE__
	mach_initialize();
#endif
}
