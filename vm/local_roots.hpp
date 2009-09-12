namespace factor
{

/* If a runtime function needs to call another function which potentially
allocates memory, it must wrap any local variable references to Factor
objects in gc_root instances */
extern std::vector<cell> gc_locals;

template <typename T>
struct gc_root : public tagged<T>
{
	void push() { check_tagged_pointer(tagged<T>::value()); gc_locals.push_back((cell)this); }
	
	explicit gc_root(cell value_) : tagged<T>(value_) { push(); }
	explicit gc_root(T *value_) : tagged<T>(value_) { push(); }

	const gc_root<T>& operator=(const T *x) { tagged<T>::operator=(x); return *this; }
	const gc_root<T>& operator=(const cell &x) { tagged<T>::operator=(x); return *this; }

	~gc_root() {
#ifdef FACTOR_DEBUG
		assert(gc_locals.back() == (cell)this);
#endif
		gc_locals.pop_back();
	}
};

/* A similar hack for the bignum implementation */
extern std::vector<cell> gc_bignums;

struct gc_bignum
{
	bignum **addr;

	gc_bignum(bignum **addr_) : addr(addr_) {
		if(*addr_)
			check_data_pointer(*addr_);
		gc_bignums.push_back((cell)addr);
	}

	~gc_bignum() {
#ifdef FACTOR_DEBUG
		assert(gc_bignums.back() == (cell)addr);
#endif
		gc_bignums.pop_back();
	}
};

#define GC_BIGNUM(x) gc_bignum x##__gc_root(&x)

}
