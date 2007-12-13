#include "master.h"

/* Simple JIT compiler. This is one of the two compilers implementing Factor;
the second one is written in Factor and performs a lot of optimizations.
See core/compiler/compiler.factor */
bool jit_fast_if_p(F_ARRAY *array, CELL i)
{
	return (i + 3) <= array_capacity(array)
		&& type_of(array_nth(array,i)) == QUOTATION_TYPE
		&& type_of(array_nth(array,i + 1)) == QUOTATION_TYPE
		&& array_nth(array,i + 2) == userenv[JIT_IF_WORD];
}

bool jit_fast_dispatch_p(F_ARRAY *array, CELL i)
{
	return (i + 2) == array_capacity(array)
		&& array_nth(array,i + 1) == userenv[JIT_DISPATCH_WORD];
}

#define EMIT(name) { \
		REGISTER_UNTAGGED(array); \
		GROWABLE_APPEND(result,untag_object(userenv[name])); \
		UNREGISTER_UNTAGGED(array); \
	}

bool jit_stack_frame_p(F_ARRAY *array)
{
	F_FIXNUM length = array_capacity(array);
	F_FIXNUM i;

	for(i = 0; i < length - 1; i++)
	{
		if(type_of(array_nth(array,i)) == WORD_TYPE)
			return true;
	}

	return false;
}

void set_quot_xt(F_QUOTATION *quot, F_COMPILED *code)
{
	quot->code = code;
	quot->xt = (XT)(code + 1);
	quot->compiledp = T;
}

void jit_compile(F_QUOTATION *quot)
{
	F_ARRAY *array = untag_object(quot->array);

	REGISTER_UNTAGGED(quot);

	REGISTER_UNTAGGED(array);
	GROWABLE_ARRAY(result);
	UNREGISTER_UNTAGGED(array);

	bool stack_frame = jit_stack_frame_p(array);

	EMIT(JIT_SETUP);

	if(stack_frame)
		EMIT(JIT_PROLOG);

	CELL i;
	CELL length = array_capacity(array);
	bool tail_call = false;

	for(i = 0; i < length; i++)
	{
		CELL obj = array_nth(array,i);
		F_WORD *word;
		bool primitive_p;

		switch(type_of(obj))
		{
		case WORD_TYPE:
			/* Emit the epilog before the primitive call gate
			so that we save the C stack pointer minus the
			current stack frame. */
			word = untag_object(obj);
			primitive_p = type_of(word->def) == FIXNUM_TYPE;

			if(i == length - 1)
			{
				if(stack_frame)
					EMIT(JIT_EPILOG);

				if(primitive_p)
					EMIT(JIT_WORD_PRIMITIVE_JUMP);

				EMIT(JIT_WORD_JUMP);
				tail_call = true;
			}
			else
			{
				if(primitive_p)
					EMIT(JIT_WORD_PRIMITIVE_CALL);

				EMIT(JIT_WORD_CALL);
			}
			break;
		case WRAPPER_TYPE:
			EMIT(JIT_PUSH_WRAPPER);
			break;
		case QUOTATION_TYPE:
			if(jit_fast_if_p(array,i))
			{
				i += 2;

				if(i == length - 1)
				{
					if(stack_frame)
						EMIT(JIT_EPILOG);
					EMIT(JIT_IF_JUMP);
					tail_call = true;
				}
				else
					EMIT(JIT_IF_CALL);

				break;
			}
		case ARRAY_TYPE:
			if(jit_fast_dispatch_p(array,i))
			{
				i++;

				if(stack_frame)
					EMIT(JIT_EPILOG);

				EMIT(JIT_DISPATCH);

				tail_call = true;
				break;
			}
		default:
			EMIT(JIT_PUSH_LITERAL);
			break;
		}
	}

	if(!tail_call)
	{
		if(stack_frame)
			EMIT(JIT_EPILOG);

		EMIT(JIT_RETURN);
	}

	GROWABLE_TRIM(result);

	UNREGISTER_UNTAGGED(quot);
	REGISTER_UNTAGGED(quot);

	REGISTER_UNTAGGED(result);
	F_ARRAY *literals = allot_array(ARRAY_TYPE,1,tag_object(quot));
	UNREGISTER_UNTAGGED(result);

	F_COMPILED *compiled = add_compiled_block(QUOTATION_TYPE,result,NULL,NULL,NULL,literals);
	iterate_code_heap_step(compiled,finalize_code_block);

	UNREGISTER_UNTAGGED(quot);
	set_quot_xt(quot,compiled);
}

F_FASTCALL CELL primitive_jit_compile(CELL tagged, F_STACK_FRAME *stack)
{
	stack_chain->callstack_top = stack;
	REGISTER_ROOT(tagged);
	jit_compile(untag_quotation(tagged));
	UNREGISTER_ROOT(tagged);
	return tagged;
}

XT quot_offset_to_pc(F_QUOTATION *quot, F_FIXNUM offset)
{
	if(offset != -1)
		critical_error("Not yet implemented",0);

	CELL xt = 0;

	xt += array_capacity(untag_array(userenv[JIT_SETUP]));

	bool stack_frame = jit_stack_frame_p(untag_array(quot->array));
	if(stack_frame)
		xt += array_capacity(untag_array(userenv[JIT_PROLOG]));

	xt *= compiled_code_format();

	return quot->xt + xt;
}

DEFINE_PRIMITIVE(curry)
{
	F_CURRY *curry = allot_object(CURRY_TYPE,sizeof(F_CURRY));

	switch(type_of(dpeek()))
	{
	case QUOTATION_TYPE:
	case CURRY_TYPE:
		curry->quot = dpop();
		curry->obj = dpop();
		dpush(tag_object(curry));
		break;
	default:
		type_error(QUOTATION_TYPE,dpeek());
		break;
	}
}

void uncurry(CELL obj)
{
	F_CURRY *curry;

	switch(type_of(obj))
	{
	case QUOTATION_TYPE:
		dpush(obj);
		break;
	case CURRY_TYPE:
		curry = untag_object(obj);
		dpush(curry->obj);
		uncurry(curry->quot);
		break;
	default:
		type_error(QUOTATION_TYPE,obj);
		break;
	}
}

DEFINE_PRIMITIVE(uncurry)
{
	uncurry(dpop());
}

/* push a new quotation on the stack */
DEFINE_PRIMITIVE(array_to_quotation)
{
	F_QUOTATION *quot = allot_object(QUOTATION_TYPE,sizeof(F_QUOTATION));
	quot->array = dpeek();
	quot->xt = lazy_jit_compile;
	quot->compiledp = F;
	drepl(tag_object(quot));
}

DEFINE_PRIMITIVE(quotation_xt)
{
	F_QUOTATION *quot = untag_quotation(dpeek());
	drepl(allot_cell((CELL)quot->xt));
}

DEFINE_PRIMITIVE(strip_compiled_quotations)
{
	data_gc();
	begin_scan();

	CELL obj;
	while((obj = next_object()) != F)
	{
		if(type_of(obj) == QUOTATION_TYPE)
		{
			F_QUOTATION *quot = untag_object(obj);
			quot->compiledp = F;
			quot->xt = lazy_jit_compile;
		}
	}

	/* end scan */
	gc_off = false;
}
