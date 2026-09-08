#include <stdio.h>
struct float_array { float values[3]; };
struct float_array ffi_array_struct(struct float_array x);
#ifndef ABI_CONTROL
struct float_array ffi_array_struct(struct float_array x) {
    x.values[0] += 10; x.values[1] += 20; x.values[2] += 30;
    return x;
}
#else
int main(void) {
    struct float_array result = ffi_array_struct((struct float_array){{1,2,3}});
    printf("array-struct=%g,%g,%g\n", result.values[0], result.values[1], result.values[2]);
    return result.values[0] != 11 || result.values[1] != 22 || result.values[2] != 33;
}
#endif
