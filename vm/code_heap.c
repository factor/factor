#include "master.h"

/* Allocate a code heap during startup */
void init_code_heap(CELL size)
{
	new_heap(&code_heap,size);
}

bool in_code_heap_p(CELL ptr)
{
	return (ptr >= code_heap.segment->start
		&& ptr <= code_heap.segment->end);
}

void set_word_code(F_WORD *word, F_CODE_BLOCK *compiled)
{
	if(compiled->block.type != WORD_TYPE)
		critical_error("bad param to set_word_xt",(CELL)compiled);

	word->code = compiled;
	word->optimizedp = T;
}

/* Compile a word definition with the non-optimizing compiler. Allocates memory */
void jit_compile_word(F_WORD *word, CELL def, bool relocate)
{
	REGISTER_ROOT(def);
	REGISTER_UNTAGGED(word);
	jit_compile(def,relocate);
	UNREGISTER_UNTAGGED(word);
	UNREGISTER_ROOT(def);

	word->code = untag_quotation(def)->code;
	word->optimizedp = F;
}

/* Apply a function to every code block */
void iterate_code_heap(CODE_HEAP_ITERATOR iter)
{
	F_BLOCK *scan = first_block(&code_heap);

	while(scan)
	{
		if(scan->status != B_FREE)
			iter((F_CODE_BLOCK *)scan);
		scan = next_block(&code_heap,scan);
	}
}

/* Copy literals referenced from all code blocks to newspace. Only for
aging and nursery collections */
void copy_code_heap_roots(void)
{
	iterate_code_heap(copy_literal_references);
}

/* Update literals referenced from all code blocks. Only for tenured
collections, done at the end. */
void update_code_heap_roots(void)
{
	iterate_code_heap(update_literal_references);
}

/* Update pointers to words referenced from all code blocks. Only after
defining a new word. */
void update_code_heap_words(void)
{
	iterate_code_heap(update_word_references);
}

void primitive_modify_code_heap(void)
{
	F_ARRAY *alist = untag_array(dpop());

	CELL count = untag_fixnum_fast(alist->capacity);
	if(count == 0)
		return;

	CELL i;
	for(i = 0; i < count; i++)
	{
		F_ARRAY *pair = untag_array(array_nth(alist,i));

		F_WORD *word = untag_word(array_nth(pair,0));

		CELL data = array_nth(pair,1);

		if(type_of(data) == QUOTATION_TYPE)
		{
			REGISTER_UNTAGGED(alist);
			REGISTER_UNTAGGED(word);
			jit_compile_word(word,data,false);
			UNREGISTER_UNTAGGED(word);
			UNREGISTER_UNTAGGED(alist);
		}
		else if(type_of(data) == ARRAY_TYPE)
		{
			F_ARRAY *compiled_code = untag_array(data);

			F_ARRAY *literals = untag_array(array_nth(compiled_code,0));
			CELL relocation = array_nth(compiled_code,1);
			F_ARRAY *labels = untag_array(array_nth(compiled_code,2));
			F_ARRAY *code = untag_array(array_nth(compiled_code,3));

			REGISTER_UNTAGGED(alist);
			REGISTER_UNTAGGED(word);

			F_CODE_BLOCK *compiled = add_code_block(
				WORD_TYPE,
				code,
				labels,
				relocation,
				tag_object(literals));

			UNREGISTER_UNTAGGED(word);
			UNREGISTER_UNTAGGED(alist);

			set_word_code(word,compiled);
		}
		else
			critical_error("Expected a quotation or an array",data);

		REGISTER_UNTAGGED(alist);
		update_word_xt(word);
		UNREGISTER_UNTAGGED(alist);
	}

	update_code_heap_words();
}

/* Push the free space and total size of the code heap */
void primitive_code_room(void)
{
	CELL used, total_free, max_free;
	heap_usage(&code_heap,&used,&total_free,&max_free);
	dpush(tag_fixnum((code_heap.segment->size) / 1024));
	dpush(tag_fixnum(used / 1024));
	dpush(tag_fixnum(total_free / 1024));
	dpush(tag_fixnum(max_free / 1024));
}

F_CODE_BLOCK *forward_xt(F_CODE_BLOCK *compiled)
{
	return (F_CODE_BLOCK *)compiled->block.forwarding;
}

void forward_frame_xt(F_STACK_FRAME *frame)
{
	CELL offset = (CELL)FRAME_RETURN_ADDRESS(frame) - (CELL)frame_code(frame);
	F_CODE_BLOCK *forwarded = forward_xt(frame_code(frame));
	frame->xt = (XT)(forwarded + 1);
	FRAME_RETURN_ADDRESS(frame) = (XT)((CELL)forwarded + offset);
}

void forward_object_xts(void)
{
	begin_scan();

	CELL obj;

	while((obj = next_object()) != F)
	{
		if(type_of(obj) == WORD_TYPE)
		{
			F_WORD *word = untag_object(obj);

			word->code = forward_xt(word->code);
			if(word->profiling)
				word->profiling = forward_xt(word->profiling);
		}
		else if(type_of(obj) == QUOTATION_TYPE)
		{
			F_QUOTATION *quot = untag_object(obj);

			if(quot->compiledp != F)
				quot->code = forward_xt(quot->code);
		}
		else if(type_of(obj) == CALLSTACK_TYPE)
		{
			F_CALLSTACK *stack = untag_object(obj);
			iterate_callstack_object(stack,forward_frame_xt);
		}
	}

	/* End the heap scan */
	gc_off = false;
}

/* Set the XT fields now that the heap has been compacted */
void fixup_object_xts(void)
{
	begin_scan();

	CELL obj;

	while((obj = next_object()) != F)
	{
		if(type_of(obj) == WORD_TYPE)
		{
			F_WORD *word = untag_object(obj);
			update_word_xt(word);
		}
		else if(type_of(obj) == QUOTATION_TYPE)
		{
			F_QUOTATION *quot = untag_object(obj);

			if(quot->compiledp != F)
				set_quot_xt(quot,quot->code);
		}
	}

	/* End the heap scan */
	gc_off = false;
}

/* Move all free space to the end of the code heap. This is not very efficient,
since it makes several passes over the code and data heaps, but we only ever
do this before saving a deployed image and exiting, so performaance is not
critical here */
void compact_code_heap(void)
{
	/* Free all unreachable code blocks */
	gc();

	/* Figure out where the code heap blocks are going to end up */
	CELL size = compute_heap_forwarding(&code_heap);

	/* Update word and quotation code pointers */
	forward_object_xts();

	/* Actually perform the compaction */
	compact_heap(&code_heap);

	/* Update word and quotation XTs */
	fixup_object_xts();

	/* Now update the free list; there will be a single free block at
	the end */
	build_free_list(&code_heap,size);
}
