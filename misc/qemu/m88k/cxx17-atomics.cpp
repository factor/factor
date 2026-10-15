// These widths are used by VM signal handlers and safepoint publication.
static_assert(__atomic_always_lock_free(1, nullptr), "flag atomics must be lock free");
static_assert(__atomic_always_lock_free(4, nullptr), "cell atomics must be lock free");
extern "C" unsigned m88k_cxx17_atomic_load(volatile unsigned *cell) {
    return __atomic_load_n(cell, __ATOMIC_SEQ_CST);
}
extern "C" void m88k_cxx17_atomic_store(volatile unsigned *cell, unsigned value) {
    __atomic_store_n(cell, value, __ATOMIC_SEQ_CST);
}
extern "C" bool m88k_cxx17_atomic_cas(volatile unsigned *cell, unsigned old_value, unsigned new_value) {
    return __sync_bool_compare_and_swap(cell, old_value, new_value);
}
