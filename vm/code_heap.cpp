#include "master.hpp"

namespace factor
{

/* Allocate a code heap during startup */
void factor_vm::init_code_heap(cell size)
{
	code = new heap(this,size);
}

bool factor_vm::in_code_heap_p(cell ptr)
{
	return (ptr >= code->seg->start && ptr <= code->seg->end);
}

/* Compile a word definition with the non-optimizing compiler. Allocates memory */
void factor_vm::jit_compile_word(cell word_, cell def_, bool relocate)
{
	gc_root<word> word(word_,this);
	gc_root<quotation> def(def_,this);

	jit_compile(def.value(),relocate);

	word->code = def->code;

	if(word->pic_def != F) jit_compile(word->pic_def,relocate);
	if(word->pic_tail_def != F) jit_compile(word->pic_tail_def,relocate);
}

/* Apply a function to every code block */
void factor_vm::iterate_code_heap(code_heap_iterator iter)
{
	heap_block *scan = code->first_block();

	while(scan)
	{
		if(scan->status != B_FREE)
			iter((code_block *)scan,this);
		scan = code->next_block(scan);
	}
}

/* Copy literals referenced from all code blocks to newspace. Only for
aging and nursery collections */
void factor_vm::copy_code_heap_roots()
{
	iterate_code_heap(factor::copy_literal_references);
}

/* Update pointers to words referenced from all code blocks. Only after
defining a new word. */
void factor_vm::update_code_heap_words()
{
	iterate_code_heap(factor::update_word_references);
}

void factor_vm::primitive_modify_code_heap()
{
	gc_root<array> alist(dpop(),this);

	cell count = array_capacity(alist.untagged());

	if(count == 0)
		return;

	cell i;
	for(i = 0; i < count; i++)
	{
		gc_root<array> pair(array_nth(alist.untagged(),i),this);

		gc_root<word> word(array_nth(pair.untagged(),0),this);
		gc_root<object> data(array_nth(pair.untagged(),1),this);

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
void factor_vm::primitive_code_room()
{
	cell used, total_free, max_free;
	code->heap_usage(&used,&total_free,&max_free);
	dpush(tag_fixnum(code->seg->size / 1024));
	dpush(tag_fixnum(used / 1024));
	dpush(tag_fixnum(total_free / 1024));
	dpush(tag_fixnum(max_free / 1024));
}

code_block *factor_vm::forward_xt(code_block *compiled)
{
	return (code_block *)forwarding[compiled];
}

void factor_vm::forward_frame_xt(stack_frame *frame)
{
	cell offset = (cell)FRAME_RETURN_ADDRESS(frame) - (cell)frame_code(frame);
	code_block *forwarded = forward_xt(frame_code(frame));
	frame->xt = forwarded->xt();
	FRAME_RETURN_ADDRESS(frame) = (void *)((cell)forwarded + offset);
}

void forward_frame_xt(stack_frame *frame,factor_vm *myvm)
{
	return myvm->forward_frame_xt(frame);
}

void factor_vm::forward_object_xts()
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

				if(quot->code)
					quot->code = forward_xt(quot->code);
			}
			break;
		case CALLSTACK_TYPE:
			{
				callstack *stack = untag<callstack>(obj);
				iterate_callstack_object(stack,factor::forward_frame_xt);
			}
			break;
		default:
			break;
		}
	}

	end_scan();
}

/* Set the XT fields now that the heap has been compacted */
void factor_vm::fixup_object_xts()
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
				if(quot->code)
					set_quot_xt(quot,quot->code);
				break;
			}
		default:
			break;
		}
	}

	end_scan();
}

/* Move all free space to the end of the code heap. This is not very efficient,
since it makes several passes over the code and data heaps, but we only ever
do this before saving a deployed image and exiting, so performaance is not
critical here */
void factor_vm::compact_code_heap()
{
	/* Free all unreachable code blocks */
	gc();

	/* Figure out where the code heap blocks are going to end up */
	cell size = code->compute_heap_forwarding(forwarding);

	/* Update word and quotation code pointers */
	forward_object_xts();

	/* Actually perform the compaction */
	code->compact_heap(forwarding);

	/* Update word and quotation XTs */
	fixup_object_xts();

	/* Now update the free list; there will be a single free block at
	the end */
	code->build_free_list(size);
}

}
