#include "factor.h"

void clear_environment(void)
{
	int i;
	for(i = 0; i < USER_ENV; i++)
		env.user[i] = 0;
}

void init_environment(void)
{
	env.ds_bot = tag_object(array(STACK_SIZE,empty));
	reset_datastack();
	env.cs_bot = tag_object(array(STACK_SIZE,empty));
	reset_callstack();
	env.cf = env.boot;
}

#define EXECUTE(w) ((XT)(w->xt))()

void run(void)
{
	CELL next;

	/* Error handling. */
	setjmp(toplevel);
	
	for(;;)
	{
		check_stacks();
		
		if(env.cf == F)
		{
			if(cpeek() == empty)
				break;

			env.cf = cpop();
			continue;
		}

		env.cf = (CELL)untag_cons(env.cf);
		next = get(env.cf);
		env.cf = get(env.cf + CELLS);

		if(TAG(next) == WORD_TYPE)
		{
			env.w = (WORD*)UNTAG(next);
			/* printf("EXECUTE %d\n",env.w->primitive); */
			EXECUTE(env.w);
		}
		else
		{
			/* printf("DPUSH %d\n",type_of(next)); */
			dpush(env.dt);
			env.dt = next;
		}
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
	WORD* word = untag_word(env.dt);
	env.dt = dpop();
	env.w = word;
	EXECUTE(env.w);
}

void primitive_call(void)
{
	CELL calling = env.dt;
	env.dt = dpop();
	if(env.cf != F)
		cpush(env.cf);
	env.cf = calling;
}

void primitive_ifte(void)
{
	CELL f = env.dt;
	CELL t = dpop();
	CELL cond = dpop();
	CELL calling = (untag_boolean(cond) ? t : f);
	env.dt = dpop();
	if(env.cf != F)
		cpush(env.cf);
	env.cf = calling;
}

void primitive_getenv(void)
{
	FIXNUM e = to_fixnum(env.dt);
	if(e < 0 || e >= USER_ENV)
		range_error(F,e,USER_ENV);
	env.dt = env.user[e];
}

void primitive_setenv(void)
{
	FIXNUM e = to_fixnum(env.dt);
	CELL value = dpop();
	if(e < 0 || e >= USER_ENV)
		range_error(F,e,USER_ENV);
	check_non_empty(value);
	env.user[e] = value;
	env.dt = dpop();
}

void primitive_exit(void)
{
	exit(to_fixnum(env.dt));
}

void primitive_os_env(void)
{
	char* name = to_c_string(untag_string(env.dt));
	char* value = getenv(name);
	if(value == NULL)
		env.dt = F;
	else
		env.dt = tag_object(from_c_string(getenv(name)));
}
