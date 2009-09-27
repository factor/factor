namespace factor
{

/* statistics */
struct gc_stats {
	cell collections;
	u64 gc_time;
	u64 max_gc_time;
	cell object_count;
	u64 bytes_copied;
};

/* We leave this many bytes free at the top of the nursery so that inline
allocation (which does not call GC because of possible roots in volatile
registers) does not run out of memory */
static const cell allot_buffer_zone = 1024;

struct factor_vm;
VM_C_API void inline_gc(cell *gc_roots_base, cell gc_roots_size, factor_vm *myvm);

}
