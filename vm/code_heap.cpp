#include "master.hpp"

namespace factor
{

code_heap::code_heap(bool secure_gc, cell size) : heap(secure_gc,size) {}

void code_heap::write_barrier(code_block *compiled)
{
	points_to_nursery.insert(compiled);
	points_to_aging.insert(compiled);
}

bool code_heap::needs_fixup_p(code_block *compiled)
{
	return needs_fixup.count(compiled) > 0;
}

void code_heap::code_heap_free(code_block *compiled)
{
	points_to_nursery.erase(compiled);
	points_to_aging.erase(compiled);
	needs_fixup.erase(compiled);
	heap_free(compiled);
}

/* Allocate a code heap during startup */
void factor_vm::init_code_heap(cell size)
{
	code = new code_heap(secure_gc,size);
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

struct word_updater {
	factor_vm *myvm;

	explicit word_updater(factor_vm *myvm_) : myvm(myvm_) {}
	void operator()(code_block *compiled)
	{
		myvm->update_word_references(compiled);
	}
};

/* Update pointers to words referenced from all code blocks. Only after
defining a new word. */
void factor_vm::update_code_heap_words()
{
	word_updater updater(this);
	iterate_code_heap(updater);
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
				cell owner = array_nth(compiled_data,0);
				cell literals = array_nth(compiled_data,1);
				cell relocation = array_nth(compiled_data,2);
				cell labels = array_nth(compiled_data,3);
				cell code = array_nth(compiled_data,4);

				code_block *compiled = add_code_block(
					WORD_TYPE,
					code,
					labels,
					owner,
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
	return (code_block *)code->forwarding[compiled];
}

struct xt_forwarder {
	factor_vm *myvm;

	explicit xt_forwarder(factor_vm *myvm_) : myvm(myvm_) {}

	void operator()(stack_frame *frame)
	{
		cell offset = (cell)FRAME_RETURN_ADDRESS(frame,myvm) - (cell)myvm->frame_code(frame);
		code_block *forwarded = myvm->forward_xt(myvm->frame_code(frame));
		frame->xt = forwarded->xt();
		FRAME_RETURN_ADDRESS(frame,myvm) = (void *)((cell)forwarded + offset);
	}
};

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
				xt_forwarder forwarder(this);
				iterate_callstack_object(stack,forwarder);
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
	/* Free all unreachable code blocks, don't trace contexts */
	garbage_collection(tenured_gen,false,false,0);

	/* Figure out where the code heap blocks are going to end up */
	cell size = code->compute_heap_forwarding();

	/* Update word and quotation code pointers */
	forward_object_xts();

	/* Actually perform the compaction */
	code->compact_heap();

	/* Update word and quotation XTs */
	fixup_object_xts();

	/* Now update the free list; there will be a single free block at
	the end */
	code->build_free_list(size);
}

struct stack_trace_stripper {
	explicit stack_trace_stripper() {}

	void operator()(code_block *compiled)
	{
		compiled->owner = F;
	}
};

void factor_vm::primitive_strip_stack_traces()
{
	stack_trace_stripper stripper;
	iterate_code_heap(stripper);
}

}
