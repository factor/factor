#include <limits.h>
#include "master.hpp"
#include "gtest/gtest.h"

namespace factor {

cell stack_depth(cell stack_ptr, segment *seg) {
  return (stack_ptr - seg->start + sizeof(cell)) / sizeof(cell);
}

cell datastack_depth(context *ctx) {
  return stack_depth(ctx->datastack, ctx->datastack_seg);
}

factor_vm* setup_factor_vm() {
  factor_vm* vm = new_factor_vm();
  vm_char* image_path = STRING_LITERAL("factor.image");
  vm_parameters p;
  vm->default_parameters(&p);
  p.image_path = image_path;
  vm->init_factor(&p);
  context* ctx = vm->spare_ctx;
  vm->ctx = vm->spare_ctx;
  return vm;
}

TEST(VMParametersTests, DefaultParameters) {
  vm_parameters p;
  factor_vm* vm = new_factor_vm();
  vm->default_parameters(&p);
  EXPECT_EQ(false, p.embedded_image);
  EXPECT_EQ(32 * sizeof(cell), p.datastack_size);
  EXPECT_EQ(32 * sizeof(cell), p.retainstack_size);
  delete vm;
}

TEST(FactorVMTests, InitialValues) {
  factor_vm* vm = new_factor_vm();
  EXPECT_EQ(0, vm->current_jit_count);
  EXPECT_EQ(false, vm->fep_p);
  delete vm;
}

TEST(FactorVMTests, CheckStackSizes) {
  factor_vm* vm = new_factor_vm();
  vm_char* image_path = STRING_LITERAL("factor.image");
  vm_parameters p;
  vm->default_parameters(&p);
  p.image_path = image_path;
  vm->init_factor(&p);
  EXPECT_TRUE(vm->spare_ctx != NULL);
  EXPECT_TRUE(vm->spare_ctx->datastack_seg != NULL);
  EXPECT_TRUE(vm->spare_ctx->retainstack_seg != NULL);
  EXPECT_TRUE(vm->spare_ctx->callstack_seg != NULL);
  EXPECT_EQ(p.datastack_size, vm->spare_ctx->datastack_seg->size);
  EXPECT_EQ(p.retainstack_size, vm->spare_ctx->retainstack_seg->size);
  EXPECT_EQ(p.callstack_size, vm->spare_ctx->callstack_seg->size);
  delete vm;
}

TEST(ContextTests, PushAndPopItems) {
  factor_vm* vm = setup_factor_vm();
  context* ctx = vm->ctx;
  cell initial_sp = ctx->datastack;
  EXPECT_EQ(0, datastack_depth(ctx));
  ctx->push(3);
  ctx->push(4);
  EXPECT_EQ(2, datastack_depth(ctx));
  ctx->pop();
  ctx->pop();
  EXPECT_EQ(0, datastack_depth(ctx));
  delete vm;
}

TEST(ArrayTests, PrimitiveArray) {
  factor_vm* vm = setup_factor_vm();
  context* ctx = vm->ctx;

  EXPECT_EQ(0, datastack_depth(ctx));
  ctx->push(tag_fixnum(9));
  ctx->push(tag_fixnum(9));
  EXPECT_EQ(2, datastack_depth(ctx));
  vm->primitive_array();
  EXPECT_EQ(1, datastack_depth(ctx));
  cell obj = ctx->pop();
  EXPECT_EQ(0, datastack_depth(ctx));

  EXPECT_EQ(ARRAY_TYPE, TAG(obj));
  array* arr = (array*)UNTAG(obj);
  cell capacity = untag_fixnum(arr->capacity);
  EXPECT_EQ(9, capacity);

  // Iterate elements
  for (int n = 0; n < capacity; n++) {
    cell elt = arr->data()[n];
    EXPECT_EQ(9, untag_fixnum(elt));
  }
  delete vm;
}

TEST(ArrayTests, SizeFromBignum) {
  factor_vm* vm = setup_factor_vm();
  context* ctx = vm->ctx;

  ctx->push(tag<bignum>(vm->fixnum_to_bignum(2987)));
  ctx->push(tag_fixnum(812));
  vm->primitive_array();
  EXPECT_EQ(1, datastack_depth(ctx));

  array* arr = (array*)untag<array>(ctx->pop());
  EXPECT_EQ(2987, untag_fixnum(arr->capacity));
  delete vm;
}

TEST(BignumTests, FixnumToBignum) {
  factor_vm* vm = setup_factor_vm();
  fixnum numbers[] = {123, -123, 777, 0, 1000002};
  for (int n = 0; n < 5; n++) {
    fixnum num = numbers[n];
    bignum* bn = vm->fixnum_to_bignum(num);
    EXPECT_EQ(num, vm->bignum_to_fixnum(bn));
  }
  delete vm;
}

}
