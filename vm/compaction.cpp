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
	mark_bits<heap_block> *forwarding_map;

	explicit code_block_forwarder(mark_bits<heap_block> *forwarding_map_) :
		forwarding_map(forwarding_map_) {}

	code_block *operator()(code_block *compiled)
	{
		return (code_block *)forwarding_map->forward_block(compiled);
	}
};

struct object_compaction_updater {
	factor_vm *parent;
	slot_visitor<object_slot_forwarder> slot_forwarder;
	code_block_visitor<code_block_forwarder> code_forwarder;

	explicit object_compaction_updater(factor_vm *parent_,
		slot_visitor<object_slot_forwarder> slot_forwader_,
		code_block_visitor<code_block_forwarder> code_forwarder_) :
		parent(parent_),
		slot_forwarder(slot_forwader_),
		code_forwarder(code_forwarder_) {}

	void operator()(object *obj, cell size)
	{
		slot_forwarder.visit_slots(obj);
		code_forwarder.visit_object_code_block(obj);
	}
};

struct code_block_compaction_updater {
	factor_vm *parent;
	slot_visitor<object_slot_forwarder> slot_forwarder;

	explicit code_block_compaction_updater(factor_vm *parent_, slot_visitor<object_slot_forwarder> slot_forwader_) :
		parent(parent_), slot_forwarder(slot_forwader_) {}

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
	mark_bits<heap_block> *code_forwarding_map = &code->allocator->state;

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
	object_compaction_updater object_updater(this,slot_forwarder,code_forwarder);
	tenured->compact(object_updater);

	/* Slide everything in the code heap up, and update data and code heap
	pointers inside code blocks. */
	code_block_compaction_updater code_block_updater(this,slot_forwarder);
	code_heap_iterator<code_block_compaction_updater> iter(code_block_updater);
	code->allocator->compact(iter);
}

}
