/* C compiler oracle for the RISC-V ILP32D/LP64D mixed floating-point convention. */
#if defined(__riscv)
#include <stddef.h>
#include <stdint.h>
#include <sys/epoll.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/statvfs.h>
#include <unistd.h>
#define RV_EXPORT __attribute__((visibility("default"), noinline))

struct rv_bit_fp { unsigned int bits : 3; double number; };
struct __attribute__((packed)) rv_fp_bit { float number; signed int bits : 13; };
struct rv_fp_pair { float a; double b; };

RV_EXPORT double rv_take_bit_fp(struct rv_bit_fp value, long tail) {
  return value.bits + 2 * value.number + tail;
}
RV_EXPORT struct rv_bit_fp rv_return_bit_fp(unsigned int bits, double number) {
  struct rv_bit_fp value = { bits, number };
  return value;
}
RV_EXPORT double rv_call_bit_fp(double (*callback)(struct rv_bit_fp, long)) {
  struct rv_bit_fp value = { 7, 2.5 };
  return callback(value, 11);
}
RV_EXPORT double rv_call_return_bit_fp(struct rv_bit_fp (*callback)(unsigned int, double)) {
  struct rv_bit_fp value = callback(5, -3.0);
  return value.bits + 2 * value.number;
}
RV_EXPORT double rv_take_fp_bit(struct rv_fp_bit value, long tail) {
  return value.bits + 2 * value.number + tail;
}
RV_EXPORT struct rv_fp_bit rv_return_fp_bit(float number, int bits) {
  struct rv_fp_bit value = { number, bits };
  return value;
}
RV_EXPORT double rv_call_fp_bit(double (*callback)(struct rv_fp_bit, long)) {
  struct rv_fp_bit value = { 2.5f, -2047 };
  return callback(value, 11);
}
RV_EXPORT double rv_call_return_fp_bit(struct rv_fp_bit (*callback)(float, int)) {
  struct rv_fp_bit value = callback(-3.0f, -4095);
  return value.bits + 2 * value.number;
}
RV_EXPORT size_t rv_sizeof_nlink_t(void) { return sizeof(((struct stat*)0)->st_nlink); }
RV_EXPORT size_t rv_sizeof_blksize_t(void) { return sizeof(((struct stat*)0)->st_blksize); }
RV_EXPORT size_t rv_sizeof_epoll_event(void) { return sizeof(struct epoll_event); }
RV_EXPORT size_t rv_offsetof_epoll_data(void) { return offsetof(struct epoll_event, data); }
/* RISC-V's native statvfs already uses the 64-bit filesystem counters. */
RV_EXPORT size_t rv_sizeof_statvfs(void) { return sizeof(struct statvfs); }
RV_EXPORT size_t rv_offsetof_statvfs_flag(void) { return offsetof(struct statvfs, f_flag); }
RV_EXPORT size_t rv_offsetof_statvfs_namemax(void) { return offsetof(struct statvfs, f_namemax); }
RV_EXPORT unsigned long rv_statvfs_flag(const char* path) {
  struct statvfs value;
  return statvfs(path, &value) == 0 ? value.f_flag : (unsigned long)-1;
}
RV_EXPORT unsigned long rv_statvfs_namemax(const char* path) {
  struct statvfs value;
  return statvfs(path, &value) == 0 ? value.f_namemax : (unsigned long)-1;
}
RV_EXPORT long rv_call_stack_gc(void (*callback)(void),
                               long a0, long a1, long a2, long a3, long a4,
                               long a5, long a6, long a7, long a8) {
  callback();
  return a0 + a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8;
}
RV_EXPORT double rv_fp_pair_after_stack(long a0, long a1, long a2, long a3,
                                       long a4, long a5, long a6, long a7,
                                       long a8, long a9, struct rv_fp_pair value) {
  return a0 + a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9 + value.a + 2 * value.b;
}
RV_EXPORT double rv_call_fp_pair_after_stack(
    double (*callback)(long, long, long, long, long, long, long, long, long, long,
                       struct rv_fp_pair)) {
  struct rv_fp_pair value = { 2.5f, -3.0 };
  return callback(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, value);
}

/* Exact-size foreign allocations must not be rounded up to XLEN. The next
   page is inaccessible so even a single trailing load or store faults. */
RV_EXPORT void* rv_guard_alloc(size_t size) {
  size_t page = (size_t)sysconf(_SC_PAGESIZE);
  if (size == 0 || size > page) return NULL;
  unsigned char* base = mmap(NULL, 2 * page, PROT_READ | PROT_WRITE,
                             MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  if (base == MAP_FAILED) return NULL;
  if (mprotect(base + page, page, PROT_NONE) != 0) {
    munmap(base, 2 * page);
    return NULL;
  }
  unsigned char* result = base + page - size;
  for (size_t i = 0; i < size; ++i) result[i] = (unsigned char)(i + 1);
  return result;
}

RV_EXPORT void rv_guard_free(void* pointer) {
  uintptr_t page = (uintptr_t)sysconf(_SC_PAGESIZE);
  munmap((void*)((uintptr_t)pointer & ~(page - 1)), 2 * page);
}

#define RV_BYTE_STRUCT(N) \
  struct __attribute__((packed)) rv_bytes##N { unsigned char bytes[N]; }; \
  RV_EXPORT unsigned int rv_take_bytes##N(struct rv_bytes##N value) { \
    unsigned int sum = 0; \
    for (size_t i = 0; i < N; ++i) sum += value.bytes[i]; \
    ((volatile struct rv_bytes##N*)&value)->bytes[0] = 99; \
    return sum; \
  } \
  RV_EXPORT struct rv_bytes##N rv_return_bytes##N(void) { \
    struct rv_bytes##N value; \
    for (size_t i = 0; i < N; ++i) value.bytes[i] = (unsigned char)(i + 1); \
    return value; \
  } \
  RV_EXPORT unsigned int rv_call_bytes##N( \
      unsigned int (*callback)(struct rv_bytes##N), void* pointer) { \
    return callback(*(struct rv_bytes##N*)pointer); \
  } \
  RV_EXPORT unsigned int rv_call_return_bytes##N( \
      struct rv_bytes##N (*callback)(void)) { \
    struct rv_bytes##N value = callback(); \
    return rv_take_bytes##N(value); \
  }

RV_BYTE_STRUCT(3)
RV_BYTE_STRUCT(5)
RV_BYTE_STRUCT(9)
RV_BYTE_STRUCT(17)
#undef RV_BYTE_STRUCT

/* Both ABIs return 17-byte structs through a hidden a0 destination. Calling
   that lowered signature puts the callback's destination at the guard page. */
RV_EXPORT void rv_call_guarded_return(void (*callback)(void*), void* pointer) {
  callback(pointer);
}
#undef RV_EXPORT
#endif
