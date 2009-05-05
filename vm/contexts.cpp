#include "master.hpp"

factor::context *stack_chain;

namespace factor
{

cell ds_size, rs_size;
context *unused_contexts;

void reset_datastack()
{
	ds = ds_bot - sizeof(cell);
}

void reset_retainstack()
{
	rs = rs_bot - sizeof(cell);
}

#define RESERVED (64 * sizeof(cell))

void fix_stacks()
{
	if(ds + sizeof(cell) < ds_bot || ds + RESERVED >= ds_top) reset_datastack();
	if(rs + sizeof(cell) < rs_bot || rs + RESERVED >= rs_top) reset_retainstack();
}

/* called before entry into foreign C code. Note that ds and rs might
be stored in registers, so callbacks must save and restore the correct values */
void save_stacks()
{
	if(stack_chain)
	{
		stack_chain->datastack = ds;
		stack_chain->retainstack = rs;
	}
}

context *alloc_context()
{
	context *new_context;

	if(unused_contexts)
	{
		new_context = unused_contexts;
		unused_contexts = unused_contexts->next;
	}
	else
	{
		new_context = (context *)safe_malloc(sizeof(context));
		new_context->datastack_region = alloc_segment(ds_size);
		new_context->retainstack_region = alloc_segment(rs_size);
	}

	return new_context;
}

void dealloc_context(context *old_context)
{
	old_context->next = unused_contexts;
	unused_contexts = old_context;
}

/* called on entry into a compiled callback */
void nest_stacks()
{
	context *new_context = alloc_context();

	new_context->callstack_bottom = (stack_frame *)-1;
	new_context->callstack_top = (stack_frame *)-1;

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
	new_context->datastack_save = ds;
	new_context->retainstack_save = rs;

	/* save per-callback userenv */
	new_context->current_callback_save = userenv[CURRENT_CALLBACK_ENV];
	new_context->catchstack_save = userenv[CATCHSTACK_ENV];

	new_context->next = stack_chain;
	stack_chain = new_context;

	reset_datastack();
	reset_retainstack();
}

/* called when leaving a compiled callback */
void unnest_stacks()
{
	ds = stack_chain->datastack_save;
	rs = stack_chain->retainstack_save;

	/* restore per-callback userenv */
	userenv[CURRENT_CALLBACK_ENV] = stack_chain->current_callback_save;
	userenv[CATCHSTACK_ENV] = stack_chain->catchstack_save;

	context *old_stacks = stack_chain;
	stack_chain = old_stacks->next;
	dealloc_context(old_stacks);
}

/* called on startup */
void init_stacks(cell ds_size_, cell rs_size_)
{
	ds_size = ds_size_;
	rs_size = rs_size_;
	stack_chain = NULL;
	unused_contexts = NULL;
}

bool stack_to_array(cell bottom, cell top)
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

PRIMITIVE(datastack)
{
	if(!stack_to_array(ds_bot,ds))
		general_error(ERROR_DS_UNDERFLOW,F,F,NULL);
}

PRIMITIVE(retainstack)
{
	if(!stack_to_array(rs_bot,rs))
		general_error(ERROR_RS_UNDERFLOW,F,F,NULL);
}

/* returns pointer to top of stack */
cell array_to_stack(array *array, cell bottom)
{
	cell depth = array_capacity(array) * sizeof(cell);
	memcpy((void*)bottom,array + 1,depth);
	return bottom + depth - sizeof(cell);
}

PRIMITIVE(set_datastack)
{
	ds = array_to_stack(untag_check<array>(dpop()),ds_bot);
}

PRIMITIVE(set_retainstack)
{
	rs = array_to_stack(untag_check<array>(dpop()),rs_bot);
}

/* Used to implement call( */
PRIMITIVE(check_datastack)
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
