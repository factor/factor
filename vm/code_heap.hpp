namespace factor
{

inline void factor_vm::check_code_pointer(cell ptr)
{
#ifdef FACTOR_DEBUG
	assert(in_code_heap_p(ptr));
#endif
}

struct word_updater {
	factor_vm *myvm;

	explicit word_updater(factor_vm *myvm_) : myvm(myvm_) {}
	void operator()(code_block *compiled)
	{
		myvm->update_word_references(compiled);
	}
};

}
