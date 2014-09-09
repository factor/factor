namespace factor {

/* The callback heap is used to store the machine code that alien-callbacks
actually jump to when C code invokes them.

The callback heap has entries that look like code_blocks from the code heap, but
callback heap entries are allocated contiguously, never deallocated, and all
fields but the owner are set to false_object. The owner points to the callback
bottom word, whose entry point is the callback body itself, generated by the
optimizing compiler. The machine code that follows a callback stub consists of a
single CALLBACK_STUB machine code template, which performs a jump to a "far"
address (on PowerPC and x86-64, its loaded into a register first).

GC updates the CALLBACK_STUB code if the code block of the callback bottom word
is ever moved. The callback stub itself won't move, though, and is never
deallocated. This means that the callback stub itself is a stable function
pointer that C code can hold on to until the associated Factor VM exits.

Since callback stubs are GC roots, and are never deallocated, the associated
callback code in the code heap is also never deallocated.

The callback heap is not saved in the image. Running GC in a new session after
saving the image will deallocate any code heap entries that were only reachable
from the callback heap in the previous session when the image was saved. */

struct callback_heap {
  segment* seg;
  bump_allocator<code_block>* allocator;
  factor_vm* parent;

  callback_heap(cell size, factor_vm* parent);
  ~callback_heap();

  void* callback_entry_point(code_block* stub) {
    word* w = (word*)UNTAG(stub->owner);
    return w->entry_point;
  }

  bool setup_seh_p();
  bool return_takes_param_p();
  instruction_operand callback_operand(code_block* stub, cell index);
  void store_callback_operand(code_block* stub, cell index);
  void store_callback_operand(code_block* stub, cell index, cell value);

  void update(code_block* stub);

  code_block* add(cell owner, cell return_rewind);

  void update();
};

}
