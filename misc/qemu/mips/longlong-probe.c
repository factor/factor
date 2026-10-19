#include <stdint.h>
int64_t signed_identity(int64_t n) { return n; }
uint64_t unsigned_identity(uint64_t n) { return n; }
int64_t negative_value(void) { return -INT64_C(1099511627776) + 7; }
int64_t signed_pair(int marker, int64_t x, int64_t y) { return x + y + marker; }
