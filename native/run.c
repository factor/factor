#include "factor.h"

void signal_handler(int signal, siginfo_t* siginfo, void* uap)
{
	general_error(ERROR_SIGNAL,tag_fixnum(signal));
}

void init_signals(void)
{
	struct sigaction custom_sigaction;
	struct sigaction ign_sigaction;
	custom_sigaction.sa_sigaction = signal_handler;
	custom_sigaction.sa_flags = SA_SIGINFO;
	ign_sigaction.sa_handler = SIG_IGN;
	ign_sigaction.sa_flags = 0;
	sigaction(SIGABRT,&custom_sigaction,NULL);
	sigaction(SIGFPE,&custom_sigaction,NULL);
	sigaction(SIGBUS,&custom_sigaction,NULL);
	sigaction(SIGSEGV,&custom_sigaction,NULL);
	sigaction(SIGPIPE,&custom_sigaction,NULL);
}

void clear_environment(void)
{
	int i;
	for(i = 0; i < USER_ENV; i++)
		userenv[i] = 0;
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
void call()
{
	/* tail call optimization */
	if(callframe != F)
		cpush(callframe);
	/* the parameter is the colon def */
	callframe = executing->parameter;
}


void primitive_execute(void)
{
	WORD* word = untag_word(dpop());
	executing = word;
	EXECUTE(executing);
}

void primitive_call(void)
{
	CELL calling = dpop();
	if(callframe != F)
		cpush(callframe);
	callframe = calling;
}

void primitive_ifte(void)
{
	CELL f = dpop();
	CELL t = dpop();
	CELL cond = dpop();
	CELL calling = (untag_boolean(cond) ? t : f);
	if(callframe != F)
		cpush(callframe);
	callframe = calling;
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
