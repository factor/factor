#include "master.hpp"

namespace factor
{

void factor_vm::reset_datastack()
{
	ds = ds_bot - sizeof(cell);
}

void factor_vm::reset_retainstack()
{
	rs = rs_bot - sizeof(cell);
}

static const cell stack_reserved = (64 * sizeof(cell));

void factor_vm::fix_stacks()
{
	if(ds + sizeof(cell) < ds_bot || ds + stack_reserved >= ds_top) reset_datastack();
	if(rs + sizeof(cell) < rs_bot || rs + stack_reserved >= rs_top) reset_retainstack();
}

/* called before entry into foreign C code. Note that ds and rs might
be stored in registers, so callbacks must save and restore the correct values */
void factor_vm::save_stacks()
{
	if(ctx)
	{
		ctx->datastack = ds;
		ctx->retainstack = rs;
	}
}

context *factor_vm::alloc_context()
{
	context *new_context;

	if(unused_contexts)
	{
		new_context = unused_contexts;
		unused_contexts = unused_contexts->next;
	}
	else
	{
		new_context = new context;
		new_context->datastack_region = new segment(ds_size,false);
		new_context->retainstack_region = new segment(rs_size,false);
	}

	return new_context;
}

void factor_vm::dealloc_context(context *old_context)
{
	old_context->next = unused_contexts;
	unused_contexts = old_context;
}

/* called on entry into a compiled callback */
void factor_vm::nest_stacks(stack_frame *magic_frame)
{
	context *new_ctx = alloc_context();

	new_ctx->callstack_bottom = (stack_frame *)-1;
	new_ctx->callstack_top = (stack_frame *)-1;

	/* note that these register values are not necessarily valid stack
	pointers. they are merely saved non-volatile registers, and are
	restored in unnest_stacks(). consider this scenario:
	- factor code calls C function
	- C function saves ds/cs registers (since they're non-volatile)
	- C function clobbers them
	- C function calls Factor callback
	- Factor callback returns
	- C function restores registers
	- C function returns to Factor code */
	new_ctx->datastack_save = ds;
	new_ctx->retainstack_save = rs;

	new_ctx->magic_frame = magic_frame;

	/* save per-callback userenv */
	new_ctx->current_callback_save = userenv[CURRENT_CALLBACK_ENV];
	new_ctx->catchstack_save = userenv[CATCHSTACK_ENV];

	new_ctx->next = ctx;
	ctx = new_ctx;

	reset_datastack();
	reset_retainstack();
}

void nest_stacks(stack_frame *magic_frame, factor_vm *myvm)
{
	return myvm->nest_stacks(magic_frame);
}

/* called when leaving a compiled callback */
void factor_vm::unnest_stacks()
{
	ds = ctx->datastack_save;
	rs = ctx->retainstack_save;

	/* restore per-callback userenv */
	userenv[CURRENT_CALLBACK_ENV] = ctx->current_callback_save;
	userenv[CATCHSTACK_ENV] = ctx->catchstack_save;

	context *old_ctx = ctx;
	ctx = old_ctx->next;
	dealloc_context(old_ctx);
}

void unnest_stacks(factor_vm *myvm)
{
	return myvm->unnest_stacks();
}

/* called on startup */
void factor_vm::init_stacks(cell ds_size_, cell rs_size_)
{
	ds_size = ds_size_;
	rs_size = rs_size_;
	ctx = NULL;
	unused_contexts = NULL;
}

bool factor_vm::stack_to_array(cell bottom, cell top)
{
	fixnum depth = (fixnum)(top - bottom + sizeof(cell));

	if(depth < 0)
		return false;
	else
	{
		array *a = allot_array_internal<array>(depth / sizeof(cell));
		memcpy(a + 1,(void*)bottom,depth);
		dpush(tag<array>(a));
		return true;
	}
}

void factor_vm::primitive_datastack()
{
	if(!stack_to_array(ds_bot,ds))
		general_error(ERROR_DS_UNDERFLOW,F,F,NULL);
}

void factor_vm::primitive_retainstack()
{
	if(!stack_to_array(rs_bot,rs))
		general_error(ERROR_RS_UNDERFLOW,F,F,NULL);
}

/* returns pointer to top of stack */
cell factor_vm::array_to_stack(array *array, cell bottom)
{
	cell depth = array_capacity(array) * sizeof(cell);
	memcpy((void*)bottom,array + 1,depth);
	return bottom + depth - sizeof(cell);
}

void factor_vm::primitive_set_datastack()
{
	ds = array_to_stack(untag_check<array>(dpop()),ds_bot);
}

void factor_vm::primitive_set_retainstack()
{
	rs = array_to_stack(untag_check<array>(dpop()),rs_bot);
}

/* Used to implement call( */
void factor_vm::primitive_check_datastack()
{
	fixnum out = to_fixnum(dpop());
	fixnum in = to_fixnum(dpop());
	fixnum height = out - in;
	array *saved_datastack = untag_check<array>(dpop());
	fixnum saved_height = array_capacity(saved_datastack);
	fixnum current_height = (ds - ds_bot + sizeof(cell)) / sizeof(cell);
	if(current_height - height != saved_height)
		dpush(F);
	else
	{
		fixnum i;
		for(i = 0; i < saved_height - in; i++)
		{
			if(((cell *)ds_bot)[i] != array_nth(saved_datastack,i))
			{
				dpush(F);
				return;
			}
		}
		dpush(T);
	}
}

}
