namespace factor
{

template<typename Type>
struct data_root : public tagged<Type> {
	factor_vm *parent;

	void push()
	{
		parent->data_roots.push_back((cell)this);
		parent->data_roots.push_back(1);
	}

	explicit data_root(cell value_, factor_vm *parent_)
		: tagged<Type>(value_), parent(parent_)
	{
		push();
	}

	explicit data_root(Type *value_, factor_vm *parent_) :
		tagged<Type>(value_), parent(parent_)
	{
		push();
	}

	const data_root<Type>& operator=(const Type *x) { tagged<Type>::operator=(x); return *this; }
	const data_root<Type>& operator=(const cell &x) { tagged<Type>::operator=(x); return *this; }

	~data_root()
	{
#ifdef FACTOR_DEBUG
		assert(parent->data_roots.back() == 1);
#endif
		parent->data_roots.pop_back();
#ifdef FACTOR_DEBUG
		assert(parent->data_roots.back() == (cell)this);
#endif
		parent->data_roots.pop_back();
	}
};

/* A similar hack for the bignum implementation */
struct gc_bignum {
	bignum **addr;
	factor_vm *parent;

	gc_bignum(bignum **addr_, factor_vm *parent_) : addr(addr_), parent(parent_)
	{
		if(*addr_) parent->check_data_pointer(*addr_);
		parent->bignum_roots.push_back((cell)addr);
	}

	~gc_bignum()
	{
#ifdef FACTOR_DEBUG
		assert(parent->bignum_roots.back() == (cell)addr);
#endif
		parent->bignum_roots.pop_back();
	}
};

#define GC_BIGNUM(x) gc_bignum x##__data_root(&x,this)

}
