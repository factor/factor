#include "master.hpp"

namespace factor {

// Simple non-optimizing compiler.

// This is one of the two compilers implementing Factor; the second one is
// written in Factor and performs advanced optimizations. See
// basis/compiler/compiler.factor.

// The non-optimizing compiler compiles a quotation at a time by
// concatenating machine code chunks; prolog, epilog, call word, jump to
// word, etc. These machine code chunks are generated from Factor code in
// basis/bootstrap/assembler/.

// Calls to words and constant quotations (referenced by conditionals and
// dips) are direct jumps to machine code blocks. Literals are also
// referenced directly without going through the literal table.

// It actually does do a little bit of very simple optimization:

// 1) Tail call optimization.

// 2) If a quotation is determined to not call any other words (except for a
// few special words which are open-coded, see below), then no prolog/epilog
// is generated.

// 3) When in tail position and immediately preceded by literal arguments,
// the 'if' is generated inline, instead of as a call to the 'if' word.

// 4) When preceded by a quotation, calls to 'dip', '2dip' and '3dip' are
// open-coded as retain stack manipulation surrounding a subroutine call.

// 5) Sub-primitives are primitive words which are implemented in assembly
// and not in the VM. They are open-coded and no subroutine call is generated.
// This includes stack shufflers, some fixnum arithmetic words, and words
// such as tag, slot and eq?. A primitive call is relatively expensive
// (two subroutine calls) so this results in a big speedup for relatively
// little effort.

inline cell quotation_jit::nth(cell index) {
  return array_nth(elements.untagged(), index);
}

void quotation_jit::init_quotation(cell quot) {
  elements.set_value(untag<quotation>(quot)->array);
}

bool quotation_jit::fast_if_p(cell i, cell length) {
  return (i + 3) == length &&
      TAG(nth(i + 1)) == QUOTATION_TYPE &&
      nth(i + 2) == parent->special_objects[JIT_IF_WORD];
}

bool quotation_jit::primitive_call_p(cell i, cell length) {
  cell jit_primitive_word = parent->special_objects[JIT_PRIMITIVE_WORD];
  return (i + 2) <= length && nth(i + 1) == jit_primitive_word;
}

bool quotation_jit::fast_dip_p(cell i, cell length) {
  cell jit_dip_word = parent->special_objects[JIT_DIP_WORD];
  return (i + 2) <= length && nth(i + 1) == jit_dip_word;
}

bool quotation_jit::fast_2dip_p(cell i, cell length) {
  cell jit_2dip_word = parent->special_objects[JIT_2DIP_WORD];
  return (i + 2) <= length && nth(i + 1) == jit_2dip_word;
}

bool quotation_jit::fast_3dip_p(cell i, cell length) {
  cell jit_3dip_word = parent->special_objects[JIT_3DIP_WORD];
  return (i + 2) <= length && nth(i + 1) == jit_3dip_word;
}

bool quotation_jit::declare_p(cell i, cell length) {
  cell jit_declare_word = parent->special_objects[JIT_DECLARE_WORD];
  return (i + 2) <= length && nth(i + 1) == jit_declare_word;
}

bool quotation_jit::mega_lookup_p(cell i, cell length) {
  return (i + 4) <= length &&
      TAG(nth(i + 1)) == FIXNUM_TYPE &&
      TAG(nth(i + 2)) == ARRAY_TYPE &&
      nth(i + 3) == parent->special_objects[MEGA_LOOKUP_WORD];
}

// Subprimitives should be flagged with whether they require a stack frame.
// See #295.
bool quotation_jit::special_subprimitive_p(cell obj) {
  return obj == parent->special_objects[SIGNAL_HANDLER_WORD] ||
         obj == parent->special_objects[LEAF_SIGNAL_HANDLER_WORD] ||
         obj == parent->special_objects[UNWIND_NATIVE_FRAMES_WORD];
}

// All quotations want a stack frame, except if they contain:
//   1) calls to the special subprimitives, see #295.
//   2) mega cache lookups, see #651
bool quotation_jit::stack_frame_p() {
  cell length = array_capacity(elements.untagged());
  for (cell i = 0; i < length; i++) {
    cell obj = nth(i);
    cell tag = TAG(obj);
    if ((tag == WORD_TYPE && special_subprimitive_p(obj)) ||
        (tag == ARRAY_TYPE && mega_lookup_p(i, length)))
      return false;
  }
  return true;
}

static bool trivial_quotation_p(array* elements) {
  return array_capacity(elements) == 1 &&
      TAG(array_nth(elements, 0)) == WORD_TYPE;
}

// Allocates memory (emit)
void quotation_jit::emit_epilog(bool needed) {
  if (needed) {
    emit(parent->special_objects[JIT_SAFEPOINT]);
    emit(parent->special_objects[JIT_EPILOG]);
  }
}

// Allocates memory conditionally
void quotation_jit::emit_quotation(cell quot_) {
  data_root<quotation> quot(quot_, parent);

  array* quot_elements = untag<array>(quot->array);

  // If the quotation consists of a single word, compile a direct call
  // to the word.
  if (trivial_quotation_p(quot_elements))
    literal(array_nth(quot_elements, 0));
  else {
    if (compiling)
      parent->jit_compile_quotation(quot.value(), relocate);
    literal(quot.value());
  }
}

// Allocates memory (parameter(), literal(), emit_epilog, emit_with_literal)
void quotation_jit::iterate_quotation() {
  bool stack_frame = stack_frame_p();

  set_position(0);

  if (stack_frame) {
    emit(parent->special_objects[JIT_SAFEPOINT]);
    emit(parent->special_objects[JIT_PROLOG]);
  }

  cell length = array_capacity(elements.untagged());
  bool tail_call = false;

  for (cell i = 0; i < length; i++) {
    set_position(i);
    data_root<object> obj(nth(i), parent);

    switch (obj.type()) {
      case WORD_TYPE:
        // Sub-primitives
        if (to_boolean(obj.as<word>()->subprimitive)) {
          tail_call = emit_subprimitive(obj.value(),     // word
                                        i == length - 1, // tail_call_p
                                        stack_frame);    // stack_frame_p
        }                                                // Everything else
        else if (i == length - 1) {
          emit_epilog(stack_frame);
          tail_call = true;
          word_jump(obj.value());
        } else
          word_call(obj.value());
        break;
      case WRAPPER_TYPE:
        push(obj.as<wrapper>()->object);
        break;
      case BYTE_ARRAY_TYPE:
        // Primitive calls
        if (primitive_call_p(i, length)) {
// On x86-64 and PowerPC, the VM pointer is stored in a register;
// on other platforms, the RT_VM relocation is used and it needs
// an offset parameter
#ifdef FACTOR_X86
          parameter(tag_fixnum(0));
#endif
          parameter(obj.value());
          parameter(false_object);
#ifdef FACTOR_PPC_TOC
          parameter(obj.value());
          parameter(false_object);
#endif
          emit(parent->special_objects[JIT_PRIMITIVE]);

          i++;
        } else
          push(obj.value());
        break;
      case QUOTATION_TYPE:
        // 'if' preceded by two literal quotations (this is why if and ? are
        // mutually recursive in the library, but both still work)
        if (fast_if_p(i, length)) {
          emit_epilog(stack_frame);
          tail_call = true;
          emit_quotation(nth(i));
          emit_quotation(nth(i + 1));
          emit(parent->special_objects[JIT_IF]);
          i += 2;
        } // dip
        else if (fast_dip_p(i, length)) {
          emit_quotation(obj.value());
          emit(parent->special_objects[JIT_DIP]);
          i++;
        } // 2dip
        else if (fast_2dip_p(i, length)) {
          emit_quotation(obj.value());
          emit(parent->special_objects[JIT_2DIP]);
          i++;
        } // 3dip
        else if (fast_3dip_p(i, length)) {
          emit_quotation(obj.value());
          emit(parent->special_objects[JIT_3DIP]);
          i++;
        } else
          push(obj.value());
        break;
      case ARRAY_TYPE:
        // Method dispatch
        if (mega_lookup_p(i, length)) {
          tail_call = true;
          emit_mega_cache_lookup(nth(i), untag_fixnum(nth(i + 1)), nth(i + 2));
          i += 3;
        } // Non-optimizing compiler ignores declarations
        else if (declare_p(i, length))
          i++;
        else
          push(obj.value());
        break;
      default:
        push(obj.value());
        break;
    }
  }

  if (!tail_call) {
    set_position(length);
    emit_epilog(stack_frame);
    emit(parent->special_objects[JIT_RETURN]);
  }
}

cell quotation_jit::word_stack_frame_size(cell obj) {
  if (special_subprimitive_p(obj))
    return SIGNAL_HANDLER_STACK_FRAME_SIZE;
  return JIT_FRAME_SIZE;
}

// Allocates memory
void quotation_jit::emit_mega_cache_lookup(cell methods_, fixnum index,
                                           cell cache_) {
  data_root<array> methods(methods_, parent);
  data_root<array> cache(cache_, parent);

  // Load the object from the datastack.
  emit_with_literal(parent->special_objects[PIC_LOAD],
                    tag_fixnum(-index * sizeof(cell)));

  // Do a cache lookup.
  emit_with_literal(parent->special_objects[MEGA_LOOKUP], cache.value());

  // If we end up here, the cache missed.
  emit(parent->special_objects[JIT_PROLOG]);

  // Push index, method table and cache on the stack.
  push(methods.value());
  push(tag_fixnum(index));
  push(cache.value());
  word_call(parent->special_objects[MEGA_MISS_WORD]);

  // Now the new method has been stored into the cache, and its on
  // the stack.
  emit(parent->special_objects[JIT_EPILOG]);
  emit(parent->special_objects[JIT_EXECUTE]);
}

// Allocates memory
code_block* factor_vm::jit_compile_quotation(cell owner_, cell quot_,
                                             bool relocating) {
  data_root<object> owner(owner_, this);
  data_root<quotation> quot(quot_, this);

  quotation_jit compiler(owner.value(), true, relocating, this);
  compiler.init_quotation(quot.value());
  compiler.iterate_quotation();

  cell frame_size = compiler.word_stack_frame_size(owner_);

  code_block* compiled = compiler.to_code_block(CODE_BLOCK_UNOPTIMIZED,
                                                frame_size);
  if (relocating)
    initialize_code_block(compiled);

  return compiled;
}

// Allocates memory
void factor_vm::jit_compile_quotation(cell quot_, bool relocating) {
  data_root<quotation> quot(quot_, this);
  if (!quotation_compiled_p(quot.untagged())) {
    code_block* compiled =
        jit_compile_quotation(quot.value(), quot.value(), relocating);
    quot.untagged()->entry_point = compiled->entry_point();
  }
}

// Allocates memory
void factor_vm::primitive_jit_compile() {
  jit_compile_quotation(ctx->pop(), true);
}

cell factor_vm::lazy_jit_compile_entry_point() {
  return untag<word>(special_objects[LAZY_JIT_COMPILE_WORD])->entry_point;
}

// push a new quotation on the stack
// Allocates memory
void factor_vm::primitive_array_to_quotation() {
  quotation* quot = allot<quotation>(sizeof(quotation));

  quot->array = ctx->peek();
  quot->cached_effect = false_object;
  quot->cache_counter = false_object;
  quot->entry_point = lazy_jit_compile_entry_point();

  ctx->replace(tag<quotation>(quot));
}

// Allocates memory (from_unsigned_cell)
void factor_vm::primitive_quotation_code() {
  data_root<quotation> quot(ctx->pop(), this);

  ctx->push(from_unsigned_cell(quot->entry_point));
  ctx->push(from_unsigned_cell((cell)quot->code() + quot->code()->size()));
}

// Allocates memory
fixnum factor_vm::quot_code_offset_to_scan(cell quot_, cell offset) {
  data_root<quotation> quot(quot_, this);
  data_root<array> array(quot->array, this);

  quotation_jit compiler(quot.value(), false, false, this);
  compiler.init_quotation(quot.value());
  compiler.compute_position(offset);
  compiler.iterate_quotation();

  return compiler.get_position();
}

// Allocates memory
cell factor_vm::lazy_jit_compile(cell quot_) {
  data_root<quotation> quot(quot_, this);

  FACTOR_ASSERT(!quotation_compiled_p(quot.untagged()));

  code_block* compiled =
      jit_compile_quotation(quot.value(), quot.value(), true);
  quot.untagged()->entry_point = compiled->entry_point();

  return quot.value();
}

// Allocates memory
VM_C_API cell lazy_jit_compile(cell quot, factor_vm* parent) {
  return parent->lazy_jit_compile(quot);
}

bool factor_vm::quotation_compiled_p(quotation* quot) {
  return quot->entry_point != 0 &&
         quot->entry_point != lazy_jit_compile_entry_point();
}

void factor_vm::primitive_quotation_compiled_p() {
  quotation* quot = untag_check<quotation>(ctx->pop());
  ctx->push(tag_boolean(quotation_compiled_p(quot)));
}

}
