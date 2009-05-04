#include "master.hpp"

namespace factor
{

F_HEAP code_heap;

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

/* Compile a word definition with the non-optimizing compiler. Allocates memory */
void jit_compile_word(CELL word_, CELL def_, bool relocate)
{
	gc_root<F_WORD> word(word_);
	gc_root<F_QUOTATION> def(def_);

	jit_compile(def.value(),relocate);

	word->code = def->code;

	if(word->direct_entry_def != F)
		jit_compile(word->direct_entry_def,relocate);
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

/* Update pointers to words referenced from all code blocks. Only after
defining a new word. */
void update_code_heap_words(void)
{
	iterate_code_heap(update_word_references);
}

PRIMITIVE(modify_code_heap)
{
	gc_root<F_ARRAY> alist(dpop());

	CELL count = array_capacity(alist.untagged());

	if(count == 0)
		return;

	CELL i;
	for(i = 0; i < count; i++)
	{
		gc_root<F_ARRAY> pair(array_nth(alist.untagged(),i));

		gc_root<F_WORD> word(array_nth(pair.untagged(),0));
		gc_root<F_OBJECT> data(array_nth(pair.untagged(),1));

		switch(data.type())
		{
		case QUOTATION_TYPE:
			jit_compile_word(word.value(),data.value(),false);
			break;
		case ARRAY_TYPE:
			F_ARRAY *compiled_data = data.as<F_ARRAY>().untagged();
			CELL literals = array_nth(compiled_data,0);
			CELL relocation = array_nth(compiled_data,1);
			CELL labels = array_nth(compiled_data,2);
			CELL code = array_nth(compiled_data,3);

			F_CODE_BLOCK *compiled = add_code_block(
				WORD_TYPE,
				code,
				labels,
				relocation,
				literals);

			word->code = compiled;
			break;
		default:
			critical_error("Expected a quotation or an array",data.value());
			break;
		}

		update_word_xt(word.value());
	}

	update_code_heap_words();
}

/* Push the free space and total size of the code heap */
PRIMITIVE(code_room)
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
		switch(tagged<F_OBJECT>(obj).type())
		{
		case WORD_TYPE:
			F_WORD *word = untag<F_WORD>(obj);

			word->code = forward_xt(word->code);
			if(word->profiling)
				word->profiling = forward_xt(word->profiling);
			
			break;
		case QUOTATION_TYPE:
			F_QUOTATION *quot = untag<F_QUOTATION>(obj);

			if(quot->compiledp != F)
				quot->code = forward_xt(quot->code);
			
			break;
		case CALLSTACK_TYPE:
			F_CALLSTACK *stack = untag<F_CALLSTACK>(obj);
			iterate_callstack_object(stack,forward_frame_xt);
			
			break;
		default:
			break;
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
		switch(tagged<F_OBJECT>(obj).type())
		{
		case WORD_TYPE:
			update_word_xt(obj);
			break;
		case QUOTATION_TYPE:
			F_QUOTATION *quot = untag<F_QUOTATION>(obj);
			if(quot->compiledp != F)
				set_quot_xt(quot,quot->code);
			break;
		default:
			break;
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

}
