namespace factor
{

enum gc_op {
	collect_nursery_op,
	collect_aging_op,
	collect_to_tenured_op,
	collect_full_op,
	collect_compact_op,
	collect_growing_heap_op
};

struct gc_state {
	gc_op op;
	u64 start_time;
        jmp_buf gc_unwind;

	explicit gc_state(gc_op op_);
	~gc_state();
};

VM_C_API void inline_gc(cell *gc_roots_base, cell gc_roots_size, factor_vm *parent);

}
