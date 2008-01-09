#include "master.h"

/* Simple JIT compiler. This is one of the two compilers implementing Factor;
the second one is written in Factor and performs a lot of optimizations.
See core/compiler/compiler.factor */
bool jit_primitive_call_p(F_ARRAY *array, CELL i)
{
	return (i + 2) == array_capacity(array)
		&& type_of(array_nth(array,i)) == FIXNUM_TYPE
		&& array_nth(array,i + 1) == userenv[JIT_PRIMITIVE_WORD];
}

bool jit_fast_if_p(F_ARRAY *array, CELL i)
{
	return (i + 3) == array_capacity(array)
		&& type_of(array_nth(array,i)) == QUOTATION_TYPE
		&& type_of(array_nth(array,i + 1)) == QUOTATION_TYPE
		&& array_nth(array,i + 2) == userenv[JIT_IF_WORD];
}

bool jit_fast_dispatch_p(F_ARRAY *array, CELL i)
{
	return (i + 2) == array_capacity(array)
		&& type_of(array_nth(array,i)) == ARRAY_TYPE
		&& array_nth(array,i + 1) == userenv[JIT_DISPATCH_WORD];
}

F_ARRAY *code_to_emit(CELL name)
{
	return untag_object(array_nth(untag_object(userenv[name]),0));
}

F_REL rel_to_emit(CELL name, CELL code_format, CELL code_length,
	CELL rel_argument, bool *rel_p)
{
	F_ARRAY *quadruple = untag_object(userenv[name]);
	CELL rel_class = array_nth(quadruple,1);
	CELL rel_type = array_nth(quadruple,2);
	CELL offset = array_nth(quadruple,3);

	F_REL rel;

	if(rel_class == F)
	{
		*rel_p = false;
		rel.type = 0;
		rel.offset = 0;
	}
	else
	{
		*rel_p = true;
		rel.type = to_fixnum(rel_type)
			| (to_fixnum(rel_class) << 8)
			| (rel_argument << 16);
		rel.offset = (code_length + to_fixnum(offset)) * code_format;
	}

	return rel;
}

#define EMIT(name,rel_argument) { \
		bool rel_p; \
		F_REL rel = rel_to_emit(name,code_format,code_count, \
			rel_argument,&rel_p); \
		if(rel_p) \
		{ \
			GROWABLE_ADD(relocation,allot_cell(rel.type)); \
			GROWABLE_ADD(relocation,allot_cell(rel.offset)); \
		} \
		GROWABLE_APPEND(code,code_to_emit(name)); \
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
	if(code->type != QUOTATION_TYPE)
		critical_error("bad param to set_quot_xt",(CELL)code);

	quot->code = code;
	quot->xt = (XT)(code + 1);
	quot->compiledp = T;
}

/* Might GC */
void jit_compile(CELL quot, bool relocate)
{
	if(untag_quotation(quot)->compiledp != F)
		return;

	CELL code_format = compiled_code_format();

	REGISTER_ROOT(quot);

	CELL array = untag_quotation(quot)->array;
	REGISTER_ROOT(array);

	GROWABLE_ARRAY(code);
	REGISTER_ROOT(code);

	GROWABLE_ARRAY(relocation);
	REGISTER_ROOT(relocation);

	GROWABLE_ARRAY(literals);
	REGISTER_ROOT(literals);

	GROWABLE_ARRAY(words);
	REGISTER_ROOT(words);

	GROWABLE_ADD(literals,stack_traces_p() ? quot : F);

	bool stack_frame = jit_stack_frame_p(untag_object(array));

	if(stack_frame)
		EMIT(JIT_PROLOG,0);

	CELL i;
	CELL length = array_capacity(untag_object(array));
	bool tail_call = false;

	for(i = 0; i < length; i++)
	{
		CELL obj = array_nth(untag_object(array),i);
		F_WORD *word;
		F_WRAPPER *wrapper;

		switch(type_of(obj))
		{
		case WORD_TYPE:
			/* Emit the epilog before the primitive call gate
			so that we save the C stack pointer minus the
			current stack frame. */
			word = untag_object(obj);

			GROWABLE_ADD(words,array_nth(untag_object(array),i));

			if(i == length - 1)
			{
				if(stack_frame)
					EMIT(JIT_EPILOG,0);

				EMIT(JIT_WORD_JUMP,words_count - 1);

				tail_call = true;
			}
			else
				EMIT(JIT_WORD_CALL,words_count - 1);
			break;
		case WRAPPER_TYPE:
			wrapper = untag_object(obj);
			GROWABLE_ADD(literals,wrapper->object);
			EMIT(JIT_PUSH_LITERAL,literals_count - 1);
			break;
		case FIXNUM_TYPE:
			if(jit_primitive_call_p(untag_object(array),i))
			{
				EMIT(JIT_PRIMITIVE,to_fixnum(obj));

				i++;

				tail_call = true;
				break;
			}
		case QUOTATION_TYPE:
			if(jit_fast_if_p(untag_object(array),i))
			{
				if(stack_frame)
					EMIT(JIT_EPILOG,0);

				GROWABLE_ADD(literals,array_nth(untag_object(array),i));
				GROWABLE_ADD(literals,array_nth(untag_object(array),i + 1));
				EMIT(JIT_IF_JUMP,literals_count - 2);

				i += 2;

				tail_call = true;
				break;
			}
		case ARRAY_TYPE:
			if(jit_fast_dispatch_p(untag_object(array),i))
			{
				if(stack_frame)
					EMIT(JIT_EPILOG,0);

				GROWABLE_ADD(literals,array_nth(untag_object(array),i));
				EMIT(JIT_DISPATCH,literals_count - 1);

				i++;

				tail_call = true;
				break;
			}
		default:
			GROWABLE_ADD(literals,obj);
			EMIT(JIT_PUSH_LITERAL,literals_count - 1);
			break;
		}
	}

	if(!tail_call)
	{
		if(stack_frame)
			EMIT(JIT_EPILOG,0);

		EMIT(JIT_RETURN,0);
	}

	GROWABLE_TRIM(code);
	GROWABLE_TRIM(relocation);
	GROWABLE_TRIM(literals);
	GROWABLE_TRIM(words);

	F_COMPILED *compiled = add_compiled_block(
		QUOTATION_TYPE,
		untag_object(code),
		NULL,
		untag_object(relocation),
		untag_object(words),
		untag_object(literals));

	set_quot_xt(untag_object(quot),compiled);

	if(relocate)
		iterate_code_heap_step(compiled,relocate_code_block);

	UNREGISTER_ROOT(words);
	UNREGISTER_ROOT(literals);
	UNREGISTER_ROOT(relocation);
	UNREGISTER_ROOT(code);
	UNREGISTER_ROOT(array);
	UNREGISTER_ROOT(quot);
}

/* Crappy code duplication. If C had closures (not just function pointers)
it would be easy to get rid of, but I can't think of a good way to deal
with it right now that doesn't involve lots of boilerplate that would be
worse than the duplication itself (eg, putting all state in some global
struct.) */
#define COUNT(name,scan) \
	{ \
		if(offset == 0) return scan - 1; \
		offset -= array_capacity(code_to_emit(name)) * code_format; \
	}

F_FIXNUM quot_code_offset_to_scan(CELL quot, F_FIXNUM offset)
{
	CELL code_format = compiled_code_format();

	CELL array = untag_quotation(quot)->array;

	bool stack_frame = jit_stack_frame_p(untag_object(array));

	if(stack_frame)
		COUNT(JIT_PROLOG,0)

	CELL i;
	CELL length = array_capacity(untag_object(array));
	bool tail_call = false;

	for(i = 0; i < length; i++)
	{
		CELL obj = array_nth(untag_object(array),i);
		F_WORD *word;

		switch(type_of(obj))
		{
		case WORD_TYPE:
			word = untag_object(obj);

			if(i == length - 1)
			{
				if(stack_frame)
					COUNT(JIT_EPILOG,i);

				COUNT(JIT_WORD_JUMP,i)

				tail_call = true;
			}
			else
				COUNT(JIT_WORD_CALL,i)
			break;
		case WRAPPER_TYPE:
			COUNT(JIT_PUSH_LITERAL,i)
			break;
		case FIXNUM_TYPE:
			if(jit_primitive_call_p(untag_object(array),i))
			{
				COUNT(JIT_PRIMITIVE,i);

				i++;

				tail_call = true;
				break;
			}
		case QUOTATION_TYPE:
			if(jit_fast_if_p(untag_object(array),i))
			{
				if(stack_frame)
					COUNT(JIT_EPILOG,i)

				i += 2;

				COUNT(JIT_IF_JUMP,i)

				tail_call = true;
				break;
			}
		case ARRAY_TYPE:
			if(jit_fast_dispatch_p(untag_object(array),i))
			{
				if(stack_frame)
					COUNT(JIT_EPILOG,i)

				i++;

				COUNT(JIT_DISPATCH,i)

				tail_call = true;
				break;
			}
		default:
			COUNT(JIT_PUSH_LITERAL,i)
			break;
		}
	}

	if(!tail_call)
	{
		if(stack_frame)
			COUNT(JIT_EPILOG,length)

		COUNT(JIT_RETURN,length)
	}

	return -1;
}

F_FASTCALL CELL primitive_jit_compile(CELL quot, F_STACK_FRAME *stack)
{
	stack_chain->callstack_top = stack;
	REGISTER_ROOT(quot);
	jit_compile(quot,true);
	UNREGISTER_ROOT(quot);
	return quot;
}

DEFINE_PRIMITIVE(curry)
{
	F_CURRY *curry;

	switch(type_of(dpeek()))
	{
	case QUOTATION_TYPE:
	case CURRY_TYPE:
		curry = allot_object(CURRY_TYPE,sizeof(F_CURRY));
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
