#include "factor.h"

void signal_handler(int signal, siginfo_t* siginfo, void* uap)
{
	general_error(ERROR_SIGNAL,tag_fixnum(signal));
}

void memory_signal_handler(int signal, siginfo_t* siginfo, void* uap)
{
	if(STACK_UNDERFLOW(ds,ds_bot))
	{
		reset_datastack();
		general_error(ERROR_DATASTACK_UNDERFLOW,F);
	}
	else if(STACK_OVERFLOW(ds,ds_bot))
	{
		reset_datastack();
		general_error(ERROR_DATASTACK_OVERFLOW,F);
	}
	else if(STACK_UNDERFLOW(cs,cs_bot))
	{
		reset_callstack();
		general_error(ERROR_CALLSTACK_UNDERFLOW,F);
	}
	else if(STACK_OVERFLOW(cs,cs_bot))
	{
		reset_callstack();
		general_error(ERROR_CALLSTACK_OVERFLOW,F);
	}
	else if(active.here > active.limit)
	{
		fprintf(stderr,"Out of memory\n");
		fprintf(stderr,"active.base  = %ld\n",active.base);
		fprintf(stderr,"active.here  = %ld\n",active.here);
		fprintf(stderr,"active.limit = %ld\n",active.limit);
		fflush(stderr);
		exit(1);
	}
	else
		general_error(ERROR_SIGNAL,tag_fixnum(signal));
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
		if(TAG(obj) == WORD_TYPE)
			untag_word(obj)->call_count++;
	}

	executing->call_count++;
}

void init_signals(void)
{
	struct sigaction custom_sigaction;
	struct sigaction profiling_sigaction;
	struct sigaction memory_sigaction;
	struct sigaction ign_sigaction;
	custom_sigaction.sa_sigaction = signal_handler;
	custom_sigaction.sa_flags = SA_SIGINFO;
	profiling_sigaction.sa_sigaction = call_profiling_step;
	profiling_sigaction.sa_flags = SA_SIGINFO;
	memory_sigaction.sa_sigaction = memory_signal_handler;
	memory_sigaction.sa_flags = SA_SIGINFO;
	ign_sigaction.sa_handler = SIG_IGN;
	sigaction(SIGABRT,&custom_sigaction,NULL);
	sigaction(SIGFPE,&custom_sigaction,NULL);
	sigaction(SIGBUS,&memory_sigaction,NULL);
	sigaction(SIGSEGV,&memory_sigaction,NULL);
	sigaction(SIGPIPE,&ign_sigaction,NULL);
	sigaction(SIGPROF,&profiling_sigaction,NULL);
}

void primitive_call_profiling(void)
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
		io_error(__FUNCTION__);
}
