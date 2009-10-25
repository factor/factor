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
		if(obj->free_p() || obj->h.hi_tag() != TUPLE_TYPE)
			return obj->size();
		else
			return align(tuple_size_with_forwarding(forwarding_map,obj),data_alignment);
	}
};

struct object_compaction_updater {
	factor_vm *parent;
	slot_visitor<object_slot_forwarder> slot_forwarder;
	code_block_visitor<code_block_forwarder> code_forwarder;
	mark_bits<object> *data_forwarding_map;

	explicit object_compaction_updater(factor_vm *parent_,
		slot_visitor<object_slot_forwarder> slot_forwarder_,
		code_block_visitor<code_block_forwarder> code_forwarder_,
		mark_bits<object> *data_forwarding_map_) :
		parent(parent_),
		slot_forwarder(slot_forwarder_),
		code_forwarder(code_forwarder_),
		data_forwarding_map(data_forwarding_map_) {}

	void operator()(object *obj, cell size)
	{
		cell payload_start;
		if(obj->h.hi_tag() == TUPLE_TYPE)
			payload_start = tuple_size_with_forwarding(data_forwarding_map,obj);
		else
			payload_start = obj->binary_payload_start();

		slot_forwarder.visit_slots(obj,payload_start);
		code_forwarder.visit_object_code_block(obj);
	}
};

struct code_block_compaction_updater {
	factor_vm *parent;
	slot_visitor<object_slot_forwarder> slot_forwarder;

	explicit code_block_compaction_updater(factor_vm *parent_, slot_visitor<object_slot_forwarder> slot_forwarder_) :
		parent(parent_), slot_forwarder(slot_forwarder_) {}

	void operator()(code_block *compiled, cell size)
	{
		slot_forwarder.visit_literal_references(compiled);
		parent->relocate_code_block(compiled);
	}
};

void factor_vm::compact_full_impl(bool trace_contexts_p)
{
	tenured_space *tenured = data->tenured;
	mark_bits<object> *data_forwarding_map = &tenured->state;
	mark_bits<code_block> *code_forwarding_map = &code->allocator->state;

	/* Figure out where blocks are going to go */
	data_forwarding_map->compute_forwarding();
	code_forwarding_map->compute_forwarding();

	/* Update root pointers */
	slot_visitor<object_slot_forwarder> slot_forwarder(this,object_slot_forwarder(data_forwarding_map));
	code_block_visitor<code_block_forwarder> code_forwarder(this,code_block_forwarder(code_forwarding_map));

	slot_forwarder.visit_roots();
	if(trace_contexts_p)
	{
		slot_forwarder.visit_contexts();
		code_forwarder.visit_context_code_blocks();
		code_forwarder.visit_callback_code_blocks();
	}

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
}

}
