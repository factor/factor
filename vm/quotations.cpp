#include "master.hpp"

namespace factor
{

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

bool quotation_jit::primitive_call_p(cell i)
{
	return (i + 2) == array_capacity(elements.untagged())
		&& tagged<object>(array_nth(elements.untagged(),i)).type_p(FIXNUM_TYPE)
		&& array_nth(elements.untagged(),i + 1) == userenv[JIT_PRIMITIVE_WORD];
}

bool quotation_jit::fast_if_p(cell i)
{
	return (i + 3) == array_capacity(elements.untagged())
		&& tagged<object>(array_nth(elements.untagged(),i)).type_p(QUOTATION_TYPE)
		&& tagged<object>(array_nth(elements.untagged(),i + 1)).type_p(QUOTATION_TYPE)
		&& array_nth(elements.untagged(),i + 2) == userenv[JIT_IF_WORD];
}

bool quotation_jit::fast_dip_p(cell i)
{
	return (i + 2) <= array_capacity(elements.untagged())
		&& tagged<object>(array_nth(elements.untagged(),i)).type_p(QUOTATION_TYPE)
		&& array_nth(elements.untagged(),i + 1) == userenv[JIT_DIP_WORD];
}

bool quotation_jit::fast_2dip_p(cell i)
{
	return (i + 2) <= array_capacity(elements.untagged())
		&& tagged<object>(array_nth(elements.untagged(),i)).type_p(QUOTATION_TYPE)
		&& array_nth(elements.untagged(),i + 1) == userenv[JIT_2DIP_WORD];
}

bool quotation_jit::fast_3dip_p(cell i)
{
	return (i + 2) <= array_capacity(elements.untagged())
		&& tagged<object>(array_nth(elements.untagged(),i)).type_p(QUOTATION_TYPE)
		&& array_nth(elements.untagged(),i + 1) == userenv[JIT_3DIP_WORD];
}

bool quotation_jit::mega_lookup_p(cell i)
{
	return (i + 3) < array_capacity(elements.untagged())
		&& tagged<object>(array_nth(elements.untagged(),i)).type_p(ARRAY_TYPE)
		&& tagged<object>(array_nth(elements.untagged(),i + 1)).type_p(FIXNUM_TYPE)
		&& tagged<object>(array_nth(elements.untagged(),i + 2)).type_p(ARRAY_TYPE)
		&& array_nth(elements.untagged(),i + 3) == userenv[MEGA_LOOKUP_WORD];
}

bool quotation_jit::stack_frame_p()
{
	fixnum length = array_capacity(elements.untagged());
	fixnum i;

	for(i = 0; i < length - 1; i++)
	{
		cell obj = array_nth(elements.untagged(),i);
		switch(tagged<object>(obj).type())
		{
		case WORD_TYPE:
			if(untag<word>(obj)->subprimitive == F)
				return true;
			break;
		case QUOTATION_TYPE:
			if(fast_dip_p(i) || fast_2dip_p(i) || fast_3dip_p(i))
				return true;
			break;
		default:
			break;
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

	cell i;
	cell length = array_capacity(elements.untagged());
	bool tail_call = false;

	for(i = 0; i < length; i++)
	{
		set_position(i);

		gc_root<object> obj(array_nth(elements.untagged(),i));

		switch(obj.type())
		{
		case WORD_TYPE:
			/* Intrinsics */
			if(obj.as<word>()->subprimitive != F)
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
					/* Inline cache misses are special-cased.
					   The calling convention for tail
					   calls stores the address of the next
					   instruction in a register. However,
					   PIC miss stubs themselves tail-call
					   the inline cache miss primitive, and
					   we don't want to clobber the saved
					   address. */
					if(obj.value() == userenv[PIC_MISS_WORD]
					   || obj.value() == userenv[PIC_MISS_TAIL_WORD])
					{
						word_special(obj.value());
					}
					else
					{
						word_jump(obj.value());
					}
				}
				else
					word_call(obj.value());
			}
			break;
		case WRAPPER_TYPE:
			push(obj.as<wrapper>()->object);
			break;
		case FIXNUM_TYPE:
			/* Primitive calls */
			if(primitive_call_p(i))
			{
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
					jit_compile(array_nth(elements.untagged(),i),relocate);
					jit_compile(array_nth(elements.untagged(),i + 1),relocate);
				}

				literal(array_nth(elements.untagged(),i));
				literal(array_nth(elements.untagged(),i + 1));
				emit(userenv[JIT_IF]);

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
					array_nth(elements.untagged(),i),
					untag_fixnum(array_nth(elements.untagged(),i + 1)),
					array_nth(elements.untagged(),i + 2));
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

void set_quot_xt(quotation *quot, code_block *code)
{
	if(code->type != QUOTATION_TYPE)
		critical_error("Bad param to set_quot_xt",(cell)code);

	quot->code = code;
	quot->xt = code->xt();
}

/* Allocates memory */
void jit_compile(cell quot_, bool relocating)
{
	gc_root<quotation> quot(quot_);
	if(quot->code) return;

	quotation_jit compiler(quot.value(),true,relocating);
	compiler.iterate_quotation();

	code_block *compiled = compiler.to_code_block();
	set_quot_xt(quot.untagged(),compiled);

	if(relocating) relocate_code_block(compiled);
}

PRIMITIVE(jit_compile)
{
	jit_compile(dpop(),true);
}

/* push a new quotation on the stack */
PRIMITIVE(array_to_quotation)
{
	quotation *quot = allot<quotation>(sizeof(quotation));
	quot->array = dpeek();
	quot->cached_effect = F;
	quot->cache_counter = F;
	quot->xt = (void *)lazy_jit_compile;
	quot->code = NULL;
	drepl(tag<quotation>(quot));
}

PRIMITIVE(quotation_xt)
{
	quotation *quot = untag_check<quotation>(dpeek());
	drepl(allot_cell((cell)quot->xt));
}

void compile_all_words()
{
	gc_root<array> words(find_all_words());

	cell i;
	cell length = array_capacity(words.untagged());
	for(i = 0; i < length; i++)
	{
		gc_root<word> word(array_nth(words.untagged(),i));

		if(!word->code || !word_optimized_p(word.untagged()))
			jit_compile_word(word.value(),word->def,false);

		update_word_xt(word.value());

	}

	iterate_code_heap(relocate_code_block);
}

/* Allocates memory */
fixnum quot_code_offset_to_scan(cell quot_, cell offset)
{
	gc_root<quotation> quot(quot_);
	gc_root<array> array(quot->array);

	quotation_jit compiler(quot.value(),false,false);
	compiler.compute_position(offset);
	compiler.iterate_quotation();

	return compiler.get_position();
}

VM_ASM_API cell lazy_jit_compile_impl(cell quot_, stack_frame *stack)
{
	gc_root<quotation> quot(quot_);
	stack_chain->callstack_top = stack;
	jit_compile(quot.value(),true);
	return quot.value();
}

PRIMITIVE(quot_compiled_p)
{
	tagged<quotation> quot(dpop());
	quot.untag_check();
	dpush(tag_boolean(quot->code != NULL));
}

}
