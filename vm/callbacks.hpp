namespace factor
{

struct callback {
	cell size;
	code_block *compiled;
	void *code() { return (void *)(this + 1); }
};

struct callback_heap {
	segment *seg;
	cell here;
	factor_vm *myvm;

	explicit callback_heap(cell size, factor_vm *myvm);
	~callback_heap();

	callback *add(code_block *compiled);
	void update(callback *stub);

	callback *next(callback *stub)
	{
		return (callback *)((cell)stub + stub->size + sizeof(callback));
	}

	template<typename Iterator> void iterate(Iterator &iter)
	{
		callback *scan = (callback *)seg->start;
		callback *end = (callback *)here;
		while(scan < end)
		{
			iter(scan);
			scan = next(scan);
		}
	}
};

}
