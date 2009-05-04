#include "master.hpp"

namespace factor
{

heap code;

/* Allocate a code heap during startup */
void init_code_heap(cell size)
{
	new_heap(&code,size);
}

bool in_code_heap_p(cell ptr)
{
	return (ptr >= code.seg->start && ptr <= code.seg->end);
}

/* Compile a word definition with the non-optimizing compiler. Allocates memory */
void jit_compile_word(cell word_, cell def_, bool relocate)
{
	gc_root<word> word(word_);
	gc_root<quotation> def(def_);

	jit_compile(def.value(),relocate);

	word->code = def->code;

	if(word->direct_entry_def != F)
		jit_compile(word->direct_entry_def,relocate);
}

/* Apply a function to every code block */
void iterate_code_heap(code_heap_iterator iter)
{
	heap_block *scan = first_block(&code);

	while(scan)
	{
		if(scan->status != B_FREE)
			iter((code_block *)scan);
		scan = next_block(&code,scan);
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
	gc_root<array> alist(dpop());

	cell count = array_capacity(alist.untagged());

	if(count == 0)
		return;

	cell i;
	for(i = 0; i < count; i++)
	{
		gc_root<array> pair(array_nth(alist.untagged(),i));

		gc_root<word> word(array_nth(pair.untagged(),0));
		gc_root<object> data(array_nth(pair.untagged(),1));

		switch(data.type())
		{
		case QUOTATION_TYPE:
			jit_compile_word(word.value(),data.value(),false);
			break;
		case ARRAY_TYPE:
			{
				array *compiled_data = data.as<array>().untagged();
				cell literals = array_nth(compiled_data,0);
				cell relocation = array_nth(compiled_data,1);
				cell labels = array_nth(compiled_data,2);
				cell code = array_nth(compiled_data,3);

				code_block *compiled = add_code_block(
					WORD_TYPE,
					code,
					labels,
					relocation,
					literals);

				word->code = compiled;
			}
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
	cell used, total_free, max_free;
	heap_usage(&code,&used,&total_free,&max_free);
	dpush(tag_fixnum(code.seg->size / 1024));
	dpush(tag_fixnum(used / 1024));
	dpush(tag_fixnum(total_free / 1024));
	dpush(tag_fixnum(max_free / 1024));
}

code_block *forward_xt(code_block *compiled)
{
	return (code_block *)compiled->block.forwarding;
}

void forward_frame_xt(stack_frame *frame)
{
	cell offset = (cell)FRAME_RETURN_ADDRESS(frame) - (cell)frame_code(frame);
	code_block *forwarded = forward_xt(frame_code(frame));
	frame->xt = forwarded->xt();
	FRAME_RETURN_ADDRESS(frame) = (void *)((cell)forwarded + offset);
}

void forward_object_xts(void)
{
	begin_scan();

	cell obj;

	while((obj = next_object()) != F)
	{
		switch(tagged<object>(obj).type())
		{
		case WORD_TYPE:
			{
				word *w = untag<word>(obj);

				if(w->code)
					w->code = forward_xt(w->code);
				if(w->profiling)
					w->profiling = forward_xt(w->profiling);
			}
			break;
		case QUOTATION_TYPE:
			{
				quotation *quot = untag<quotation>(obj);

				if(quot->compiledp != F)
					quot->code = forward_xt(quot->code);
			}
			break;
		case CALLSTACK_TYPE:
			{
				callstack *stack = untag<callstack>(obj);
				iterate_callstack_object(stack,forward_frame_xt);
			}
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

	cell obj;

	while((obj = next_object()) != F)
	{
		switch(tagged<object>(obj).type())
		{
		case WORD_TYPE:
			update_word_xt(obj);
			break;
		case QUOTATION_TYPE:
			{
				quotation *quot = untag<quotation>(obj);
				if(quot->compiledp != F)
					set_quot_xt(quot,quot->code);
				break;
			}
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
	cell size = compute_heap_forwarding(&code);

	/* Update word and quotation code pointers */
	forward_object_xts();

	/* Actually perform the compaction */
	compact_heap(&code);

	/* Update word and quotation XTs */
	fixup_object_xts();

	/* Now update the free list; there will be a single free block at
	the end */
	build_free_list(&code,size);
}

}
