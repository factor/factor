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

/* Called from a signal handler. XXX - is this safe? */
void call_profiling_step(int signal, siginfo_t* siginfo, void* uap)
{
	CELL depth = (cs - cs_bot) / CELLS;
	int i;
	CELL obj;
	for(i = profile_depth; i < depth; i++)
	{
		obj = get(cs_bot + i * CELLS);
		if(type_of(obj) == WORD_TYPE)
			untag_word(obj)->call_count++;
	}

	untag_word_fast(executing)->call_count++;
}

void init_signals(void)
{
	struct sigaction custom_sigaction;
	struct sigaction profiling_sigaction;
	struct sigaction ign_sigaction;
	struct sigaction dump_sigaction;
	sigemptyset(&custom_sigaction.sa_mask);
	custom_sigaction.sa_sigaction = signal_handler;
	custom_sigaction.sa_flags = SA_SIGINFO;
	sigemptyset(&profiling_sigaction.sa_mask);
	profiling_sigaction.sa_sigaction = call_profiling_step;
	profiling_sigaction.sa_flags = SA_SIGINFO;
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
	sigaction(SIGPROF,&profiling_sigaction,NULL);
	sigaction(SIGQUIT,&dump_sigaction,NULL);
}

void primitive_call_profiling(F_WORD *word)
{
	CELL d = dpop();
	if(d == F)
	{
		timerclear(&prof_timer.it_interval);
		timerclear(&prof_timer.it_value);

		profile_depth = 0;
	}
	else
	{
		prof_timer.it_interval.tv_sec = 0;
		prof_timer.it_interval.tv_usec = 1000;
		prof_timer.it_value.tv_sec = 0;
		prof_timer.it_value.tv_usec = 1000;

		profile_depth = to_fixnum(d);
	}

	if(setitimer(ITIMER_PROF,&prof_timer,NULL) < 0)
		io_error();
}
