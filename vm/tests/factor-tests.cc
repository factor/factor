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
  const vm_char* image_path = STRING_LITERAL("factor.image");
  vm_parameters p;
  vm->default_parameters(&p);
  p.image_path = image_path;
  vm->init_factor(&p);
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
  const vm_char* image_path = STRING_LITERAL("factor.image");
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
  EXPECT_EQ(0, datastack_depth(ctx));
  ctx->push(3);
  ctx->push(4);
  EXPECT_EQ(2, datastack_depth(ctx));
  ctx->pop();
  ctx->pop();
  EXPECT_EQ(0, datastack_depth(ctx));
  delete vm;
}

TEST(MathTests, FixnumShift) {
  factor_vm* vm = setup_factor_vm();
  context* ctx = vm->ctx;
  ctx->push(tag_fixnum(8));
  ctx->push(tag_fixnum(2));
  vm->primitive_fixnum_shift();
  cell obj = ctx->pop();
  EXPECT_EQ(0, datastack_depth(ctx));
  EXPECT_EQ(32, untag_fixnum(obj));
  delete vm;
}

TEST(MathTests, FixnumShiftBignum) {
  factor_vm* vm = setup_factor_vm();
  context* ctx = vm->ctx;
  ctx->push(tag_fixnum(1));
  ctx->push(tag_fixnum(67));
  vm->primitive_fixnum_shift();
  cell obj = ctx->pop();
  EXPECT_EQ(0, datastack_depth(ctx));
  EXPECT_EQ(BIGNUM_TYPE, TAG(obj));
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
  for (cell n = 0; n < capacity; n++) {
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

TEST(BignumTests, CountDigits) {
  factor_vm* vm = setup_factor_vm();
  cell fixnum_bits = (WORD_SIZE - TAG_BITS - 1);
  for (cell n = 1; n < fixnum_bits; n++) {
    fixnum f = ((fixnum)1 << n) - 1;
    bignum *b_pos = vm->fixnum_to_bignum(f);
    EXPECT_EQ(1, BIGNUM_LENGTH(b_pos));
    bignum *b_neg = vm->fixnum_to_bignum(-f);
    EXPECT_EQ(1, BIGNUM_LENGTH(b_neg));
  }
  delete vm;
}

TEST(BignumTests, CountDigitsInSpecialNums) {
  factor_vm* vm = setup_factor_vm();
  fixnum numbers[] = {0, 1, -1, fixnum_max, fixnum_min};
  cell expected[] = {0, 1, 1, 1, 1};
  for (cell n = 0; n < 5; n++) {
    fixnum num = numbers[n];
    cell exp = expected[n];
    EXPECT_EQ(exp, BIGNUM_LENGTH(vm->fixnum_to_bignum(num)));
  }
  delete vm;
}

TEST(AllotTests, AllocateInNursery) {
  factor_vm* vm = setup_factor_vm();

  for (cell n = 0; n < 10; n++) {
    cell free_space = vm->nursery.free_space();
    ASSERT_GT(free_space, 0);
    vm->fixnum_to_bignum(99999);
    ASSERT_LT(vm->nursery.free_space(), free_space);
  }
  delete vm;
}

TEST(AllotTests, CheckBignumMoveToAging) {
  factor_vm* vm = setup_factor_vm();

  bignum *b1 = vm->fixnum_to_bignum(99999);
  bignum *b2 = vm->fixnum_to_bignum(99999);
  cell old_addr1 = (cell)b1;
  cell old_addr2 = (cell)b2;
  gc_bignum *b_data_root = new gc_bignum(&b1, vm);

  vm->primitive_minor_gc();

  // Object now lives in aging and has a new address.
  ASSERT_NE((cell)b1, old_addr1);

  // But the other bignum wasn't data rooted and therefore wasn't
  // moved. Its pointer is now invalid.
  ASSERT_EQ((cell)b2, old_addr2);

  delete b_data_root;
  delete vm;
}

TEST(AllotTests, CheckStringMoveToAging) {
  factor_vm* vm = setup_factor_vm();

  string *s1 = vm->allot_string(77, 65);
  string *s2 = vm->allot_string(100, 66);
  cell addr1 = (cell)s1, addr2 = (cell)s2;
  data_root<string> *s1_dr = new data_root<string>(s1, vm);
  ASSERT_EQ(s1_dr->untagged(), s1);

  vm->primitive_minor_gc();

  memset_cell((void*)vm->nursery.start, false_object, vm->nursery.size);
  ASSERT_EQ(vm->nursery.start, vm->nursery.here);

  // None of the pointers have been moved. Different from the
  // gc_bignum case.
  ASSERT_EQ((cell)s1, addr1);
  ASSERT_EQ((cell)s2, addr2);

  // But if you untag the data rooted object, you find the moved
  // string.
  string *moved_s1 = s1_dr->untagged();
  ASSERT_NE((cell)moved_s1, addr1);
  ASSERT_EQ(77, string_capacity(moved_s1));

  delete s1_dr;
  delete vm;
}


}
