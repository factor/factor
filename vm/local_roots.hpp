namespace factor
{

template<typename Type>
struct gc_root : public tagged<Type>
{
	factor_vm *parent;

	void push() { parent->check_tagged_pointer(tagged<Type>::value()); parent->gc_locals.push_back((cell)this); }
	
	explicit gc_root(cell value_,factor_vm *vm) : tagged<Type>(value_),parent(vm) { push(); }
	explicit gc_root(Type *value_, factor_vm *vm) : tagged<Type>(value_),parent(vm) { push(); }

	const gc_root<Type>& operator=(const Type *x) { tagged<Type>::operator=(x); return *this; }
	const gc_root<Type>& operator=(const cell &x) { tagged<Type>::operator=(x); return *this; }

	~gc_root() {
#ifdef FACTOR_DEBUG
		assert(parent->gc_locals.back() == (cell)this);
#endif
		parent->gc_locals.pop_back();
	}
};

/* A similar hack for the bignum implementation */
struct gc_bignum
{
	bignum **addr;
	factor_vm *parent;
	gc_bignum(bignum **addr_, factor_vm *vm) : addr(addr_), parent(vm) {
		if(*addr_)
			parent->check_data_pointer(*addr_);
		parent->gc_bignums.push_back((cell)addr);
	}

	~gc_bignum() {
#ifdef FACTOR_DEBUG
		assert(parent->gc_bignums.back() == (cell)addr);
#endif
		parent->gc_bignums.pop_back();
	}
};

#define GC_BIGNUM(x) gc_bignum x##__gc_root(&x,this)

}
