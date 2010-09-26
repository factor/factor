#include "master.hpp"

namespace factor
{

code_heap::code_heap(cell size)
{
	if(size > ((u64)1 << (sizeof(cell) * 8 - 6))) fatal_error("Heap too large",size);
	seg = new segment(align_page(size),true);
	if(!seg) fatal_error("Out of memory in code_heap constructor",size);

	cell start = seg->start + seh_area_size;

	allocator = new free_list_allocator<code_block>(seg->end - start,start);

	/* See os-windows-x86.64.cpp for seh_area usage */
	seh_area = (char *)seg->start;
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

bool code_heap::uninitialized_p(code_block *compiled)
{
	return uninitialized_blocks.count(compiled) > 0;
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

void code_heap::free(code_block *compiled)
{
	assert(!uninitialized_p(compiled));
	points_to_nursery.erase(compiled);
	points_to_aging.erase(compiled);
	allocator->free(compiled);
}

void code_heap::flush_icache()
{
	factor::flush_icache(seg->start,seg->size);
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

struct word_updater {
	factor_vm *parent;
	bool reset_inline_caches;

	word_updater(factor_vm *parent_, bool reset_inline_caches_) :
		parent(parent_), reset_inline_caches(reset_inline_caches_) {}

	void operator()(code_block *compiled, cell size)
	{
		parent->update_word_references(compiled,reset_inline_caches);
	}
};

/* Update pointers to words referenced from all code blocks.
Only needed after redefining an existing word.
If generic words were redefined, inline caches need to be reset. */
void factor_vm::update_code_heap_words(bool reset_inline_caches)
{
	word_updater updater(this,reset_inline_caches);
	each_code_block(updater);
}

/* Fix up new words only.
Fast path for compilation units that only define new words. */
void factor_vm::initialize_code_blocks()
{
	std::map<code_block *, cell>::const_iterator iter = code->uninitialized_blocks.begin();
	std::map<code_block *, cell>::const_iterator end = code->uninitialized_blocks.end();

	for(; iter != end; iter++)
		initialize_code_block(iter->first,iter->second);

	code->uninitialized_blocks.clear();
}

void factor_vm::primitive_modify_code_heap()
{
	bool reset_inline_caches = to_boolean(ctx->pop());
	bool update_existing_words = to_boolean(ctx->pop());
	data_root<array> alist(ctx->pop(),this);

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
				cell parameters = array_nth(compiled_data,0);
				cell literals = array_nth(compiled_data,1);
				cell relocation = array_nth(compiled_data,2);
				cell labels = array_nth(compiled_data,3);
				cell code = array_nth(compiled_data,4);

				code_block *compiled = add_code_block(
					code_block_optimized,
					code,
					labels,
					word.value(),
					relocation,
					parameters,
					literals);

				word->code = compiled;
			}
			break;
		default:
			critical_error("Expected a quotation or an array",data.value());
			break;
		}

		update_word_entry_point(word.untagged());
	}

	if(update_existing_words)
		update_code_heap_words(reset_inline_caches);
	else
		initialize_code_blocks();
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
	ctx->push(tag<byte_array>(byte_array_from_value(&room)));
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
	each_code_block(stripper);
}

struct code_block_accumulator {
	std::vector<cell> objects;

	void operator()(code_block *compiled, cell size)
	{
		objects.push_back(compiled->owner);
		objects.push_back(compiled->parameters);
		objects.push_back(compiled->relocation);

		objects.push_back(tag_fixnum(compiled->type()));
		objects.push_back(tag_fixnum(compiled->size()));

		/* Note: the entry point is always a multiple of the heap
		alignment (16 bytes). We cannot allocate while iterating
		through the code heap, so it is not possible to call
		from_unsigned_cell() here. It is OK, however, to add it as
		if it were a fixnum, and have library code shift it to the
		left by 4. */
		cell entry_point = (cell)compiled->entry_point();
		assert((entry_point & (data_alignment - 1)) == 0);
		assert((entry_point & TAG_MASK) == FIXNUM_TYPE);
		objects.push_back(entry_point);
	}
};

cell factor_vm::code_blocks()
{
	code_block_accumulator accum;
	each_code_block(accum);
	return std_vector_to_array(accum.objects);
}

void factor_vm::primitive_code_blocks()
{
	ctx->push(code_blocks());
}

}
