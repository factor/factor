extern "C" unsigned locked_add(unsigned *p,unsigned x) {return __atomic_fetch_add(p,x,__ATOMIC_SEQ_CST);}
extern "C" unsigned locked_sub(unsigned *p,unsigned x) {return __atomic_fetch_sub(p,x,__ATOMIC_ACQ_REL);}
extern "C" unsigned locked_and(unsigned *p,unsigned x) {return __atomic_fetch_and(p,x,__ATOMIC_RELAXED);}
extern "C" unsigned locked_or(unsigned *p,unsigned x) {return __atomic_fetch_or(p,x,__ATOMIC_RELEASE);}
extern "C" unsigned locked_xor(unsigned *p,unsigned x) {return __atomic_fetch_xor(p,x,__ATOMIC_ACQUIRE);}
extern "C" unsigned locked_exchange(unsigned *p,unsigned x) {return __atomic_exchange_n(p,x,__ATOMIC_SEQ_CST);}
extern "C" bool locked_cas(unsigned *p,unsigned *expected,unsigned desired) {return __atomic_compare_exchange_n(p,expected,desired,false,__ATOMIC_SEQ_CST,__ATOMIC_SEQ_CST);}
#if __has_feature(cxx_thread_local)
#error Unsupported TLS must not be advertised
#endif
