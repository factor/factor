#include "master.hpp"

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

bool quotation_jit::primitive_call_p(CELL i)
{
	return (i + 2) == array_capacity(array.untagged())
		&& type_of(array_nth(array.untagged(),i)) == FIXNUM_TYPE
		&& array_nth(array.untagged(),i + 1) == userenv[JIT_PRIMITIVE_WORD];
}

bool quotation_jit::fast_if_p(CELL i)
{
	return (i + 3) == array_capacity(array.untagged())
		&& type_of(array_nth(array.untagged(),i)) == QUOTATION_TYPE
		&& type_of(array_nth(array.untagged(),i + 1)) == QUOTATION_TYPE
		&& array_nth(array.untagged(),i + 2) == userenv[JIT_IF_WORD];
}

bool quotation_jit::fast_dip_p(CELL i)
{
	return (i + 2) <= array_capacity(array.untagged())
		&& type_of(array_nth(array.untagged(),i)) == QUOTATION_TYPE
		&& array_nth(array.untagged(),i + 1) == userenv[JIT_DIP_WORD];
}

bool quotation_jit::fast_2dip_p(CELL i)
{
	return (i + 2) <= array_capacity(array.untagged())
		&& type_of(array_nth(array.untagged(),i)) == QUOTATION_TYPE
		&& array_nth(array.untagged(),i + 1) == userenv[JIT_2DIP_WORD];
}

bool quotation_jit::fast_3dip_p(CELL i)
{
	return (i + 2) <= array_capacity(array.untagged())
		&& type_of(array_nth(array.untagged(),i)) == QUOTATION_TYPE
		&& array_nth(array.untagged(),i + 1) == userenv[JIT_3DIP_WORD];
}

bool quotation_jit::mega_lookup_p(CELL i)
{
	return (i + 3) < array_capacity(array.untagged())
		&& type_of(array_nth(array.untagged(),i)) == ARRAY_TYPE
		&& type_of(array_nth(array.untagged(),i + 1)) == FIXNUM_TYPE
		&& type_of(array_nth(array.untagged(),i + 2)) == ARRAY_TYPE
		&& array_nth(array.untagged(),i + 3) == userenv[MEGA_LOOKUP_WORD];
}

bool quotation_jit::stack_frame_p()
{
	F_FIXNUM length = array_capacity(array.untagged());
	F_FIXNUM i;

	for(i = 0; i < length - 1; i++)
	{
		CELL obj = array_nth(array.untagged(),i);
		if(type_of(obj) == WORD_TYPE)
		{
			if(untag<F_WORD>(obj)->subprimitive == F)
				return true;
		}
		else if(type_of(obj) == QUOTATION_TYPE)
		{
			if(fast_dip_p(i) || fast_2dip_p(i) || fast_3dip_p(i))
				return true;
		}
	}

	return false;
}

/* Allocates memory */
void quotation_jit::iterate_quotation()
{
	bool stack_frame = stack_frame_p();

	set_position(0);

	if(stack_frame)
		emit(userenv[JIT_PROLOG]);

	CELL i;
	CELL length = array_capacity(array.untagged());
	bool tail_call = false;

	for(i = 0; i < length; i++)
	{
		set_position(i);

		gc_root<F_OBJECT> obj(array_nth(array.untagged(),i));

		switch(obj.type())
		{
		case WORD_TYPE:
			/* Intrinsics */
			if(obj.as<F_WORD>()->subprimitive != F)
				emit_subprimitive(obj.value());
			/* The (execute) primitive is special-cased */
			else if(obj.value() == userenv[JIT_EXECUTE_WORD])
			{
				if(i == length - 1)
				{
					if(stack_frame) emit(userenv[JIT_EPILOG]);
					tail_call = true;
					emit(userenv[JIT_EXECUTE_JUMP]);
				}
				else
					emit(userenv[JIT_EXECUTE_CALL]);
			}
			/* Everything else */
			else
			{
				if(i == length - 1)
				{
					if(stack_frame) emit(userenv[JIT_EPILOG]);
					tail_call = true;
					word_jump(obj.value());
				}
				else
					word_call(obj.value());
			}
			break;
		case WRAPPER_TYPE:
			push(obj.as<F_WRAPPER>()->object);
			break;
		case FIXNUM_TYPE:
			/* Primitive calls */
			if(primitive_call_p(i))
			{
				emit(userenv[JIT_SAVE_STACK]);
				emit_with(userenv[JIT_PRIMITIVE],obj.value());

				i++;

				tail_call = true;
				break;
			}
		case QUOTATION_TYPE:
			/* 'if' preceeded by two literal quotations (this is why if and ? are
			   mutually recursive in the library, but both still work) */
			if(fast_if_p(i))
			{
				if(stack_frame) emit(userenv[JIT_EPILOG]);
				tail_call = true;

				if(compiling)
				{
					jit_compile(array_nth(array.untagged(),i),relocate);
					jit_compile(array_nth(array.untagged(),i + 1),relocate);
				}

				emit_with(userenv[JIT_IF_1],array_nth(array.untagged(),i));
				emit_with(userenv[JIT_IF_2],array_nth(array.untagged(),i + 1));

				i += 2;

				break;
			}
			/* dip */
			else if(fast_dip_p(i))
			{
				if(compiling)
					jit_compile(obj.value(),relocate);
				emit_with(userenv[JIT_DIP],obj.value());
				i++;
				break;
			}
			/* 2dip */
			else if(fast_2dip_p(i))
			{
				if(compiling)
					jit_compile(obj.value(),relocate);
				emit_with(userenv[JIT_2DIP],obj.value());
				i++;
				break;
			}
			/* 3dip */
			else if(fast_3dip_p(i))
			{
				if(compiling)
					jit_compile(obj.value(),relocate);
				emit_with(userenv[JIT_3DIP],obj.value());
				i++;
				break;
			}
		case ARRAY_TYPE:
			/* Method dispatch */
			if(mega_lookup_p(i))
			{
				emit_mega_cache_lookup(
					array_nth(array.untagged(),i),
					untag_fixnum(array_nth(array.untagged(),i + 1)),
					array_nth(array.untagged(),i + 2));
				i += 3;
				tail_call = true;
				break;
			}
		default:
			push(obj.value());
			break;
		}
	}

	if(!tail_call)
	{
		set_position(length);

		if(stack_frame)
			emit(userenv[JIT_EPILOG]);
		emit(userenv[JIT_RETURN]);
	}
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
void jit_compile(CELL quot_, bool relocating)
{
	gc_root<F_QUOTATION> quot(quot_);
	if(quot->compiledp != F) return;

	quotation_jit jit(quot.value(),true,relocating);
	jit.iterate_quotation();

	F_CODE_BLOCK *compiled = jit.code_block();
	set_quot_xt(quot.untagged(),compiled);

	if(relocating) relocate_code_block(compiled);
}

F_FASTCALL CELL lazy_jit_compile_impl(CELL quot_, F_STACK_FRAME *stack)
{
	gc_root<F_QUOTATION> quot(quot_);
	stack_chain->callstack_top = stack;
	jit_compile(quot.value(),true);
	return quot.value();
}

void primitive_jit_compile(void)
{
	jit_compile(dpop(),true);
}

/* push a new quotation on the stack */
void primitive_array_to_quotation(void)
{
	F_QUOTATION *quot = allot<F_QUOTATION>(sizeof(F_QUOTATION));
	quot->array = dpeek();
	quot->xt = (void *)lazy_jit_compile;
	quot->compiledp = F;
	quot->cached_effect = F;
	quot->cache_counter = F;
	drepl(tag<F_QUOTATION>(quot));
}

void primitive_quotation_xt(void)
{
	F_QUOTATION *quot = untag_check<F_QUOTATION>(dpeek());
	drepl(allot_cell((CELL)quot->xt));
}

void compile_all_words(void)
{
	gc_root<F_ARRAY> words(find_all_words());

	CELL i;
	CELL length = array_capacity(words.untagged());
	for(i = 0; i < length; i++)
	{
		gc_root<F_WORD> word(array_nth(words.untagged(),i));

		if(!word->code || !word_optimized_p(word.untagged()))
			jit_compile_word(word.value(),word->def,false);

		update_word_xt(word.value());

	}

	iterate_code_heap(relocate_code_block);
}

/* Allocates memory */
F_FIXNUM quot_code_offset_to_scan(CELL quot_, CELL offset)
{
	gc_root<F_QUOTATION> quot(quot_);
	gc_root<F_ARRAY> array(quot->array);

	quotation_jit jit(quot.value(),false,false);
	jit.compute_position(offset);
	jit.iterate_quotation();

	return jit.get_position();
}
