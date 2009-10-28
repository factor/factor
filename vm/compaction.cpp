#include "master.hpp"

namespace factor {

struct object_slot_forwarder {
	mark_bits<object> *forwarding_map;

	explicit object_slot_forwarder(mark_bits<object> *forwarding_map_) :
		forwarding_map(forwarding_map_) {}

	object *visit_object(object *obj)
	{
		return forwarding_map->forward_block(obj);
	}
};

struct code_block_forwarder {
	mark_bits<code_block> *forwarding_map;

	explicit code_block_forwarder(mark_bits<code_block> *forwarding_map_) :
		forwarding_map(forwarding_map_) {}

	code_block *operator()(code_block *compiled)
	{
		return forwarding_map->forward_block(compiled);
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
			return forwarding_map->unmarked_space_starting_at(obj);
		else if(obj->h.hi_tag() == TUPLE_TYPE)
			return align(tuple_size_with_forwarding(forwarding_map,obj),data_alignment);
		else
			return obj->size();
	}
};

struct object_compaction_updater {
	factor_vm *parent;
	slot_visitor<object_slot_forwarder> slot_forwarder;
	code_block_visitor<code_block_forwarder> code_forwarder;
	mark_bits<object> *data_forwarding_map;
	object_start_map *starts;

	explicit object_compaction_updater(factor_vm *parent_,
		slot_visitor<object_slot_forwarder> slot_forwarder_,
		code_block_visitor<code_block_forwarder> code_forwarder_,
		mark_bits<object> *data_forwarding_map_) :
		parent(parent_),
		slot_forwarder(slot_forwarder_),
		code_forwarder(code_forwarder_),
		data_forwarding_map(data_forwarding_map_),
		starts(&parent->data->tenured->starts) {}

	void operator()(object *old_address, object *new_address, cell size)
	{
		cell payload_start;
		if(old_address->h.hi_tag() == TUPLE_TYPE)
			payload_start = tuple_size_with_forwarding(data_forwarding_map,old_address);
		else
			payload_start = old_address->binary_payload_start();

		memmove(new_address,old_address,size);

		slot_forwarder.visit_slots(new_address,payload_start);
		code_forwarder.visit_object_code_block(new_address);
		starts->record_object_start_offset(new_address);
	}
};

struct code_block_compaction_updater {
	factor_vm *parent;
	slot_visitor<object_slot_forwarder> slot_forwarder;

	explicit code_block_compaction_updater(factor_vm *parent_, slot_visitor<object_slot_forwarder> slot_forwarder_) :
		parent(parent_), slot_forwarder(slot_forwarder_) {}

	void operator()(code_block *old_address, code_block *new_address, cell size)
	{
		memmove(new_address,old_address,size);
		slot_forwarder.visit_literal_references(new_address);
		parent->relocate_code_block(new_address);
	}
};

void factor_vm::collect_compact_impl(bool trace_contexts_p)
{
	current_gc->event->started_compaction();

	tenured_space *tenured = data->tenured;
	mark_bits<object> *data_forwarding_map = &tenured->state;
	mark_bits<code_block> *code_forwarding_map = &code->allocator->state;

	/* Figure out where blocks are going to go */
	data_forwarding_map->compute_forwarding();
	code_forwarding_map->compute_forwarding();

	/* Update root pointers */
	slot_visitor<object_slot_forwarder> slot_forwarder(this,object_slot_forwarder(data_forwarding_map));
	code_block_visitor<code_block_forwarder> code_forwarder(this,code_block_forwarder(code_forwarding_map));

	/* Object start offsets get recomputed by the object_compaction_updater */
	data->tenured->starts.clear_object_start_offsets();

	/* Slide everything in tenured space up, and update data and code heap
	pointers inside objects. */
	object_compaction_updater object_updater(this,slot_forwarder,code_forwarder,data_forwarding_map);
	compaction_sizer object_sizer(data_forwarding_map);
	tenured->compact(object_updater,object_sizer);

	/* Slide everything in the code heap up, and update data and code heap
	pointers inside code blocks. */
	code_block_compaction_updater code_block_updater(this,slot_forwarder);
	standard_sizer<code_block> code_block_sizer;
	code->allocator->compact(code_block_updater,code_block_sizer);

	slot_forwarder.visit_roots();
	if(trace_contexts_p)
	{
		slot_forwarder.visit_contexts();
		code_forwarder.visit_context_code_blocks();
		code_forwarder.visit_callback_code_blocks();
	}

	current_gc->event->ended_compaction();
}

}
