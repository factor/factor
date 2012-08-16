#include "master.hpp"

namespace factor
{

void factor_vm::primitive_special_object()
{
	fixnum n = untag_fixnum(ctx->peek());
	ctx->replace(special_objects[n]);
}

void factor_vm::primitive_set_special_object()
{
	fixnum n = untag_fixnum(ctx->pop());
	cell value = ctx->pop();
	special_objects[n] = value;
}

void factor_vm::primitive_identity_hashcode()
{
	cell tagged = ctx->peek();
	object *obj = untag<object>(tagged);
	ctx->replace(tag_fixnum(obj->hashcode()));
}

void factor_vm::compute_identity_hashcode(object *obj)
{
	object_counter++;
	if(object_counter == 0) object_counter++;
	obj->set_hashcode((cell)obj ^ object_counter);
}

void factor_vm::primitive_compute_identity_hashcode()
{
	object *obj = untag<object>(ctx->pop());
	compute_identity_hashcode(obj);
}

void factor_vm::primitive_set_slot()
{
	fixnum slot = untag_fixnum(ctx->pop());
	object *obj = untag<object>(ctx->pop());
	cell value = ctx->pop();

	cell *slot_ptr = &obj->slots()[slot];
	*slot_ptr = value;
	write_barrier(slot_ptr);
}

cell factor_vm::clone_object(cell obj_)
{
	data_root<object> obj(obj_,this);

	if(immediate_p(obj.value()))
		return obj.value();
	else
	{
		cell size = object_size(obj.value());
		object *new_obj = allot_object(obj.type(),size);
		memcpy(new_obj,obj.untagged(),size);
		new_obj->set_hashcode(0);
		return tag_dynamic(new_obj);
	}
}

void factor_vm::primitive_clone()
{
	ctx->replace(clone_object(ctx->peek()));
}

/* Size of the object pointed to by a tagged pointer */
cell factor_vm::object_size(cell tagged)
{
	if(immediate_p(tagged))
		return 0;
	else
		return untag<object>(tagged)->size();
}

/* Allocates memory */
void factor_vm::primitive_size()
{
	ctx->push(from_unsigned_cell(object_size(ctx->pop())));
}

struct slot_become_fixup : no_fixup {
	std::map<object *,object *> *become_map;

	explicit slot_become_fixup(std::map<object *,object *> *become_map_) :
		become_map(become_map_) {}

	object *fixup_data(object *old)
	{
		std::map<object *,object *>::const_iterator iter = become_map->find(old);
		if(iter != become_map->end())
			return iter->second;
		else
			return old;
	}
};

struct object_become_visitor {
	slot_visitor<slot_become_fixup> *workhorse;

	explicit object_become_visitor(slot_visitor<slot_become_fixup> *workhorse_) :
		workhorse(workhorse_) {}

	void operator()(object *obj)
	{
		workhorse->visit_slots(obj);
	}
};

struct code_block_become_visitor {
	slot_visitor<slot_become_fixup> *workhorse;

	explicit code_block_become_visitor(slot_visitor<slot_become_fixup> *workhorse_) :
		workhorse(workhorse_) {}

	void operator()(code_block *compiled, cell size)
	{
		workhorse->visit_code_block_objects(compiled);
		workhorse->visit_embedded_literals(compiled);
	}
};

struct code_block_write_barrier_visitor {
	code_heap *code;

	explicit code_block_write_barrier_visitor(code_heap *code_) :
		code(code_) {}

	void operator()(code_block *compiled, cell size)
	{
		code->write_barrier(compiled);
	}
};

/* classes.tuple uses this to reshape tuples; tools.deploy.shaker uses this
   to coalesce equal but distinct quotations and wrappers. */
void factor_vm::primitive_become()
{
	array *new_objects = untag_check<array>(ctx->pop());
	array *old_objects = untag_check<array>(ctx->pop());

	cell capacity = array_capacity(new_objects);
	if(capacity != array_capacity(old_objects))
		critical_error("bad parameters to become",0);

	/* Build the forwarding map */
	std::map<object *,object *> become_map;

	for(cell i = 0; i < capacity; i++)
	{
		tagged<object> old_obj(array_nth(old_objects,i));
		tagged<object> new_obj(array_nth(new_objects,i));

		if(old_obj != new_obj)
			become_map[old_obj.untagged()] = new_obj.untagged();
	}

	/* Update all references to old objects to point to new objects */
	{
		slot_visitor<slot_become_fixup> workhorse(this,slot_become_fixup(&become_map));
		workhorse.visit_roots();
		workhorse.visit_contexts();

		object_become_visitor object_visitor(&workhorse);
		each_object(object_visitor);

		code_block_become_visitor code_block_visitor(&workhorse);
		each_code_block(code_block_visitor);
	}

	/* Since we may have introduced old->new references, need to revisit
	all objects and code blocks on a minor GC. */
	data->mark_all_cards();

	{
		code_block_write_barrier_visitor code_block_visitor(code);
		each_code_block(code_block_visitor);
	}
}

}
