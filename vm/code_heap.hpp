namespace factor
{

inline void factor_vm::check_code_pointer(cell ptr)
{
#ifdef FACTOR_DEBUG
	assert(in_code_heap_p(ptr));
#endif
}

}
