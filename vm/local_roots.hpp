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

/* Extra roots: stores pointers to objects in the heap. Requires extra work
(you have to unregister before accessing the object) but more flexible. */
extern F_SEGMENT *extra_roots_region;
extern CELL extra_roots;

DEFPUSHPOP(root_,extra_roots)

#define REGISTER_BIGNUM(obj) if(obj) root_push(tag_bignum(obj))
#define UNREGISTER_BIGNUM(obj) if(obj) obj = (untag_bignum_fast(root_pop()))
