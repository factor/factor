namespace factor
{

	// if you change this struct, also change vm.factor k--------
	extern "C" context *stack_chain; 
	extern "C" zone nursery; /* new objects are allocated here */
	extern "C" cell cards_offset;
	extern "C" cell decks_offset;
//extern "C" cell userenv[USER_ENV]; /* TAGGED user environment data; see getenv/setenv prims */

	// -------------------------------

	// contexts
	extern "C" cell ds_size, rs_size;
	extern "C" context *unused_contexts;


	// profiler
	extern "C" bool profiling_p;

	// errors
	/* Global variables used to pass fault handler state from signal handler to
	   user-space */
	extern "C" cell signal_number;
	extern "C" cell signal_fault_addr;
	extern "C" unsigned int signal_fpu_status;
	extern "C" stack_frame *signal_callstack_top;

	//data_heap
	extern "C" bool secure_gc;  /* Set by the -securegc command line argument */
	extern "C" bool gc_off; /* GC is off during heap walking */
	extern "C" data_heap *data;
	/* A heap walk allows useful things to be done, like finding all
	   references to an object for debugging purposes. */
	extern "C" cell heap_scan_ptr;
	//write barrier
	extern "C" cell allot_markers_offset;
	//data_gc
	/* used during garbage collection only */
	extern "C" zone *newspace;
	extern "C" bool performing_gc;
	extern "C" bool performing_compaction;
	extern "C" cell collecting_gen;
	/* if true, we are collecting aging space for the second time, so if it is still
	   full, we go on to collect tenured */
	extern "C" bool collecting_aging_again;
	/* in case a generation fills up in the middle of a gc, we jump back
	   up to try collecting the next generation. */
	extern "C" jmp_buf gc_jmp;
	extern "C" gc_stats stats[max_gen_count];
	extern "C" u64 cards_scanned;
	extern "C" u64 decks_scanned;
	extern "C" u64 card_scan_time;
	extern "C" cell code_heap_scans;
	/* What generation was being collected when copy_code_heap_roots() was last
	   called? Until the next call to add_code_block(), future
	   collections of younger generations don't have to touch the code
	   heap. */
	extern "C" cell last_code_heap_scan;
	/* sometimes we grow the heap */
	extern "C" bool growing_data_heap;
	extern "C" data_heap *old_data_heap;

	// local roots
	/* If a runtime function needs to call another function which potentially
	   allocates memory, it must wrap any local variable references to Factor
	   objects in gc_root instances */
	//extern "C" segment *gc_locals_region;
	//extern "C" cell gc_locals;
	//extern "C" segment *gc_bignums_region;
	//extern "C" cell gc_bignums;

	//debug
	extern "C" bool fep_disabled;
	extern "C" bool full_output;
	extern "C" cell look_for;
	extern "C" cell obj;

	//math
	extern "C" cell bignum_zero;
	extern "C" cell bignum_pos_one;
	extern "C" cell bignum_neg_one;	

    //code_heap
	extern "C" heap code;
	extern "C" unordered_map<heap_block *,char *> forwarding;

	//image
	extern "C" cell code_relocation_base;
	extern "C" cell data_relocation_base;

	//dispatch
	extern "C" cell megamorphic_cache_hits;
	extern "C" cell megamorphic_cache_misses;

	//inline cache
	extern "C" cell max_pic_size;
	extern "C" cell cold_call_to_ic_transitions;
	extern "C" cell ic_to_pic_transitions;
	extern "C" cell pic_to_mega_transitions;
	extern "C" cell pic_counts[4];  /* PIC_TAG, PIC_HI_TAG, PIC_TUPLE, PIC_HI_TAG_TUPLE */

struct factorvmdata {
	cell userenv[USER_ENV]; /* TAGGED user environment data; see getenv/setenv prims */

	// run
	cell T;  /* Canonical T object. It's just a word */

	// local roots
	/* If a runtime function needs to call another function which potentially
	   allocates memory, it must wrap any local variable references to Factor
	   objects in gc_root instances */
	std::vector<cell> gc_locals;
	std::vector<cell> gc_bignums;
};
}
