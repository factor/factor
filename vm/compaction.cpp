#include "master.hpp"

namespace factor {

void factor_vm::update_fixup_set_for_compaction(mark_bits<code_block> *forwarding_map)
{
	std::set<code_block *>::const_iterator iter = code->needs_fixup.begin();
	std::set<code_block *>::const_iterator end = code->needs_fixup.end();

	std::set<code_block *> new_needs_fixup;
	for(; iter != end; iter++)
	{
		printf("a block needs fixup\n");
		new_needs_fixup.insert(forwarding_map->forward_block(*iter));
	}

	code->needs_fixup = new_needs_fixup;
}

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
	slot_visitor<forwarder<object> > slot_forwarder;
	code_block_visitor<forwarder<code_block> > code_forwarder;
	mark_bits<object> *data_forwarding_map;
	object_start_map *starts;

	explicit object_compaction_updater(factor_vm *parent_,
		slot_visitor<forwarder<object> > slot_forwarder_,
		code_block_visitor<forwarder<code_block> > code_forwarder_,
		mark_bits<object> *data_forwarding_map_) :
		parent(parent_),
		slot_forwarder(slot_forwarder_),
		code_forwarder(code_forwarder_),
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

		slot_forwarder.visit_slots(new_address,payload_start);
		code_forwarder.visit_object_code_block(new_address);
		starts->record_object_start_offset(new_address);
	}
};

struct relative_address_updater {
	factor_vm *parent;
	code_block *old_address;

	explicit relative_address_updater(factor_vm *parent_, code_block *old_address_) :
		parent(parent_), old_address(old_address_) {}

	void operator()(relocation_entry rel, cell index, code_block *compiled)
	{
		instruction_operand op(rel.rel_class(),rel.rel_offset() + (cell)compiled->xt());

		relocation_type type = rel.rel_type();
		cell value;
		if(type == RT_HERE || type == RT_THIS)
			value = parent->compute_relocation(rel,index,compiled);
		else
			value = op.load_value(rel.rel_offset() + (cell)old_address->xt());

		op.store_value(value);
	}
};

template<typename SlotForwarder, typename CodeBlockForwarder>
struct code_block_compaction_updater {
	factor_vm *parent;
	slot_visitor<forwarder<object> > slot_forwarder;
	code_block_visitor<forwarder<code_block> > code_forwarder;

	explicit code_block_compaction_updater(factor_vm *parent_,
		slot_visitor<forwarder<object> > slot_forwarder_,
		code_block_visitor<forwarder<code_block> > code_forwarder_) :
		parent(parent_), slot_forwarder(slot_forwarder_), code_forwarder(code_forwarder_) {}

	void operator()(code_block *old_address, code_block *new_address, cell size)
	{
		memmove(new_address,old_address,size);

		slot_forwarder.visit_code_block_objects(new_address);

		relative_address_updater updater(parent,old_address);
		parent->iterate_relocations(new_address,updater);

		slot_forwarder.visit_embedded_literals(new_address);
		code_forwarder.visit_embedded_code_pointers(new_address);
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

	update_fixup_set_for_compaction(code_forwarding_map);

	slot_visitor<forwarder<object> > slot_forwarder(this,forwarder<object>(data_forwarding_map));
	code_block_visitor<forwarder<code_block> > code_forwarder(this,forwarder<code_block>(code_forwarding_map));

	/* Object start offsets get recomputed by the object_compaction_updater */
	data->tenured->starts.clear_object_start_offsets();

	/* Slide everything in tenured space up, and update data and code heap
	pointers inside objects. */
	object_compaction_updater object_updater(this,slot_forwarder,code_forwarder,data_forwarding_map);
	compaction_sizer object_sizer(data_forwarding_map);
	tenured->compact(object_updater,object_sizer);

	/* Slide everything in the code heap up, and update data and code heap
	pointers inside code blocks. */
	code_block_compaction_updater<slot_visitor<forwarder<object> >, code_block_visitor<forwarder<code_block> > > code_block_updater(this,slot_forwarder,code_forwarder);
	standard_sizer<code_block> code_block_sizer;
	code->allocator->compact(code_block_updater,code_block_sizer);

	slot_forwarder.visit_roots();
	if(trace_contexts_p)
	{
		slot_forwarder.visit_contexts();
		code_forwarder.visit_context_code_blocks();
		code_forwarder.visit_callback_code_blocks();
	}

	update_code_roots_for_compaction();

	current_gc->event->ended_compaction();
}

struct object_code_block_updater {
	code_block_visitor<forwarder<code_block> > code_forwarder;

	explicit object_code_block_updater(code_block_visitor<forwarder<code_block> > code_forwarder_) :
		code_forwarder(code_forwarder_) {}

	void operator()(object *obj)
	{
		code_forwarder.visit_object_code_block(obj);
	}
};

struct code_block_grow_heap_updater {
	factor_vm *parent;

	explicit code_block_grow_heap_updater(factor_vm *parent_) : parent(parent_) {}

	void operator()(code_block *old_address, code_block *new_address, cell size)
	{
		memmove(new_address,old_address,size);
		parent->relocate_code_block(new_address);
	}
};

/* Compact just the code heap, after growing the data heap */
void factor_vm::collect_compact_code_impl(bool trace_contexts_p)
{
	/* Figure out where blocks are going to go */
	mark_bits<code_block> *code_forwarding_map = &code->allocator->state;
	code_forwarding_map->compute_forwarding();

	update_fixup_set_for_compaction(code_forwarding_map);

	code_block_visitor<forwarder<code_block> > code_forwarder(this,forwarder<code_block>(code_forwarding_map));

	if(trace_contexts_p)
	{
		code_forwarder.visit_context_code_blocks();
		code_forwarder.visit_callback_code_blocks();
	}

	/* Update code heap references in data heap */
	object_code_block_updater updater(code_forwarder);
	each_object(updater);

	/* Slide everything in the code heap up, and update code heap
	pointers inside code blocks. */
	code_block_grow_heap_updater code_block_updater(this);
	standard_sizer<code_block> code_block_sizer;
	code->allocator->compact(code_block_updater,code_block_sizer);

	update_code_roots_for_compaction();
}

}
