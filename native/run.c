#include "factor.h"

void signal_handler(int signal, siginfo_t* siginfo, void* uap)
{
	general_error(ERROR_SIGNAL,tag_fixnum(signal));
}

void init_signals(void)
{
	struct sigaction custom_sigaction;
	custom_sigaction.sa_sigaction = signal_handler;
	custom_sigaction.sa_flags = SA_SIGINFO;
	sigaction(SIGABRT,&custom_sigaction,NULL);
	sigaction(SIGFPE,&custom_sigaction,NULL);
	sigaction(SIGBUS,&custom_sigaction,NULL);
	sigaction(SIGSEGV,&custom_sigaction,NULL);
}

void clear_environment(void)
{
	int i;
	for(i = 0; i < USER_ENV; i++)
		env.user[i] = 0;
}

#define EXECUTE(w) ((XT)(w->xt))()

void run(void)
{
	CELL next;

	/* Error handling. */
	setjmp(toplevel);
	
	for(;;)
	{
		if(env.cf == F)
		{
			env.cf = cpop();
			continue;
		}

		env.cf = (CELL)untag_cons(env.cf);
		next = get(env.cf);
		env.cf = get(env.cf + CELLS);

		if(TAG(next) == WORD_TYPE)
		{
			env.w = (WORD*)UNTAG(next);
			EXECUTE(env.w);
		}
		else
			dpush(next);
	}
}

/* XT of deferred words */
void undefined()
{
	general_error(ERROR_UNDEFINED_WORD,tag_word(env.w));
}

/* XT of compound definitions */
void call()
{
	/* tail call optimization */
	if(env.cf != F)
		cpush(env.cf);
	/* the parameter is the colon def */
	env.cf = env.w->parameter;
}


void primitive_execute(void)
{
	WORD* word = untag_word(dpop());
	env.w = word;
	EXECUTE(env.w);
}

void primitive_call(void)
{
	CELL calling = dpop();
	if(env.cf != F)
		cpush(env.cf);
	env.cf = calling;
}

void primitive_ifte(void)
{
	CELL f = dpop();
	CELL t = dpop();
	CELL cond = dpop();
	CELL calling = (untag_boolean(cond) ? t : f);
	if(env.cf != F)
		cpush(env.cf);
	env.cf = calling;
}

void primitive_getenv(void)
{
	FIXNUM e = to_fixnum(dpeek());
	if(e < 0 || e >= USER_ENV)
		range_error(F,e,USER_ENV);
	drepl(env.user[e]);
}

void primitive_setenv(void)
{
	FIXNUM e = to_fixnum(dpop());
	CELL value = dpop();
	if(e < 0 || e >= USER_ENV)
		range_error(F,e,USER_ENV);
	env.user[e] = value;
}
