#include "factor.h"

INLINE void execute(F_WORD* word)
{
	((XT)(word->xt))(word);
}

INLINE void push_callframe(void)
{
	cs += CELLS * 3;
	put(cs - CELLS * 2,callframe);
	put(cs - CELLS,callframe_scan);
	put(cs,callframe_end);
}

INLINE void set_callframe(CELL quot)
{
	F_ARRAY *untagged = (F_ARRAY*)UNTAG(quot);
	type_check(QUOTATION_TYPE,quot);
	callframe = quot;
	callframe_scan = AREF(untagged,0);
	callframe_end = AREF(untagged,array_capacity(untagged));
}

void call(CELL quot)
{
	if(quot == F)
		return;

	/* tail call optimization */
	if(callframe_scan < callframe_end)
		push_callframe();

	set_callframe(quot);
}

/* Called from platform_run() */
void handle_error(void)
{
	if(throwing)
	{
		if(thrown_keep_stacks)
		{
			ds = thrown_ds;
			rs = thrown_rs;
		}
		else
			fix_stacks();

		dpush(thrown_error);
		/* Notify any 'catch' blocks */
		push_callframe();
		set_callframe(userenv[BREAK_ENV]);
		throwing = false;
	}
}

void run(void)
{
	CELL next;

	for(;;)
	{
		if(callframe_scan == callframe_end)
		{
			if(cs_bot - cs == CELLS)
				return;

			callframe_end = get(cs);
			callframe_scan = get(cs - CELLS);
			callframe = get(cs - CELLS * 2);
			cs -= CELLS * 3;
			continue;
		}

		next = get(callframe_scan);
		callframe_scan += CELLS;

		switch(TAG(next))
		{
		case WORD_TYPE:
			execute(untag_word_fast(next));
			break;
		case WRAPPER_TYPE:
			dpush(untag_wrapper_fast(next)->object);
			break;
		default:
			dpush(next);
			break;
		}
	}
}

void run_toplevel(void)
{
	SETJMP(stack_chain->toplevel);
	handle_error();
	run();
}

/* Called by compiled callbacks after nest_stacks() and boxing registers */
void run_callback(CELL quot)
{
	call(quot);
	platform_run();
}

/* XT of deferred words */
void undefined(F_WORD* word)
{
	general_error(ERROR_UNDEFINED_WORD,tag_word(word),F,true);
}

/* XT of compound definitions */
void docol(F_WORD* word)
{
	call(word->def);
}

/* pushes word parameter */
void dosym(F_WORD* word)
{
	dpush(word->def);
}

void primitive_execute(void)
{
	execute(untag_word(dpop()));
}

void primitive_call(void)
{
	call(dpop());
}

void primitive_ifte(void)
{
	ds -= CELLS * 3;
	call(get(ds + CELLS) == F ? get(ds + CELLS * 3) : get(ds + CELLS * 2));
}

void primitive_dispatch(void)
{
	F_ARRAY *a = untag_array_fast(dpop());
	F_FIXNUM n = untag_fixnum_fast(dpop());
	call(get(AREF(a,n)));
}

void primitive_getenv(void)
{
	F_FIXNUM e = untag_fixnum_fast(dpeek());
	drepl(userenv[e]);
}

void primitive_setenv(void)
{
	F_FIXNUM e = untag_fixnum_fast(dpop());
	CELL value = dpop();
	userenv[e] = value;
}

void primitive_exit(void)
{
	exit(to_fixnum(dpop()));
}

void primitive_os_env(void)
{
	char *name, *value;

	maybe_gc(0);

	name = unbox_char_string();
	value = getenv(name);
	if(value == NULL)
		dpush(F);
	else
		box_char_string(getenv(name));
}

void primitive_eq(void)
{
	CELL lhs = dpop();
	CELL rhs = dpeek();
	drepl((lhs == rhs) ? T : F);
}

void primitive_millis(void)
{
	maybe_gc(0);
	dpush(tag_bignum(s48_long_long_to_bignum(current_millis())));
}

void fatal_error(char* msg, CELL tagged)
{
	fprintf(stderr,"Fatal error: %s %ld\n",msg,tagged);
	exit(1);
}

void critical_error(char* msg, CELL tagged)
{
	fprintf(stderr,"Critical error: %s %ld\n",msg,tagged);
	factorbug();
}

void early_error(CELL error)
{
	if(userenv[BREAK_ENV] == F)
	{
		/* Crash at startup */
		fprintf(stderr,"Error during startup: ");
		print_obj(error);
		fprintf(stderr,"\n");
		factorbug();
	}
}

void throw_error(CELL error, bool keep_stacks)
{
	early_error(error);

	throwing = true;
	thrown_error = error;
	thrown_keep_stacks = keep_stacks;
	thrown_ds = ds;
	thrown_rs = rs;

	/* Return to run() method */
	LONGJMP(stack_chain->toplevel,1);
}

void primitive_throw(void)
{
	throw_error(dpop(),true);
}

void primitive_die(void)
{
	factorbug();
}

void general_error(F_ERRORTYPE error, CELL arg1, CELL arg2, bool keep_stacks)
{
	throw_error(make_array_4(userenv[ERROR_ENV],
		tag_fixnum(error),arg1,arg2),keep_stacks);
}

void memory_protection_error(void *addr, int signal)
{
	if(in_page(addr, (void *) ds_bot, 0, -1))
		general_error(ERROR_DS_UNDERFLOW,F,F,false);
	else if(in_page(addr, (void *) ds_bot, ds_size, 0))
		general_error(ERROR_DS_OVERFLOW,F,F,false);
	else if(in_page(addr, (void *) rs_bot, 0, -1))
		general_error(ERROR_RS_UNDERFLOW,F,F,false);
	else if(in_page(addr, (void *) rs_bot, rs_size, 0))
		general_error(ERROR_RS_OVERFLOW,F,F,false);
	else if(in_page(addr, (void *) cs_bot, 0, -1))
		general_error(ERROR_CS_UNDERFLOW,F,F,false);
	else if(in_page(addr, (void *) cs_bot, cs_size, 0))
		general_error(ERROR_CS_OVERFLOW,F,F,false);
	else
		signal_error(signal);
}

/* It is not safe to access 'ds' from a signal handler, so we just not
touch it */
void signal_error(int signal)
{
	general_error(ERROR_SIGNAL,tag_fixnum(signal),F,false);
}

void type_error(CELL type, CELL tagged)
{
	general_error(ERROR_TYPE,tag_fixnum(type),tagged,true);
}

void init_compiler(CELL size)
{
	compiling.base = compiling.here
		= (CELL)(alloc_bounded_block(size)->start);
	if(compiling.base == 0)
		fatal_error("Cannot allocate code heap",size);
	compiling.limit = compiling.base + size;
	last_flush = compiling.base;
}

void collect_literals(void)
{
	/* CELL i;
	for(i = compiling.base; i < literal_top; i += CELLS)
		copy_handle((CELL*)i); */
}

void deposit_vector(F_VECTOR *vector, CELL format)
{
	CELL count = untag_fixnum_fast(vector->top);
	F_ARRAY *array = untag_array_fast(vector->array);
	CELL i;

	if(format == 1)
	{
		for(i = 0; i < count; i++)
			cput(compiling.here + i,to_fixnum(get(AREF(array,i))));
	}
	else if(format == CELLS)
	{
		CELL dest = compiling.here;

		for(i = 0; i < count; i++)
		{
			put(dest,to_fixnum(get(AREF(array,i))));
			dest += CELLS;
		}
	}
	else
		fatal_error("Bad format param to deposit_vector()",format);
	
	compiling.here += count * format;
}

void add_compiled_block(F_VECTOR *code, CELL code_format,
	F_VECTOR *reloc, F_VECTOR *literals)
{
	CELL start = compiling.here;
	CELL code_length = untag_fixnum_fast(code->top) * code_format;
	CELL reloc_length = untag_fixnum_fast(reloc->top) * CELLS;
	CELL literal_length = untag_fixnum_fast(literals->top) * CELLS;

	/* compiled header */
	F_COMPILED header;
	header.header = COMPILED_HEADER;
	header.code_length = align8(code_length);
	header.reloc_length = reloc_length;
	header.literal_length = literal_length;
	memcpy((void*)compiling.here,&header,sizeof(F_COMPILED));
	compiling.here += sizeof(F_COMPILED);
	
	/* code */
	deposit_vector(code,code_format);
	compiling.here = align8(compiling.here);

	/* relocation info */
	deposit_vector(reloc,CELLS);

	/* literals */
	deposit_vector(literals,CELLS);

	/* push the XT of the new word on the stack */
	box_unsigned_cell(start + sizeof(F_COMPILED));
}

void primitive_add_compiled_block(void)
{
	F_VECTOR *literals = untag_vector(dpop());
	F_VECTOR *rel = untag_vector(dpop());
	CELL code_format = to_cell(dpop());
	F_VECTOR *code = untag_vector(dpop());
	
	add_compiled_block(code,code_format,rel,literals);
}

void primitive_finalize_compile(void)
{
	flush_icache((void*)last_flush,compiling.here - last_flush);

	while(last_flush < compiling.here)
		last_flush = relocate_code_next(last_flush);

	last_flush = compiling.here;
}
