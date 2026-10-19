#include "master.hpp"
#include "cpu-stack-pointer-signals.hpp"

// Kernel signal return enters raw instructions. CALLS then establishes the
// native AP/FP frame and consumes the handler's entry mask. The handler must
// unwind into Factor; an unexpected native return stops instead of using a
// nonexistent caller frame.
__asm__(".text\n.align 1\n.globl vax_non_resumable_signal_entry\n"
        "vax_non_resumable_signal_entry:\ncalls $0,(%r0)\nhalt\n");

// JSB entry, with a count/argument list immediately above its return word and
// the mapped Factor continuation above that list. CALLG's hardware return PC
// stays in this pinned native text. The logical continuation can move during
// code compaction; consume that repaired word rather than JSB's original PC.
// R0/R1 carry the native result; R4/R5 are reserved Factor scratch registers.
__asm__(".text\n.align 1\n.globl vax_native_call_bridge\n"
        "vax_native_call_bridge:\nmoval 4(%sp),%r4\ncallg (%r4),(%r5)\n"
        "movl 4(%sp),%r4\nashl $2,%r4,%r4\naddl2 $8,%r4\n"
        "addl2 %r4,%sp\nrsb\n");

namespace factor {

static void software_fp_signal(uint_fast8_t) { (void)raise(SIGFPE); }

VM_C_API cell vax_get_fpu_state() {
  cell state = software_fp_get_state();
  software_fp_set_state(0);
  return state;
}

VM_C_API void vax_set_fpu_state(cell state) {
  software_fp_trap = software_fp_signal;
  software_fp_set_state((uint32_t)state);
}

// Optimizer values remain IEEE until the actual foreign ABI boundary.
VM_C_API uint32_t vax_to_ieee_float(cell value, factor_vm* parent) {
#if defined(FACTOR_INTEGER_ONLY)
  return narrow_ieee_bits(vm_float_bits(parent->untag_float_check(value)));
#else
  return parent->untag_float_check(value).float_bits();
#endif
}

VM_C_API uint64_t vax_to_ieee_double(cell value, factor_vm* parent) {
  return vm_float_bits(parent->untag_float_check(value));
}

VM_C_API cell vax_from_ieee_float(uint32_t bits, factor_vm* parent) {
  return parent->allot_float_bits(widen_float_bits(bits));
}

VM_C_API cell vax_from_ieee_double(uint64_t bits, factor_vm* parent) {
  return parent->allot_float_bits(bits);
}

// Integer arguments keep native F/D encodings out of IEEE register pairs.
// These helpers do not allocate on success. The caller publishes its Factor
// frame and GC map before CALLG, so ERROR_FFI can unwind normally.
VM_C_API uint32_t vax_native_float_to_ieee(uint32_t native, factor_vm* parent) {
#if defined(FACTOR_INTEGER_ONLY)
  (void)native;
  parent->general_error(ERROR_FLOAT_UNSUPPORTED, false_object, false_object);
  return 0;
#else
  uint32_t bits = 0;
  if (vax_f_to_ieee(&native, bits) == vax_float_conversion::reserved_operand)
    parent->general_error(ERROR_FFI, false_object, false_object);
  return bits;
#endif
}

VM_C_API uint64_t vax_native_double_to_ieee(uint64_t native, factor_vm* parent) {
#if defined(FACTOR_INTEGER_ONLY)
  (void)native;
  parent->general_error(ERROR_FLOAT_UNSUPPORTED, false_object, false_object);
  return 0;
#else
  uint64_t bits = 0;
  if (vax_d_to_ieee(&native, bits) == vax_float_conversion::reserved_operand)
    parent->general_error(ERROR_FFI, false_object, false_object);
  return bits;
#endif
}

VM_C_API uint32_t vax_ieee_float_to_native(uint32_t bits, factor_vm* parent) {
#if defined(FACTOR_INTEGER_ONLY)
  (void)bits;
  parent->general_error(ERROR_FLOAT_UNSUPPORTED, false_object, false_object);
  return 0;
#else
  uint32_t native = 0;
  vax_float_conversion status = ieee_to_vax_f(bits, &native);
  if (status != vax_float_conversion::exact && status != vax_float_conversion::rounded)
    parent->general_error(ERROR_FFI, false_object, false_object);
  return native;
#endif
}

VM_C_API uint64_t vax_ieee_double_to_native(uint64_t bits, factor_vm* parent) {
#if defined(FACTOR_INTEGER_ONLY)
  (void)bits;
  parent->general_error(ERROR_FLOAT_UNSUPPORTED, false_object, false_object);
  return 0;
#else
  uint64_t native = 0;
  vax_float_conversion status = ieee_to_vax_d(bits, &native);
  if (status != vax_float_conversion::exact && status != vax_float_conversion::rounded)
    parent->general_error(ERROR_FFI, false_object, false_object);
  return native;
#endif
}

VM_C_API uint64_t vax_ieee_single_to_double(uint32_t bits) {
  return widen_float_bits(bits);
}

VM_C_API uint64_t vax_ieee_sqrt(uint64_t bits) {
#if defined(FACTOR_INTEGER_ONLY)
  (void)bits;
  current_vm()->general_error(ERROR_FLOAT_UNSUPPORTED, false_object, false_object);
  return 0;
#else
  return vm_float::from_bits(bits).sqrt().bits();
#endif
}

VM_C_API uint32_t vax_ieee_double_to_single(uint64_t bits) {
  return narrow_float_bits(bits);
}

}
