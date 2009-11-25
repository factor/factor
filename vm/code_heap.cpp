#include "master.hpp"

namespace factor
{

code_heap::code_heap(cell size)
{
	if(size > (1L << (sizeof(cell) * 8 - 6))) fatal_error("Heap too large",size);
	seg = new segment(align_page(size),true);
	if(!seg) fatal_error("Out of memory in heap allocator",size);
	allocator = new free_list_allocator<code_block>(size,seg->start);
}

code_heap::~code_heap()
{
	delete allocator;
	allocator = NULL;
	delete seg;
	seg = NULL;
}

void code_heap::write_barrier(code_block *compiled)
{
	points_to_nursery.insert(compiled);
	points_to_aging.insert(compiled);
}

void code_heap::clear_remembered_set()
{
	points_to_nursery.clear();
	points_to_aging.clear();
}

bool code_heap::needs_fixup_p(code_block *compiled)
{
	return needs_fixup.count(compiled) > 0;
}

bool code_heap::marked_p(code_block *compiled)
{
	return allocator->state.marked_p(compiled);
}

void code_heap::set_marked_p(code_block *compiled)
{
	allocator->state.set_marked_p(compiled);
}

void code_heap::clear_mark_bits()
{
	allocator->state.clear_mark_bits();
}

void code_heap::code_heap_free(code_block *compiled)
{
	points_to_nursery.erase(compiled);
	points_to_aging.erase(compiled);
	needs_fixup.erase(compiled);
	allocator->free(compiled);
}

/* Allocate a code heap during startup */
void factor_vm::init_code_heap(cell size)
{
	code = new code_heap(size);
}

bool factor_vm::in_code_heap_p(cell ptr)
{
	return (ptr >= code->seg->start && ptr <= code->seg->end);
}

/* Compile a word definition with the non-optimizing compiler. Allocates memory */
void factor_vm::jit_compile_word(cell word_, cell def_, bool relocate)
{
	data_root<word> word(word_,this);
	data_root<quotation> def(def_,this);

	jit_compile(def.value(),relocate);

	word->code = def->code;

	if(to_boolean(word->pic_def)) jit_compile(word->pic_def,relocate);
	if(to_boolean(word->pic_tail_def)) jit_compile(word->pic_tail_def,relocate);
}

struct word_updater {
	factor_vm *parent;

	explicit word_updater(factor_vm *parent_) : parent(parent_) {}

	void operator()(code_block *compiled, cell size)
	{
		parent->update_word_references(compiled);
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
	data_root<array> alist(dpop(),this);

	cell count = array_capacity(alist.untagged());

	if(count == 0)
		return;

	for(cell i = 0; i < count; i++)
	{
		data_root<array> pair(array_nth(alist.untagged(),i),this);

		data_root<word> word(array_nth(pair.untagged(),0),this);
		data_root<object> data(array_nth(pair.untagged(),1),this);

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
					code_block_optimized,
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

		update_word_xt(word.untagged());
	}

	update_code_heap_words();
}

code_heap_room factor_vm::code_room()
{
	code_heap_room room;

	room.size             = code->allocator->size;
	room.occupied_space   = code->allocator->occupied_space();
	room.total_free       = code->allocator->free_space();
	room.contiguous_free  = code->allocator->largest_free_block();
	room.free_block_count = code->allocator->free_block_count();

	return room;
}

void factor_vm::primitive_code_room()
{
	code_heap_room room = code_room();
	dpush(tag<byte_array>(byte_array_from_value(&room)));
}

struct stack_trace_stripper {
	explicit stack_trace_stripper() {}

	void operator()(code_block *compiled, cell size)
	{
		compiled->owner = false_object;
	}
};

void factor_vm::primitive_strip_stack_traces()
{
	stack_trace_stripper stripper;
	iterate_code_heap(stripper);
}

}
