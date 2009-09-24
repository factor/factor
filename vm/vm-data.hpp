namespace factor
{

struct factor_vm_data {
	// if you change this struct, also change vm.factor k--------
	context *stack_chain; 
	zone nursery; /* new objects are allocated here */
	cell cards_offset;
	cell decks_offset;
	cell userenv[USER_ENV]; /* TAGGED user environment data; see getenv/setenv prims */

	// -------------------------------

	// contexts
	cell ds_size, rs_size;
	context *unused_contexts;

	// run
	cell T;  /* Canonical T object. It's just a word */

	// profiler
	bool profiling_p;

	// errors
	/* Global variables used to pass fault handler state from signal handler to
	   user-space */
	cell signal_number;
	cell signal_fault_addr;
	unsigned int signal_fpu_status;
	stack_frame *signal_callstack_top;

	//data_heap
	bool secure_gc;  /* Set by the -securegc command line argument */
	bool gc_off; /* GC is off during heap walking */
	data_heap *data;
	/* A heap walk allows useful things to be done, like finding all
	   references to an object for debugging purposes. */
	cell heap_scan_ptr;
	//write barrier
	cell allot_markers_offset;
	//data_gc
	/* used during garbage collection only */
	zone *newspace;
	bool performing_gc;
	bool performing_compaction;
	cell collecting_gen;
	/* if true, we are collecting aging space for the second time, so if it is still
	   full, we go on to collect tenured */
	bool collecting_aging_again;
	/* in case a generation fills up in the middle of a gc, we jump back
	   up to try collecting the next generation. */
	jmp_buf gc_jmp;
	gc_stats stats[max_gen_count];
	u64 cards_scanned;
	u64 decks_scanned;
	u64 card_scan_time;
	cell code_heap_scans;
	/* What generation was being collected when copy_code_heap_roots() was last
	   called? Until the next call to add_code_block(), future
	   collections of younger generations don't have to touch the code
	   heap. */
	cell last_code_heap_scan;
	/* sometimes we grow the heap */
	bool growing_data_heap;
	data_heap *old_data_heap;

	// local roots
	/* If a runtime function needs to call another function which potentially
	   allocates memory, it must wrap any local variable references to Factor
	   objects in gc_root instances */
	std::vector<cell> gc_locals;
	std::vector<cell> gc_bignums;

	//debug
	bool fep_disabled;
	bool full_output;
	cell look_for;
	cell obj;

	//math
	cell bignum_zero;
	cell bignum_pos_one;
	cell bignum_neg_one;	

	//code_heap
	heap code;
	unordered_map<heap_block *,char *> forwarding;

	//image
	cell code_relocation_base;
	cell data_relocation_base;

	//dispatch
	cell megamorphic_cache_hits;
	cell megamorphic_cache_misses;

	//inline cache
	cell max_pic_size;
	cell cold_call_to_ic_transitions;
	cell ic_to_pic_transitions;
	cell pic_to_mega_transitions;
	cell pic_counts[4];  /* PIC_TAG, PIC_HI_TAG, PIC_TUPLE, PIC_HI_TAG_TUPLE */

	factor_vm_data() 
		: profiling_p(false),
		  secure_gc(false),
		  gc_off(false),
		  performing_gc(false),
		  performing_compaction(false),
		  collecting_aging_again(false),
		  growing_data_heap(false),
		  fep_disabled(false),
		  full_output(false),
		  max_pic_size(0)
	{
		memset(this,0,sizeof(this)); // just to make sure
	}

};

}
