#include "master.hpp"

namespace factor
{

/* Simple non-optimizing compiler.

This is one of the two compilers implementing Factor; the second one is written
in Factor and performs advanced optimizations. See basis/compiler/compiler.factor.

The non-optimizing compiler compiles a quotation at a time by concatenating
machine code chunks; prolog, epilog, call word, jump to word, etc. These machine
code chunks are generated from Factor code in basis/cpu/.../bootstrap.factor.

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

void quotation_jit::init_quotation(cell quot)
{
	elements = untag<quotation>(quot)->array;
}

bool quotation_jit::primitive_call_p(cell i, cell length)
{
	return (i + 2) <= length && array_nth(elements.untagged(),i + 1) == parent->special_objects[JIT_PRIMITIVE_WORD];
}

bool quotation_jit::fast_if_p(cell i, cell length)
{
	return (i + 3) == length
		&& tagged<object>(array_nth(elements.untagged(),i + 1)).type_p(QUOTATION_TYPE)
		&& array_nth(elements.untagged(),i + 2) == parent->special_objects[JIT_IF_WORD];
}

bool quotation_jit::fast_dip_p(cell i, cell length)
{
	return (i + 2) <= length && array_nth(elements.untagged(),i + 1) == parent->special_objects[JIT_DIP_WORD];
}

bool quotation_jit::fast_2dip_p(cell i, cell length)
{
	return (i + 2) <= length && array_nth(elements.untagged(),i + 1) == parent->special_objects[JIT_2DIP_WORD];
}

bool quotation_jit::fast_3dip_p(cell i, cell length)
{
	return (i + 2) <= length && array_nth(elements.untagged(),i + 1) == parent->special_objects[JIT_3DIP_WORD];
}

bool quotation_jit::mega_lookup_p(cell i, cell length)
{
	return (i + 4) <= length
		&& tagged<object>(array_nth(elements.untagged(),i + 1)).type_p(FIXNUM_TYPE)
		&& tagged<object>(array_nth(elements.untagged(),i + 2)).type_p(ARRAY_TYPE)
		&& array_nth(elements.untagged(),i + 3) == parent->special_objects[MEGA_LOOKUP_WORD];
}

bool quotation_jit::declare_p(cell i, cell length)
{
	return (i + 2) <= length
		&& array_nth(elements.untagged(),i + 1) == parent->special_objects[JIT_DECLARE_WORD];
}

bool quotation_jit::special_subprimitive_p(cell obj)
{
	// Subprimitives should be flagged with whether they require a stack frame.
	// See #295.
	return obj == parent->special_objects[SIGNAL_HANDLER_WORD]
		|| obj == parent->special_objects[LEAF_SIGNAL_HANDLER_WORD]
		|| obj == parent->special_objects[FFI_SIGNAL_HANDLER_WORD]
		|| obj == parent->special_objects[FFI_LEAF_SIGNAL_HANDLER_WORD]
		|| obj == parent->special_objects[UNWIND_NATIVE_FRAMES_WORD];
}

bool quotation_jit::word_stack_frame_p(cell obj)
{
	return (to_boolean(untag<word>(obj)->subprimitive) && !special_subprimitive_p(obj))
		|| obj == parent->special_objects[JIT_PRIMITIVE_WORD];
}

bool quotation_jit::word_safepoint_p(cell obj)
{
	return !special_subprimitive_p(obj);
}

bool quotation_jit::safepoint_p()
{
	fixnum length = array_capacity(elements.untagged());

	for(fixnum i = 0; i < length; i++)
	{
		cell obj = array_nth(elements.untagged(),i);
		switch(tagged<object>(obj).type())
		{
		case WORD_TYPE:
			if(!word_safepoint_p(obj))
				return false;
			break;
		default:
			break;
		}
	}

	return true;
}

bool quotation_jit::stack_frame_p()
{
	fixnum length = array_capacity(elements.untagged());

	for(fixnum i = 0; i < length; i++)
	{
		cell obj = array_nth(elements.untagged(),i);
		if (tagged<object>(obj).type() == WORD_TYPE && !word_safepoint_p(obj))
			return false;
	}

	return true;
}

bool quotation_jit::trivial_quotation_p(array *elements)
{
	return array_capacity(elements) == 1 && tagged<object>(array_nth(elements,0)).type_p(WORD_TYPE);
}

void quotation_jit::emit_prolog(bool safepoint, bool stack_frame)
{
	if(safepoint) emit(parent->special_objects[JIT_SAFEPOINT]);
	if(stack_frame) emit(parent->special_objects[JIT_PROLOG]);
}

void quotation_jit::emit_epilog(bool safepoint, bool stack_frame)
{
	if(safepoint) emit(parent->special_objects[JIT_SAFEPOINT]);
	if(stack_frame) emit(parent->special_objects[JIT_EPILOG]);
}

void quotation_jit::emit_quot(cell quot_)
{
	data_root<quotation> quot(quot_,parent);

	array *elements = untag<array>(quot->array);

	/* If the quotation consists of a single word, compile a direct call
	to the word. */
	if(trivial_quotation_p(elements))
		literal(array_nth(elements,0));
	else
	{
		if(compiling) parent->jit_compile_quot(quot.value(),relocate);
		literal(quot.value());
	}
}

/* Allocates memory */
void quotation_jit::iterate_quotation()
{
	bool safepoint = safepoint_p();
	bool stack_frame = stack_frame_p();

	set_position(0);

	emit_prolog(safepoint, stack_frame);

	cell i;
	cell length = array_capacity(elements.untagged());
	bool tail_call = false;

	for(i = 0; i < length; i++)
	{
		set_position(i);

		data_root<object> obj(array_nth(elements.untagged(),i),parent);

		switch(obj.type())
		{
		case WORD_TYPE:
			/* Sub-primitives */
			if(to_boolean(obj.as<word>()->subprimitive))
			{
				tail_call = emit_subprimitive(obj.value(), /* word */
					i == length - 1, /* tail_call_p */
					stack_frame); /* stack_frame_p */
			}
			/* Everything else */
			else if(i == length - 1)
			{
				emit_epilog(safepoint, stack_frame);
				tail_call = true;
				word_jump(obj.value());
			}
			else
				word_call(obj.value());
			break;
		case WRAPPER_TYPE:
			push(obj.as<wrapper>()->object);
			break;
		case BYTE_ARRAY_TYPE:
			/* Primitive calls */
			if(primitive_call_p(i,length))
			{
				/* On x86-64 and PowerPC, the VM pointer is stored in
				a register; on other platforms, the RT_VM relocation
				is used and it needs an offset parameter */
#ifdef FACTOR_X86
				parameter(tag_fixnum(0));
#endif
				parameter(obj.value());
				parameter(false_object);
#ifdef FACTOR_PPC_TOC
				parameter(obj.value());
				parameter(false_object);
#endif
				emit(parent->special_objects[JIT_PRIMITIVE]);

				i++;
			}
			else
				push(obj.value());
			break;
		case QUOTATION_TYPE:
			/* 'if' preceded by two literal quotations (this is why if and ? are
			   mutually recursive in the library, but both still work) */
			if(fast_if_p(i,length))
			{
				emit_epilog(safepoint, stack_frame);
				tail_call = true;

				emit_quot(array_nth(elements.untagged(),i));
				emit_quot(array_nth(elements.untagged(),i + 1));
				emit(parent->special_objects[JIT_IF]);

				i += 2;
			}
			/* dip */
			else if(fast_dip_p(i,length))
			{
				emit_quot(obj.value());
				emit(parent->special_objects[JIT_DIP]);
				i++;
			}
			/* 2dip */
			else if(fast_2dip_p(i,length))
			{
				emit_quot(obj.value());
				emit(parent->special_objects[JIT_2DIP]);
				i++;
			}
			/* 3dip */
			else if(fast_3dip_p(i,length))
			{
				emit_quot(obj.value());
				emit(parent->special_objects[JIT_3DIP]);
				i++;
			}
			else
				push(obj.value());
			break;
		case ARRAY_TYPE:
			/* Method dispatch */
			if(mega_lookup_p(i,length))
			{
				fixnum index = untag_fixnum(array_nth(elements.untagged(),i + 1));
				/* Load the object from the datastack, then remove our stack frame. */
				emit_with_literal(parent->special_objects[PIC_LOAD],tag_fixnum(-index * sizeof(cell)));
				emit_epilog(safepoint, stack_frame);
				tail_call = true;

				emit_mega_cache_lookup(
					array_nth(elements.untagged(),i),
					index,
					array_nth(elements.untagged(),i + 2));
				i += 3;
			}
			/* Non-optimizing compiler ignores declarations */
			else if(declare_p(i,length))
				i++;
			else
				push(obj.value());
			break;
		default:
			push(obj.value());
			break;
		}
	}

	if(!tail_call)
	{
		set_position(length);

		emit_epilog(safepoint, stack_frame);
		emit(parent->special_objects[JIT_RETURN]);
	}
}

cell quotation_jit::word_stack_frame_size(cell obj)
{
	if (special_subprimitive_p(obj))
		return SIGNAL_HANDLER_STACK_FRAME_SIZE;
	else
		return JIT_FRAME_SIZE;
}

/* Allocates memory */
code_block *factor_vm::jit_compile_quot(cell owner_, cell quot_, bool relocating)
{
	data_root<object> owner(owner_,this);
	data_root<quotation> quot(quot_,this);

	quotation_jit compiler(owner.value(),true,relocating,this);
	compiler.init_quotation(quot.value());
	compiler.iterate_quotation();

	cell frame_size = compiler.word_stack_frame_size(owner_);

	code_block *compiled = compiler.to_code_block(frame_size);

	if(relocating) initialize_code_block(compiled);

	return compiled;
}

void factor_vm::jit_compile_quot(cell quot_, bool relocating)
{
	data_root<quotation> quot(quot_,this);
	if(!quot_compiled_p(quot.untagged()))
	{
		code_block *compiled = jit_compile_quot(quot.value(),quot.value(),relocating);
		quot.untagged()->entry_point = compiled->entry_point();
	}
}

void factor_vm::primitive_jit_compile()
{
	jit_compile_quot(ctx->pop(),true);
}

void *factor_vm::lazy_jit_compile_entry_point()
{
	return untag<word>(special_objects[LAZY_JIT_COMPILE_WORD])->entry_point;
}

/* push a new quotation on the stack */
void factor_vm::primitive_array_to_quotation()
{
	quotation *quot = allot<quotation>(sizeof(quotation));

	quot->array = ctx->peek();
	quot->cached_effect = false_object;
	quot->cache_counter = false_object;
	quot->entry_point = lazy_jit_compile_entry_point();

	ctx->replace(tag<quotation>(quot));
}

void factor_vm::primitive_quotation_code()
{
	quotation *quot = untag_check<quotation>(ctx->pop());

	ctx->push(from_unsigned_cell((cell)quot->entry_point));
	ctx->push(from_unsigned_cell((cell)quot->code() + quot->code()->size()));
}

/* Allocates memory */
fixnum factor_vm::quot_code_offset_to_scan(cell quot_, cell offset)
{
	data_root<quotation> quot(quot_,this);
	data_root<array> array(quot->array,this);

	quotation_jit compiler(quot.value(),false,false,this);
	compiler.init_quotation(quot.value());
	compiler.compute_position(offset);
	compiler.iterate_quotation();

	return compiler.get_position();
}

cell factor_vm::lazy_jit_compile(cell quot_)
{
	data_root<quotation> quot(quot_,this);

	FACTOR_ASSERT(!quot_compiled_p(quot.untagged()));

	code_block *compiled = jit_compile_quot(quot.value(),quot.value(),true);
	quot.untagged()->entry_point = compiled->entry_point();

	return quot.value();
}

VM_C_API cell lazy_jit_compile(cell quot, factor_vm *parent)
{
	return parent->lazy_jit_compile(quot);
}

bool factor_vm::quot_compiled_p(quotation *quot)
{
	return quot->entry_point != NULL && quot->entry_point != lazy_jit_compile_entry_point();
}

void factor_vm::primitive_quot_compiled_p()
{
	tagged<quotation> quot(ctx->pop());
	quot.untag_check(this);
	ctx->push(tag_boolean(quot_compiled_p(quot.untagged())));
}

cell factor_vm::find_all_quotations()
{
	return instances(QUOTATION_TYPE);
}

void factor_vm::initialize_all_quotations()
{
	data_root<array> quotations(find_all_quotations(),this);

	cell length = array_capacity(quotations.untagged());
	for(cell i = 0; i < length; i++)
	{
		data_root<quotation> quot(array_nth(quotations.untagged(),i),this);
		if(!quot->entry_point)
			quot.untagged()->entry_point = lazy_jit_compile_entry_point();
	}
}

}
