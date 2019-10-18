namespace factor
{

struct code_root {
	cell value;
	bool valid;
	factor_vm *parent;

	void push()
	{
		parent->code_roots.push_back(this);
	}

	explicit code_root(cell value_, factor_vm *parent_) :
		value(value_), valid(true), parent(parent_)
	{
		push();
	}

	~code_root()
	{
#ifdef FACTOR_DEBUG
		assert(parent->code_roots.back() == this);
#endif
		parent->code_roots.pop_back();
	}
};

}
