#include "master.hpp"

namespace factor
{

context::context(cell ds_size, cell rs_size) :
	callstack_top(NULL),
	callstack_bottom(NULL),
	datastack(0),
	retainstack(0),
	magic_frame(NULL),
	datastack_region(new segment(ds_size,false)),
	retainstack_region(new segment(rs_size,false)),
	catchstack_save(0),
	current_callback_save(0),
	next(NULL)
{
	reset_datastack();
	reset_retainstack();
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
		new_context = new context(ds_size,rs_size);

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

	new_ctx->magic_frame = magic_frame;

	/* save per-callback special_objects */
	new_ctx->current_callback_save = special_objects[OBJ_CURRENT_CALLBACK];
	new_ctx->catchstack_save = special_objects[OBJ_CATCHSTACK];

	new_ctx->next = ctx;
	ctx = new_ctx;
}

void nest_stacks(stack_frame *magic_frame, factor_vm *parent)
{
	return parent->nest_stacks(magic_frame);
}

/* called when leaving a compiled callback */
void factor_vm::unnest_stacks()
{
	/* restore per-callback special_objects */
	special_objects[OBJ_CURRENT_CALLBACK] = ctx->current_callback_save;
	special_objects[OBJ_CATCHSTACK] = ctx->catchstack_save;

	context *old_ctx = ctx;
	ctx = old_ctx->next;
	dealloc_context(old_ctx);
}

void unnest_stacks(factor_vm *parent)
{
	return parent->unnest_stacks();
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
		array *a = allot_uninitialized_array<array>(depth / sizeof(cell));
		memcpy(a + 1,(void*)bottom,depth);
		ctx->push(tag<array>(a));
		return true;
	}
}

void factor_vm::primitive_datastack()
{
	if(!stack_to_array(ctx->datastack_region->start,ctx->datastack))
		general_error(ERROR_DS_UNDERFLOW,false_object,false_object,NULL);
}

void factor_vm::primitive_retainstack()
{
	if(!stack_to_array(ctx->retainstack_region->start,ctx->retainstack))
		general_error(ERROR_RS_UNDERFLOW,false_object,false_object,NULL);
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
	ctx->datastack = array_to_stack(untag_check<array>(ctx->pop()),ctx->datastack_region->start);
}

void factor_vm::primitive_set_retainstack()
{
	ctx->retainstack = array_to_stack(untag_check<array>(ctx->pop()),ctx->retainstack_region->start);
}

/* Used to implement call( */
void factor_vm::primitive_check_datastack()
{
	fixnum out = to_fixnum(ctx->pop());
	fixnum in = to_fixnum(ctx->pop());
	fixnum height = out - in;
	array *saved_datastack = untag_check<array>(ctx->pop());
	fixnum saved_height = array_capacity(saved_datastack);
	fixnum current_height = (ctx->datastack - ctx->datastack_region->start + sizeof(cell)) / sizeof(cell);
	if(current_height - height != saved_height)
		ctx->push(false_object);
	else
	{
		cell *ds_bot = (cell *)ctx->datastack_region->start;
		for(fixnum i = 0; i < saved_height - in; i++)
		{
			if(ds_bot[i] != array_nth(saved_datastack,i))
			{
				ctx->push(false_object);
				return;
			}
		}
		ctx->push(true_object);
	}
}

void factor_vm::primitive_load_locals()
{
	fixnum count = untag_fixnum(ctx->pop());
	memcpy((cell *)(ctx->retainstack + sizeof(cell)),
		(cell *)(ctx->datastack - sizeof(cell) * (count - 1)),
		sizeof(cell) * count);
	ctx->datastack -= sizeof(cell) * count;
	ctx->retainstack += sizeof(cell) * count;
}

}
