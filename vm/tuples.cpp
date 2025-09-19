#include "master.hpp"

namespace factor {

// push a new tuple on the stack, filling its slots with f
// Allocates memory
void factor_vm::primitive_tuple() {
  data_root<tuple_layout> layout(ctx->pop(), this);
  tagged<tuple> t(allot<tuple>(tuple_size(layout.untagged())));
  t->layout = layout.value();

  memset_cell(t->data(), false_object,
              tuple_size(layout.untagged()) - sizeof(cell));

  ctx->push(t.value());
}

// push a new tuple on the stack, filling its slots from the stack
// Allocates memory
void factor_vm::primitive_tuple_boa() {
  data_root<tuple_layout> layout(ctx->pop(), this);
  tagged<tuple> t(allot<tuple>(tuple_size(layout.untagged())));
  t->layout = layout.value();

  cell size = untag_fixnum(layout.untagged()->size) * sizeof(cell);
  cell src_addr = ctx->datastack - size + sizeof(cell);
    memcpy(t->data(), ptr_from_cell<void>(src_addr), size);
  ctx->datastack -= size;
  ctx->push(t.value());
}

}
