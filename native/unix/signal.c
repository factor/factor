#include "../factor.h"

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

void dump_stack_signal(int signal, siginfo_t* siginfo, void* uap)
{
	factorbug();
}

void init_signals(void)
{
	struct sigaction custom_sigaction;
	struct sigaction ign_sigaction;
	struct sigaction dump_sigaction;
	sigemptyset(&custom_sigaction.sa_mask);
	custom_sigaction.sa_sigaction = signal_handler;
	custom_sigaction.sa_flags = SA_SIGINFO;
	sigemptyset(&dump_sigaction.sa_mask);
	dump_sigaction.sa_sigaction = dump_stack_signal;
	dump_sigaction.sa_flags = SA_SIGINFO;
	sigemptyset(&ign_sigaction.sa_mask);
	ign_sigaction.sa_handler = SIG_IGN;
	sigaction(SIGABRT,&custom_sigaction,NULL);
	sigaction(SIGFPE,&custom_sigaction,NULL);
	sigaction(SIGBUS,&custom_sigaction,NULL);
	sigaction(SIGILL,&custom_sigaction,NULL);
	sigaction(SIGSEGV,&custom_sigaction,NULL);
	sigaction(SIGPIPE,&ign_sigaction,NULL);
	sigaction(SIGQUIT,&dump_sigaction,NULL);
}
