namespace factor
{

template<typename Type>
struct gc_root : public tagged<Type>
{
	factor_vm *parent_vm;

	void push() { parent_vm->check_tagged_pointer(tagged<Type>::value()); parent_vm->gc_locals.push_back((cell)this); }
	
	explicit gc_root(cell value_,factor_vm *vm) : tagged<Type>(value_),parent_vm(vm) { push(); }
	explicit gc_root(Type *value_, factor_vm *vm) : tagged<Type>(value_),parent_vm(vm) { push(); }

	const gc_root<Type>& operator=(const Type *x) { tagged<Type>::operator=(x); return *this; }
	const gc_root<Type>& operator=(const cell &x) { tagged<Type>::operator=(x); return *this; }

	~gc_root() {
#ifdef FACTOR_DEBUG
		assert(parent_vm->gc_locals.back() == (cell)this);
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
		assert(parent_vm->gc_bignums.back() == (cell)addr);
#endif
		parent_vm->gc_bignums.pop_back();
	}
};

#define GC_BIGNUM(x) gc_bignum x##__gc_root(&x,this)

}
