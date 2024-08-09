#include "master.hpp"

namespace factor {

// Size of the object pointed to by a tagged pointer
cell object_size(cell tagged) {
  if (immediate_p(tagged))
    return 0;
  return untag<object>(tagged)->size();
}

void factor_vm::primitive_special_object() {
  fixnum n = untag_fixnum(ctx->peek());
  ctx->replace(special_objects[n]);
}

void factor_vm::primitive_set_special_object() {
  fixnum n = untag_fixnum(ctx->pop());
  cell value = ctx->pop();
  special_objects[n] = value;
}

void factor_vm::primitive_identity_hashcode() {
  cell tagged = ctx->peek();
  object* obj = untag<object>(tagged);
  ctx->replace(tag_fixnum(obj->hashcode()));
}

void factor_vm::primitive_compute_identity_hashcode() {
  object* obj = untag<object>(ctx->pop());
  cell y = object_counter;
#ifdef FACTOR_64
  y ^= (y<<13); y ^= (y>>17); y ^= (y<<5);
#else
  y ^= (y<<13); y ^= (y>>7); y ^= (y<<17);
#endif
  object_counter = y;
  obj->set_hashcode(y);
}

void factor_vm::primitive_set_slot() {
  fixnum slot = untag_fixnum(ctx->pop());
  object* obj = untag<object>(ctx->pop());
  cell value = ctx->pop();

  cell* slot_ptr = &obj->slots()[slot];
  *slot_ptr = value;
  write_barrier(slot_ptr);
}

// Allocates memory
void factor_vm::primitive_clone() {

  data_root<object> obj(ctx->peek(), this);

  if (immediate_p(obj.value()))
    return;
  cell size = object_size(obj.value());
  object* new_obj = allot_object(obj.type(), size);
  memcpy(new_obj, obj.untagged(), size);
  new_obj->set_hashcode(0);
  ctx->replace(tag_dynamic(new_obj));
}

// Allocates memory
void factor_vm::primitive_size() {
  ctx->replace(from_unsigned_cell(object_size(ctx->peek())));
}

struct slot_become_fixup : no_fixup {
  std::map<object*, object*>* become_map;

  slot_become_fixup(std::map<object*, object*>* become_map)
      : become_map(become_map) {}

  object* fixup_data(object* old) {
    std::map<object*, object*>::const_iterator iter = become_map->find(old);
    if (iter != become_map->end())
      return iter->second;
    return old;
  }
};

// classes.tuple uses this to reshape tuples; tools.deploy.shaker uses this
// to coalesce equal but distinct quotations and wrappers.
// Calls gc
void factor_vm::primitive_become() {
  primitive_minor_gc();
  array* new_objects = untag_check<array>(ctx->pop());
  array* old_objects = untag_check<array>(ctx->pop());

  cell capacity = array_capacity(new_objects);
  if (capacity != array_capacity(old_objects))
    critical_error("bad parameters to become", 0);

  // Build the forwarding map
  std::map<object*, object*> become_map;

  for (cell i = 0; i < capacity; i++) {
    cell old_ptr = array_nth(old_objects, i);
    cell new_ptr = array_nth(new_objects, i);
    if (old_ptr != new_ptr)
      become_map[untag<object>(old_ptr)] = untag<object>(new_ptr);
  }

  // Update all references to old objects to point to new objects
  {
    slot_visitor<slot_become_fixup> visitor(this,
                                            slot_become_fixup(&become_map));
    visitor.visit_all_roots();

    auto object_become_func = [&](object* obj) {
      visitor.visit_slots(obj);
    };
    each_object(object_become_func);

    auto code_block_become_func = [&](code_block* compiled, cell size) {
      (void)size;
      visitor.visit_code_block_objects(compiled);
      visitor.visit_embedded_literals(compiled);
      code->write_barrier(compiled);
    };
    each_code_block(code_block_become_func);
  }

  // Since we may have introduced old->new references, need to revisit
  // all objects and code blocks on a minor GC.
  data->mark_all_cards();
}

}
