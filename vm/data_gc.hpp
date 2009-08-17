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

PRIMITIVE(gc);
PRIMITIVE(gc_stats);
PRIMITIVE(clear_gc_stats);
PRIMITIVE(become);

VM_ASM_API void inline_gc(cell *gc_roots_base, cell gc_roots_size);

}
