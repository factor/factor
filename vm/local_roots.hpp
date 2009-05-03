/* If a runtime function needs to call another function which potentially
allocates memory, it must wrap any local variable references to Factor
objects in gc_root instances */
extern F_SEGMENT *gc_locals_region;
extern CELL gc_locals;

DEFPUSHPOP(gc_local_,gc_locals)

template <typename T>
struct gc_root : public tagged<T>
{
	void push() { gc_local_push((CELL)this); }
	
	explicit gc_root(CELL value_) : tagged<T>(value_) { push(); }
	explicit gc_root(T *value_) : tagged<T>(value_) { push(); }

	const gc_root<T>& operator=(const T *x) { tagged<T>::operator=(x); return *this; }
	const gc_root<T>& operator=(const CELL &x) { tagged<T>::operator=(x); return *this; }

	~gc_root() { CELL old = gc_local_pop(); assert(old == (CELL)this); }
};

/* A similar hack for the bignum implementation */
extern F_SEGMENT *gc_bignums_region;
extern CELL gc_bignums;

DEFPUSHPOP(gc_bignum_,gc_bignums)

struct gc_bignum
{
	F_BIGNUM **addr;

	gc_bignum(F_BIGNUM **addr_) : addr(addr_) { if(*addr_) check_data_pointer((CELL)*addr_); gc_bignum_push((CELL)addr); }
	~gc_bignum() { assert((CELL)addr == gc_bignum_pop()); }
};

#define GC_BIGNUM(x) gc_bignum x##__gc_root(&x)
