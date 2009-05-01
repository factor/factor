#include "master.h"

/* Simple non-optimizing compiler.

This is one of the two compilers implementing Factor; the second one is written
in Factor and performs advanced optimizations. See core/compiler/compiler.factor.

The non-optimizing compiler compiles a quotation at a time by concatenating
machine code chunks; prolog, epilog, call word, jump to word, etc. These machine
code chunks are generated from Factor code in core/cpu/.../bootstrap.factor.

Calls to words and constant quotations (referenced by conditionals and dips)
are direct jumps to machine code blocks. Literals are also referenced directly
without going through the literal table.

It actually does do a little bit of very simple optimization:

1) Tail call optimization.

2) If a quotation is determined to not call any other words (except for a few
special words which are open-coded, see below), then no prolog/epilog is
generated.

3) When in tail position and immediately preceded by literal arguments, the
'if' is generated inline, instead of as a call to the 'if' word.

4) When preceded by a quotation, calls to 'dip', '2dip' and '3dip' are
open-coded as retain stack manipulation surrounding a subroutine call.

5) Sub-primitives are primitive words which are implemented in assembly and not
in the VM. They are open-coded and no subroutine call is generated. This
includes stack shufflers, some fixnum arithmetic words, and words such as tag,
slot and eq?. A primitive call is relatively expensive (two subroutine calls)
so this results in a big speedup for relatively little effort. */

static bool jit_primitive_call_p(F_ARRAY *array, CELL i)
{
	return (i + 2) == array_capacity(array)
		&& type_of(array_nth(array,i)) == FIXNUM_TYPE
		&& array_nth(array,i + 1) == userenv[JIT_PRIMITIVE_WORD];
}

static bool jit_fast_if_p(F_ARRAY *array, CELL i)
{
	return (i + 3) == array_capacity(array)
		&& type_of(array_nth(array,i)) == QUOTATION_TYPE
		&& type_of(array_nth(array,i + 1)) == QUOTATION_TYPE
		&& array_nth(array,i + 2) == userenv[JIT_IF_WORD];
}

static bool jit_fast_dip_p(F_ARRAY *array, CELL i)
{
	return (i + 2) <= array_capacity(array)
		&& type_of(array_nth(array,i)) == QUOTATION_TYPE
		&& array_nth(array,i + 1) == userenv[JIT_DIP_WORD];
}

static bool jit_fast_2dip_p(F_ARRAY *array, CELL i)
{
	return (i + 2) <= array_capacity(array)
		&& type_of(array_nth(array,i)) == QUOTATION_TYPE
		&& array_nth(array,i + 1) == userenv[JIT_2DIP_WORD];
}

static bool jit_fast_3dip_p(F_ARRAY *array, CELL i)
{
	return (i + 2) <= array_capacity(array)
		&& type_of(array_nth(array,i)) == QUOTATION_TYPE
		&& array_nth(array,i + 1) == userenv[JIT_3DIP_WORD];
}

static bool jit_mega_lookup_p(F_ARRAY *array, CELL i)
{
	return (i + 3) < array_capacity(array)
		&& type_of(array_nth(array,i)) == ARRAY_TYPE
		&& type_of(array_nth(array,i + 1)) == FIXNUM_TYPE
		&& type_of(array_nth(array,i + 2)) == ARRAY_TYPE
		&& array_nth(array,i + 3) == userenv[MEGA_LOOKUP_WORD];
}

static bool jit_stack_frame_p(F_ARRAY *array)
{
	F_FIXNUM length = array_capacity(array);
	F_FIXNUM i;

	for(i = 0; i < length - 1; i++)
	{
		CELL obj = array_nth(array,i);
		if(type_of(obj) == WORD_TYPE)
		{
			F_WORD *word = untag_object(obj);
			if(word->subprimitive == F)
				return true;
		}
		else if(type_of(obj) == QUOTATION_TYPE)
		{
			if(jit_fast_dip_p(array,i)
				|| jit_fast_2dip_p(array,i)
				|| jit_fast_3dip_p(array,i))
				return true;
		}
	}

	return false;
}

#define TAIL_CALL { \
		if(stack_frame) jit_emit(jit,userenv[JIT_EPILOG]); \
		tail_call = true; \
	}

/* Allocates memory */
static void jit_iterate_quotation(F_JIT *jit, CELL array, CELL compiling, CELL relocate)
{
	REGISTER_ROOT(array);

	bool stack_frame = jit_stack_frame_p(untag_object(array));

	jit_set_position(jit,0);

	if(stack_frame)
		jit_emit(jit,userenv[JIT_PROLOG]);

	CELL i;
	CELL length = array_capacity(untag_object(array));
	bool tail_call = false;

	for(i = 0; i < length; i++)
	{
		jit_set_position(jit,i);

		CELL obj = array_nth(untag_object(array),i);
		REGISTER_ROOT(obj);

		F_WORD *word;
		F_WRAPPER *wrapper;

		switch(type_of(obj))
		{
		case WORD_TYPE:
			word = untag_object(obj);

			/* Intrinsics */
			if(word->subprimitive != F)
				jit_emit_subprimitive(jit,word);
			/* The (execute) primitive is special-cased */
			else if(obj == userenv[JIT_EXECUTE_WORD])
			{
				if(i == length - 1)
				{
					TAIL_CALL;
					jit_emit(jit,userenv[JIT_EXECUTE_JUMP]);
				}
				else
					jit_emit(jit,userenv[JIT_EXECUTE_CALL]);
			}
			/* Everything else */
			else
			{
				if(i == length - 1)
				{
					TAIL_CALL;
					jit_word_jump(jit,obj);
				}
				else
					jit_word_call(jit,obj);
			}
			break;
		case WRAPPER_TYPE:
			wrapper = untag_object(obj);
			jit_push(jit,wrapper->object);
			break;
		case FIXNUM_TYPE:
			/* Primitive calls */
			if(jit_primitive_call_p(untag_object(array),i))
			{
				jit_emit(jit,userenv[JIT_SAVE_STACK]);
				jit_emit_with(jit,userenv[JIT_PRIMITIVE],obj);

				i++;

				tail_call = true;
				break;
			}
		case QUOTATION_TYPE:
			/* 'if' preceeded by two literal quotations (this is why if and ? are
			   mutually recursive in the library, but both still work) */
			if(jit_fast_if_p(untag_object(array),i))
			{
				TAIL_CALL;

				if(compiling)
				{
					jit_compile(array_nth(untag_object(array),i),relocate);
					jit_compile(array_nth(untag_object(array),i + 1),relocate);
				}

				jit_emit_with(jit,userenv[JIT_IF_1],array_nth(untag_object(array),i));
				jit_emit_with(jit,userenv[JIT_IF_2],array_nth(untag_object(array),i + 1));

				i += 2;

				break;
			}
			/* dip */
			else if(jit_fast_dip_p(untag_object(array),i))
			{
				if(compiling)
					jit_compile(obj,relocate);
				jit_emit_with(jit,userenv[JIT_DIP],obj);
				i++;
				break;
			}
			/* 2dip */
			else if(jit_fast_2dip_p(untag_object(array),i))
			{
				if(compiling)
					jit_compile(obj,relocate);
				jit_emit_with(jit,userenv[JIT_2DIP],obj);
				i++;
				break;
			}
			/* 3dip */
			else if(jit_fast_3dip_p(untag_object(array),i))
			{
				if(compiling)
					jit_compile(obj,relocate);
				jit_emit_with(jit,userenv[JIT_3DIP],obj);
				i++;
				break;
			}
		case ARRAY_TYPE:
			/* Method dispatch */
			if(jit_mega_lookup_p(untag_object(array),i))
			{
				jit_emit_mega_cache_lookup(jit,
					array_nth(untag_object(array),i),
					untag_fixnum_fast(array_nth(untag_object(array),i + 1)),
					array_nth(untag_object(array),i + 2));
				i += 3;
				tail_call = true;
				break;
			}
		default:
			jit_push(jit,obj);
			break;
		}

		UNREGISTER_ROOT(obj);
	}

	if(!tail_call)
	{
		jit_set_position(jit,length);

		if(stack_frame)
			jit_emit(jit,userenv[JIT_EPILOG]);
		jit_emit(jit,userenv[JIT_RETURN]);
	}

	UNREGISTER_ROOT(array);
}

void set_quot_xt(F_QUOTATION *quot, F_CODE_BLOCK *code)
{
	if(code->block.type != QUOTATION_TYPE)
		critical_error("Bad param to set_quot_xt",(CELL)code);

	quot->code = code;
	quot->xt = (XT)(code + 1);
	quot->compiledp = T;
}

/* Allocates memory */
void jit_compile(CELL quot, bool relocate)
{
	if(untag_quotation(quot)->compiledp != F)
		return;

	CELL array = untag_quotation(quot)->array;

	REGISTER_ROOT(quot);
	REGISTER_ROOT(array);

	F_JIT jit;
	jit_init(&jit,QUOTATION_TYPE,quot);

	jit_iterate_quotation(&jit,array,true,relocate);

	F_CODE_BLOCK *compiled = jit_make_code_block(&jit);

	set_quot_xt(untag_object(quot),compiled);

	if(relocate) relocate_code_block(compiled);

	jit_dispose(&jit);

	UNREGISTER_ROOT(array);
	UNREGISTER_ROOT(quot);
}

F_FIXNUM quot_code_offset_to_scan(CELL quot, CELL offset)
{
	CELL array = untag_quotation(quot)->array;
	REGISTER_ROOT(array);

	F_JIT jit;
	jit_init(&jit,QUOTATION_TYPE,quot);
	jit_compute_position(&jit,offset);
	jit_iterate_quotation(&jit,array,false,false);
	jit_dispose(&jit);

	UNREGISTER_ROOT(array);

	return jit_get_position(&jit);
}

F_FASTCALL CELL lazy_jit_compile_impl(CELL quot, F_STACK_FRAME *stack)
{
	stack_chain->callstack_top = stack;
	REGISTER_ROOT(quot);
	jit_compile(quot,true);
	UNREGISTER_ROOT(quot);
	return quot;
}

void primitive_jit_compile(void)
{
	jit_compile(dpop(),true);
}

/* push a new quotation on the stack */
void primitive_array_to_quotation(void)
{
	F_QUOTATION *quot = allot_object(QUOTATION_TYPE,sizeof(F_QUOTATION));
	quot->array = dpeek();
	quot->xt = lazy_jit_compile;
	quot->compiledp = F;
	quot->cached_effect = F;
	quot->cache_counter = F;
	drepl(tag_quotation(quot));
}

void primitive_quotation_xt(void)
{
	F_QUOTATION *quot = untag_quotation(dpeek());
	drepl(allot_cell((CELL)quot->xt));
}

void compile_all_words(void)
{
	CELL words = find_all_words();

	REGISTER_ROOT(words);

	CELL i;
	CELL length = array_capacity(untag_object(words));
	for(i = 0; i < length; i++)
	{
		F_WORD *word = untag_word(array_nth(untag_array(words),i));
		REGISTER_UNTAGGED(word);

		if(!word->code || !word_optimized_p(word))
			jit_compile_word(word,word->def,false);

		UNREGISTER_UNTAGGED(word);
		update_word_xt(word);

	}

	UNREGISTER_ROOT(words);

	iterate_code_heap(relocate_code_block);
}
