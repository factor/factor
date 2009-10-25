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

/* statistics */
struct generation_statistics {
	cell collections;
	u64 gc_time;
	u64 max_gc_time;
	cell object_count;
	u64 bytes_copied;
};

struct gc_statistics {
	generation_statistics nursery_stats;
	generation_statistics aging_stats;
	generation_statistics full_stats;
	u64 cards_scanned;
	u64 decks_scanned;
	u64 card_scan_time;
	u64 code_blocks_scanned;
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
