namespace factor {
namespace atomic {
FACTOR_FORCE_INLINE static bool load(volatile bool* ptr) {
  atomic::fence();
  return *ptr;
}
FACTOR_FORCE_INLINE static cell load(volatile cell* ptr) {
  atomic::fence();
  return *ptr;
}

FACTOR_FORCE_INLINE static fixnum load(volatile fixnum* ptr) {
  atomic::fence();
  return *ptr;
}

FACTOR_FORCE_INLINE static void store(volatile bool* ptr, bool val) {
  *ptr = val;
  atomic::fence();
}

FACTOR_FORCE_INLINE static void store(volatile cell* ptr, cell val) {
  *ptr = val;
  atomic::fence();
}

FACTOR_FORCE_INLINE static void store(volatile fixnum* ptr, fixnum val) {
  *ptr = val;
  atomic::fence();
}
}
}
