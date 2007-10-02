#include "master.h"

void reset_datastack(void)
{
	ds = ds_bot - CELLS;
}

void reset_retainstack(void)
{
	rs = rs_bot - CELLS;
}

#define RESERVED (64 * CELLS)

void fix_stacks(void)
{
	if(ds + CELLS < ds_bot || ds + RESERVED >= ds_top) reset_datastack();
	if(rs + CELLS < rs_bot || rs + RESERVED >= rs_top) reset_retainstack();
}

/* called before entry into foreign C code. Note that ds and rs might
be stored in registers, so callbacks must save and restore the correct values */
void save_stacks(void)
{
	stack_chain->datastack = ds;
	stack_chain->retainstack = rs;
}

/* called on entry into a compiled callback */
void nest_stacks(void)
{
	F_CONTEXT *new_stacks = safe_malloc(sizeof(F_CONTEXT));

	new_stacks->callstack_bottom = (F_STACK_FRAME *)-1;
	new_stacks->callstack_top = (F_STACK_FRAME *)-1;

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
	new_stacks->datastack_save = ds;
	new_stacks->retainstack_save = rs;

	/* save per-callback userenv */
	new_stacks->current_callback_save = userenv[CURRENT_CALLBACK_ENV];
	new_stacks->catchstack_save = userenv[CATCHSTACK_ENV];

	new_stacks->datastack_region = alloc_segment(ds_size);
	new_stacks->retainstack_region = alloc_segment(rs_size);

	new_stacks->extra_roots = extra_roots;

	new_stacks->next = stack_chain;
	stack_chain = new_stacks;

	reset_datastack();
	reset_retainstack();
}

/* called when leaving a compiled callback */
void unnest_stacks(void)
{
	dealloc_segment(stack_chain->datastack_region);
	dealloc_segment(stack_chain->retainstack_region);

	ds = stack_chain->datastack_save;
	rs = stack_chain->retainstack_save;

	/* restore per-callback userenv */
	userenv[CURRENT_CALLBACK_ENV] = stack_chain->current_callback_save;
	userenv[CATCHSTACK_ENV] = stack_chain->catchstack_save;

	extra_roots = stack_chain->extra_roots;

	F_CONTEXT *old_stacks = stack_chain;
	stack_chain = old_stacks->next;
	free(old_stacks);
}

/* called on startup */
void init_stacks(CELL ds_size_, CELL rs_size_)
{
	ds_size = ds_size_;
	rs_size = rs_size_;
	stack_chain = NULL;
}

DEFINE_PRIMITIVE(drop)
{
	dpop();
}

DEFINE_PRIMITIVE(2drop)
{
	ds -= 2 * CELLS;
}

DEFINE_PRIMITIVE(3drop)
{
	ds -= 3 * CELLS;
}

DEFINE_PRIMITIVE(dup)
{
	dpush(dpeek());
}

DEFINE_PRIMITIVE(2dup)
{
	CELL top = dpeek();
	CELL next = get(ds - CELLS);
	ds += CELLS * 2;
	put(ds - CELLS,next);
	put(ds,top);
}

DEFINE_PRIMITIVE(3dup)
{
	CELL c1 = dpeek();
	CELL c2 = get(ds - CELLS);
	CELL c3 = get(ds - CELLS * 2);
	ds += CELLS * 3;
	put (ds,c1);
	put (ds - CELLS,c2);
	put (ds - CELLS * 2,c3);
}

DEFINE_PRIMITIVE(rot)
{
	CELL c1 = dpeek();
	CELL c2 = get(ds - CELLS);
	CELL c3 = get(ds - CELLS * 2);
	put(ds,c3);
	put(ds - CELLS,c1);
	put(ds - CELLS * 2,c2);
}

DEFINE_PRIMITIVE(_rot)
{
	CELL c1 = dpeek();
	CELL c2 = get(ds - CELLS);
	CELL c3 = get(ds - CELLS * 2);
	put(ds,c2);
	put(ds - CELLS,c3);
	put(ds - CELLS * 2,c1);
}

DEFINE_PRIMITIVE(dupd)
{
	CELL top = dpeek();
	CELL next = get(ds - CELLS);
	put(ds,next);
	put(ds - CELLS,next);
	dpush(top);
}

DEFINE_PRIMITIVE(swapd)
{
	CELL top = get(ds - CELLS);
	CELL next = get(ds - CELLS * 2);
	put(ds - CELLS,next);
	put(ds - CELLS * 2,top);
}

DEFINE_PRIMITIVE(nip)
{
	CELL top = dpop();
	drepl(top);
}

DEFINE_PRIMITIVE(2nip)
{
	CELL top = dpeek();
	ds -= CELLS * 2;
	drepl(top);
}

DEFINE_PRIMITIVE(tuck)
{
	CELL top = dpeek();
	CELL next = get(ds - CELLS);
	put(ds,next);
	put(ds - CELLS,top);
	dpush(top);
}

DEFINE_PRIMITIVE(over)
{
	dpush(get(ds - CELLS));
}

DEFINE_PRIMITIVE(pick)
{
	dpush(get(ds - CELLS * 2));
}

DEFINE_PRIMITIVE(swap)
{
	CELL top = dpeek();
	CELL next = get(ds - CELLS);
	put(ds,next);
	put(ds - CELLS,top);
}

DEFINE_PRIMITIVE(to_r)
{
	rpush(dpop());
}

DEFINE_PRIMITIVE(from_r)
{
	dpush(rpop());
}

void stack_to_array(CELL bottom, CELL top)
{
	F_FIXNUM depth = (F_FIXNUM)(top - bottom + CELLS);

	if(depth < 0) critical_error("depth < 0",0);

	F_ARRAY *a = allot_array_internal(ARRAY_TYPE,depth / CELLS);
	memcpy(a + 1,(void*)bottom,depth);
	dpush(tag_object(a));
}

DEFINE_PRIMITIVE(datastack)
{
	stack_to_array(ds_bot,ds);
}

DEFINE_PRIMITIVE(retainstack)
{
	stack_to_array(rs_bot,rs);
}

/* returns pointer to top of stack */
CELL array_to_stack(F_ARRAY *array, CELL bottom)
{
	CELL depth = array_capacity(array) * CELLS;
	memcpy((void*)bottom,array + 1,depth);
	return bottom + depth - CELLS;
}

DEFINE_PRIMITIVE(set_datastack)
{
	ds = array_to_stack(untag_array(dpop()),ds_bot);
}

DEFINE_PRIMITIVE(set_retainstack)
{
	rs = array_to_stack(untag_array(dpop()),rs_bot);
}

XT default_word_xt(F_WORD *word)
{
	if(word->def == T)
		return dosym;
	else if(type_of(word->def) == QUOTATION_TYPE)
	{
		if(profiling)
			return docol_profiling;
		else
			return docol;
	}
	else if(type_of(word->def) == FIXNUM_TYPE)
		return primitives[to_fixnum(word->def)];
	else
		return undefined;
}

DEFINE_PRIMITIVE(getenv)
{
	F_FIXNUM e = untag_fixnum_fast(dpeek());
	drepl(userenv[e]);
}

DEFINE_PRIMITIVE(setenv)
{
	F_FIXNUM e = untag_fixnum_fast(dpop());
	CELL value = dpop();
	userenv[e] = value;
}

DEFINE_PRIMITIVE(exit)
{
	exit(to_fixnum(dpop()));
}

DEFINE_PRIMITIVE(os_env)
{
	char *name = unbox_char_string();
	char *value = getenv(name);
	if(value == NULL)
		dpush(F);
	else
		box_char_string(value);
}

DEFINE_PRIMITIVE(eq)
{
	CELL lhs = dpop();
	CELL rhs = dpeek();
	drepl((lhs == rhs) ? T : F);
}

DEFINE_PRIMITIVE(millis)
{
	box_unsigned_8(current_millis());
}

DEFINE_PRIMITIVE(sleep)
{
	sleep_millis(to_cell(dpop()));
}

DEFINE_PRIMITIVE(type)
{
	drepl(tag_fixnum(type_of(dpeek())));
}

DEFINE_PRIMITIVE(tag)
{
	drepl(tag_fixnum(TAG(dpeek())));
}

DEFINE_PRIMITIVE(class_hash)
{
	CELL obj = dpeek();
	CELL tag = TAG(obj);
	if(tag == TUPLE_TYPE)
	{
		F_WORD *class = untag_object(get(SLOT(obj,2)));
		drepl(class->hashcode);
	}
	else if(tag == OBJECT_TYPE)
		drepl(get(UNTAG(obj)));
	else
		drepl(tag_fixnum(tag));
}

DEFINE_PRIMITIVE(slot)
{
	F_FIXNUM slot = untag_fixnum_fast(dpop());
	CELL obj = dpop();
	dpush(get(SLOT(obj,slot)));
}

DEFINE_PRIMITIVE(set_slot)
{
	F_FIXNUM slot = untag_fixnum_fast(dpop());
	CELL obj = dpop();
	CELL value = dpop();
	set_slot(obj,slot,value);
}

void enable_word_profiling(F_WORD *word)
{
	if(word->xt == docol)
		word->xt = docol_profiling;
}

void disable_word_profiling(F_WORD *word)
{
	if(word->xt == docol_profiling)
		word->xt = docol;
}

DEFINE_PRIMITIVE(profiling)
{
	profiling = to_boolean(dpop());

	begin_scan();

	CELL obj;
	while((obj = next_object()) != F)
	{
		if(type_of(obj) == WORD_TYPE)
		{
			if(profiling)
				enable_word_profiling(untag_object(obj));
			else
				disable_word_profiling(untag_object(obj));
		}
	}

	gc_off = false; /* end heap scan */
}
