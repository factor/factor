namespace factor
{

struct code_heap : heap {
	/* What generation was being collected when trace_code_heap_roots() was last
	   called? Until the next call to add_code_block(), future
	   collections of younger generations don't have to touch the code
	   heap. */
	cell last_code_heap_scan;
	
	explicit code_heap(factor_vm *myvm, cell size);
};

}
