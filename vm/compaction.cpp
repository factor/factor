#include "master.hpp"

namespace factor {

template<typename Block> struct forwarder {
	mark_bits<Block> *forwarding_map;

	explicit forwarder(mark_bits<Block> *forwarding_map_) :
		forwarding_map(forwarding_map_) {}

	Block *operator()(Block *block)
	{
		return forwarding_map->forward_block(block);
	}
};

static inline cell tuple_size_with_forwarding(mark_bits<object> *forwarding_map, object *obj)
{
	/* The tuple layout may or may not have been forwarded already. Tricky. */
	object *layout_obj = (object *)UNTAG(((tuple *)obj)->layout);
	tuple_layout *layout;

	if(layout_obj < obj)
	{
		/* It's already been moved up; dereference through forwarding
		map to get the size */
		layout = (tuple_layout *)forwarding_map->forward_block(layout_obj);
	}
	else
	{
		/* It hasn't been moved up yet; dereference directly */
		layout = (tuple_layout *)layout_obj;
	}

	return tuple_size(layout);
}

struct compaction_sizer {
	mark_bits<object> *forwarding_map;

	explicit compaction_sizer(mark_bits<object> *forwarding_map_) :
		forwarding_map(forwarding_map_) {}

	cell operator()(object *obj)
	{
		if(!forwarding_map->marked_p(obj))
			return forwarding_map->unmarked_block_size(obj);
		else if(obj->type() == TUPLE_TYPE)
			return align(tuple_size_with_forwarding(forwarding_map,obj),data_alignment);
		else
			return obj->size();
	}
};

struct object_compaction_updater {
	factor_vm *parent;
	mark_bits<code_block> *code_forwarding_map;
	mark_bits<object> *data_forwarding_map;
	object_start_map *starts;

	explicit object_compaction_updater(factor_vm *parent_,
		mark_bits<object> *data_forwarding_map_,
		mark_bits<code_block> *code_forwarding_map_) :
		parent(parent_),
		code_forwarding_map(code_forwarding_map_),
		data_forwarding_map(data_forwarding_map_),
		starts(&parent->data->tenured->starts) {}

	void operator()(object *old_address, object *new_address, cell size)
	{
		cell payload_start;
		if(old_address->type() == TUPLE_TYPE)
			payload_start = tuple_size_with_forwarding(data_forwarding_map,old_address);
		else
			payload_start = old_address->binary_payload_start();

		memmove(new_address,old_address,size);

		slot_visitor<forwarder<object> > slot_forwarder(parent,forwarder<object>(data_forwarding_map));
		slot_forwarder.visit_slots(new_address,payload_start);

		code_block_visitor<forwarder<code_block> > code_forwarder(parent,forwarder<code_block>(code_forwarding_map));
		code_forwarder.visit_object_code_block(new_address);

		starts->record_object_start_offset(new_address);
	}
};

template<typename SlotForwarder>
struct code_block_compaction_relocation_visitor {
	factor_vm *parent;
	code_block *old_address;
	slot_visitor<SlotForwarder> slot_forwarder;
	code_block_visitor<forwarder<code_block> > code_forwarder;

	explicit code_block_compaction_relocation_visitor(factor_vm *parent_,
		code_block *old_address_,
		slot_visitor<SlotForwarder> slot_forwarder_,
		code_block_visitor<forwarder<code_block> > code_forwarder_) :
		parent(parent_),
		old_address(old_address_),
		slot_forwarder(slot_forwarder_),
		code_forwarder(code_forwarder_) {}

	void operator()(instruction_operand op)
	{
		cell old_offset = op.rel_offset() + (cell)old_address->xt();

		switch(op.rel_type())
		{
		case RT_IMMEDIATE:
			op.store_value(slot_forwarder.visit_pointer(op.load_value(old_offset)));
			break;
		case RT_XT:
		case RT_XT_PIC:
		case RT_XT_PIC_TAIL:
			op.store_code_block(code_forwarder.visit_code_block(op.load_code_block(old_offset)));
			break;
		case RT_HERE:
			op.store_value(op.load_value(old_offset) - (cell)old_address + (cell)op.parent_code_block());
			break;
		case RT_THIS:
		case RT_CARDS_OFFSET:
		case RT_DECKS_OFFSET:
			parent->store_external_address(op);
			break;
		default:
			op.store_value(op.load_value(old_offset));
			break;
		}
	}
};

template<typename SlotForwarder>
struct code_block_compaction_updater {
	factor_vm *parent;
	slot_visitor<SlotForwarder> slot_forwarder;
	code_block_visitor<forwarder<code_block> > code_forwarder;

	explicit code_block_compaction_updater(factor_vm *parent_,
		slot_visitor<SlotForwarder> slot_forwarder_,
		code_block_visitor<forwarder<code_block> > code_forwarder_) :
		parent(parent_),
		slot_forwarder(slot_forwarder_),
		code_forwarder(code_forwarder_) {}

	void operator()(code_block *old_address, code_block *new_address, cell size)
	{
		memmove(new_address,old_address,size);

		slot_forwarder.visit_code_block_objects(new_address);

		code_block_compaction_relocation_visitor<SlotForwarder> visitor(parent,old_address,slot_forwarder,code_forwarder);
		new_address->each_instruction_operand(visitor);
	}
};

/* Compact data and code heaps */
void factor_vm::collect_compact_impl(bool trace_contexts_p)
{
	current_gc->event->started_compaction();

	tenured_space *tenured = data->tenured;
	mark_bits<object> *data_forwarding_map = &tenured->state;
	mark_bits<code_block> *code_forwarding_map = &code->allocator->state;

	/* Figure out where blocks are going to go */
	data_forwarding_map->compute_forwarding();
	code_forwarding_map->compute_forwarding();

	slot_visitor<forwarder<object> > slot_forwarder(this,forwarder<object>(data_forwarding_map));
	code_block_visitor<forwarder<code_block> > code_forwarder(this,forwarder<code_block>(code_forwarding_map));

	code_forwarder.visit_uninitialized_code_blocks();

	/* Object start offsets get recomputed by the object_compaction_updater */
	data->tenured->starts.clear_object_start_offsets();

	/* Slide everything in tenured space up, and update data and code heap
	pointers inside objects. */
	object_compaction_updater object_updater(this,data_forwarding_map,code_forwarding_map);
	compaction_sizer object_sizer(data_forwarding_map);
	tenured->compact(object_updater,object_sizer);

	/* Slide everything in the code heap up, and update data and code heap
	pointers inside code blocks. */
	code_block_compaction_updater<forwarder<object> > code_block_updater(this,slot_forwarder,code_forwarder);
	standard_sizer<code_block> code_block_sizer;
	code->allocator->compact(code_block_updater,code_block_sizer);

	slot_forwarder.visit_roots();
	if(trace_contexts_p)
	{
		slot_forwarder.visit_contexts();
		code_forwarder.visit_context_code_blocks();
	}

	update_code_roots_for_compaction();
	callbacks->update();

	current_gc->event->ended_compaction();
}

struct object_grow_heap_updater {
	code_block_visitor<forwarder<code_block> > code_forwarder;

	explicit object_grow_heap_updater(code_block_visitor<forwarder<code_block> > code_forwarder_) :
		code_forwarder(code_forwarder_) {}

	void operator()(object *obj)
	{
		code_forwarder.visit_object_code_block(obj);
	}
};

struct dummy_slot_forwarder {
	object *operator()(object *obj) { return obj; }
};

/* Compact just the code heap, after growing the data heap */
void factor_vm::collect_compact_code_impl(bool trace_contexts_p)
{
	/* Figure out where blocks are going to go */
	mark_bits<code_block> *code_forwarding_map = &code->allocator->state;
	code_forwarding_map->compute_forwarding();

	slot_visitor<dummy_slot_forwarder> slot_forwarder(this,dummy_slot_forwarder());
	code_block_visitor<forwarder<code_block> > code_forwarder(this,forwarder<code_block>(code_forwarding_map));

	code_forwarder.visit_uninitialized_code_blocks();

	if(trace_contexts_p)
		code_forwarder.visit_context_code_blocks();

	/* Update code heap references in data heap */
	object_grow_heap_updater updater(code_forwarder);
	each_object(updater);

	/* Slide everything in the code heap up, and update code heap
	pointers inside code blocks. */
	code_block_compaction_updater<dummy_slot_forwarder> code_block_updater(this,slot_forwarder,code_forwarder);
	standard_sizer<code_block> code_block_sizer;
	code->allocator->compact(code_block_updater,code_block_sizer);

	update_code_roots_for_compaction();
	callbacks->update();
}

void factor_vm::collect_compact(bool trace_contexts_p)
{
	collect_mark_impl(trace_contexts_p);
	collect_compact_impl(trace_contexts_p);
	code->flush_icache();
}

void factor_vm::collect_growing_heap(cell requested_bytes, bool trace_contexts_p)
{
	/* Grow the data heap and copy all live objects to the new heap. */
	data_heap *old = data;
	set_data_heap(data->grow(requested_bytes));
	collect_mark_impl(trace_contexts_p);
	collect_compact_code_impl(trace_contexts_p);
	code->flush_icache();
	delete old;
}

}
