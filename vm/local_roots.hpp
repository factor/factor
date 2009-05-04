namespace factor
{

/* If a runtime function needs to call another function which potentially
allocates memory, it must wrap any local variable references to Factor
objects in gc_root instances */
extern segment *gc_locals_region;
extern cell gc_locals;

DEFPUSHPOP(gc_local_,gc_locals)

template <typename T>
struct gc_root : public tagged<T>
{
	void push() { gc_local_push((cell)this); }
	
	explicit gc_root(cell value_) : tagged<T>(value_) { push(); }
	explicit gc_root(T *value_) : tagged<T>(value_) { push(); }

	const gc_root<T>& operator=(const T *x) { tagged<T>::operator=(x); return *this; }
	const gc_root<T>& operator=(const cell &x) { tagged<T>::operator=(x); return *this; }

	~gc_root() {
#ifdef FACTOR_DEBUG
		cell old = gc_local_pop();
		assert(old == (cell)this);
#else
		gc_local_pop();
#endif
	}
};

/* A similar hack for the bignum implementation */
extern segment *gc_bignums_region;
extern cell gc_bignums;

DEFPUSHPOP(gc_bignum_,gc_bignums)

struct gc_bignum
{
	bignum **addr;

	gc_bignum(bignum **addr_) : addr(addr_) {
		if(*addr_)
			check_data_pointer(*addr_);
		gc_bignum_push((cell)addr);
	}

	~gc_bignum() { assert((cell)addr == gc_bignum_pop()); }
};

#define GC_BIGNUM(x) gc_bignum x##__gc_root(&x)

}
