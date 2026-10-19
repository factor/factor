// Publication-only gate: global CAS/RMW lock-free capability is unchanged.
extern "C" unsigned char m88k_publication_load8(volatile unsigned char *p) {
    return __atomic_load_n(p, __ATOMIC_SEQ_CST);
}
extern "C" void m88k_publication_store8(volatile unsigned char *p, unsigned char v) {
    __atomic_store_n(p, v, __ATOMIC_SEQ_CST);
}
extern "C" unsigned m88k_publication_load32(volatile unsigned *p) {
    return __atomic_load_n(p, __ATOMIC_SEQ_CST);
}
extern "C" void m88k_publication_store32(volatile unsigned *p, unsigned v) {
    __atomic_store_n(p, v, __ATOMIC_SEQ_CST);
}
