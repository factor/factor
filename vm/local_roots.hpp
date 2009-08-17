namespace factor
{

struct factorvm;

template <typename TYPE>
struct gc_root : public tagged<TYPE>
{
	factorvm *myvm;

	void push() { check_tagged_pointer(tagged<TYPE>::value()); myvm->gc_locals.push_back((cell)this); }
	
	//explicit gc_root(cell value_, factorvm *vm) : myvm(vm),tagged<TYPE>(value_) { push(); }
	explicit gc_root(cell value_,factorvm *vm) : tagged<TYPE>(value_),myvm(vm) { push(); }
	explicit gc_root(TYPE *value_, factorvm *vm) : tagged<TYPE>(value_),myvm(vm) { push(); }

	const gc_root<TYPE>& operator=(const TYPE *x) { tagged<TYPE>::operator=(x); return *this; }
	const gc_root<TYPE>& operator=(const cell &x) { tagged<TYPE>::operator=(x); return *this; }

	~gc_root() {
#ifdef FACTOR_DEBUG
		assert(myvm->gc_locals.back() == (cell)this);
#endif
		myvm->gc_locals.pop_back();
	}
};

/* A similar hack for the bignum implementation */
struct gc_bignum
{
	bignum **addr;
	factorvm *myvm;
	gc_bignum(bignum **addr_, factorvm *vm) : addr(addr_), myvm(vm) {
		if(*addr_)
			check_data_pointer(*addr_);
		myvm->gc_bignums.push_back((cell)addr);
	}

	~gc_bignum() {
#ifdef FACTOR_DEBUG
		assert(myvm->gc_bignums.back() == (cell)addr);
#endif
		myvm->gc_bignums.pop_back();
	}
};

#define GC_BIGNUM(x,vm) gc_bignum x##__gc_root(&x,vm)

}
