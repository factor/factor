#include "factor.h"

void signal_handler(int signal, siginfo_t* siginfo, void* uap)
{
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
	struct sigaction ign_sigaction;
	custom_sigaction.sa_sigaction = signal_handler;
	custom_sigaction.sa_flags = SA_SIGINFO;
	profiling_sigaction.sa_sigaction = call_profiling_step;
	profiling_sigaction.sa_flags = SA_SIGINFO;
	ign_sigaction.sa_handler = SIG_IGN;
	sigaction(SIGABRT,&custom_sigaction,NULL);
	sigaction(SIGFPE,&custom_sigaction,NULL);
	sigaction(SIGBUS,&custom_sigaction,NULL);
	sigaction(SIGSEGV,&custom_sigaction,NULL);
	sigaction(SIGPIPE,&ign_sigaction,NULL);
	sigaction(SIGPROF,&profiling_sigaction,NULL);
}

void clear_environment(void)
{
	int i;
	for(i = 0; i < USER_ENV; i++)
		userenv[i] = 0;
	profile_depth = 0;
}

#define EXECUTE(w) ((XT)(w->xt))()

void run(void)
{
	CELL next;

	/* Error handling. */
	sigsetjmp(toplevel, 1);
	
	for(;;)
	{
		if(callframe == F)
		{
			callframe = cpop();
#ifdef FACTOR_PROFILER
			cpop();
#endif
			continue;
		}

		callframe = (CELL)untag_cons(callframe);
		next = get(callframe);
		callframe = get(callframe + CELLS);

		if(TAG(next) == WORD_TYPE)
		{
			executing = (WORD*)UNTAG(next);
			EXECUTE(executing);
		}
		else
			dpush(next);
	}
}

/* XT of deferred words */
void undefined()
{
	general_error(ERROR_UNDEFINED_WORD,tag_word(executing));
}

/* XT of compound definitions */
void docol(void)
{
	call(executing->parameter);
}

void primitive_execute(void)
{
	executing = untag_word(dpop());
	EXECUTE(executing);
}

void primitive_call(void)
{
	call(dpop());
}

void primitive_ifte(void)
{
	CELL f = dpop();
	CELL t = dpop();
	CELL cond = dpop();
	call(untag_boolean(cond) ? t : f);
}

void primitive_getenv(void)
{
	FIXNUM e = to_fixnum(dpeek());
	if(e < 0 || e >= USER_ENV)
		range_error(F,e,USER_ENV);
	drepl(userenv[e]);
}

void primitive_setenv(void)
{
	FIXNUM e = to_fixnum(dpop());
	CELL value = dpop();
	if(e < 0 || e >= USER_ENV)
		range_error(F,e,USER_ENV);
	userenv[e] = value;
}

void primitive_call_profiling(void)
{
#ifndef FACTOR_PROFILER
	general_error(ERROR_PROFILING_DISABLED,F);
#else
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
#endif
}
