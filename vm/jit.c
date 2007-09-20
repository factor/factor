#include "master.h"

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

	XT xt = add_compiled_block(QUOTATION_TYPE,result,NULL,NULL,NULL,literals);
	iterate_code_heap_step(xt_to_compiled(xt),finalize_code_block);

	UNREGISTER_UNTAGGED(quot);
	quot->xt = xt;
}

void jit_compile_all(void)
{
	begin_scan();

	CELL obj;
	while((obj = next_object()) != F)
	{
		if(type_of(obj) == QUOTATION_TYPE)
			jit_compile(untag_quotation(obj));
	}

	/* End the scan */
	gc_off = false;
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
