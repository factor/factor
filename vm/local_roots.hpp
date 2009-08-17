namespace factor
{

struct factorvm;

template <typename T>
struct gc_root : public tagged<T>
{
	void push() { check_tagged_pointer(tagged<T>::value()); vm->gc_locals.push_back((cell)this); }
	
	//explicit gc_root(cell value_, factorvm *vm) : myvm(vm),tagged<T>(value_) { push(); }
	explicit gc_root(cell value_) : tagged<T>(value_) { push(); }
	explicit gc_root(T *value_) : tagged<T>(value_) { push(); }

	const gc_root<T>& operator=(const T *x) { tagged<T>::operator=(x); return *this; }
	const gc_root<T>& operator=(const cell &x) { tagged<T>::operator=(x); return *this; }

	~gc_root() {
#ifdef FACTOR_DEBUG
		assert(vm->gc_locals.back() == (cell)this);
#endif
		vm->gc_locals.pop_back();
	}
};

/* A similar hack for the bignum implementation */
struct gc_bignum
{
	bignum **addr;
	factorvm *myvm;
	//gc_bignum(bignum **addr_, factorvm *vm) : addr(addr_), myvm(vm) {
	gc_bignum(bignum **addr_) : addr(addr_), myvm(vm) {
		if(*addr_)
			check_data_pointer(*addr_);
		vm->gc_bignums.push_back((cell)addr);
	}

	~gc_bignum() {
#ifdef FACTOR_DEBUG
		assert(vm->gc_bignums.back() == (cell)addr);
#endif
		vm->gc_bignums.pop_back();
	}
};

#define GC_BIGNUM(x) gc_bignum x##__gc_root(&x)

}
