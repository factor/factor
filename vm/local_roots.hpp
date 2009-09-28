namespace factor
{

//local_roots.hpp
template <typename TYPE>
struct gc_root : public tagged<TYPE>
{
	factor_vm *parent_vm;

	void push() { parent_vm->check_tagged_pointer(tagged<TYPE>::value()); parent_vm->gc_locals.push_back((cell)this); }
	
	explicit gc_root(cell value_,factor_vm *vm) : tagged<TYPE>(value_),parent_vm(vm) { push(); }
	explicit gc_root(TYPE *value_, factor_vm *vm) : tagged<TYPE>(value_),parent_vm(vm) { push(); }

	const gc_root<TYPE>& operator=(const TYPE *x) { tagged<TYPE>::operator=(x); return *this; }
	const gc_root<TYPE>& operator=(const cell &x) { tagged<TYPE>::operator=(x); return *this; }

	~gc_root() {
#ifdef FACTOR_DEBUG
		assert(myvm->gc_locals.back() == (cell)this);
#endif
		parent_vm->gc_locals.pop_back();
	}
};

/* A similar hack for the bignum implementation */
struct gc_bignum
{
	bignum **addr;
	factor_vm *parent_vm;
	gc_bignum(bignum **addr_, factor_vm *vm) : addr(addr_), parent_vm(vm) {
		if(*addr_)
			parent_vm->check_data_pointer(*addr_);
		parent_vm->gc_bignums.push_back((cell)addr);
	}

	~gc_bignum() {
#ifdef FACTOR_DEBUG
		assert(myvm->gc_bignums.back() == (cell)addr);
#endif
		parent_vm->gc_bignums.pop_back();
	}
};

#define GC_BIGNUM(x) gc_bignum x##__gc_root(&x,this)

}
