#include "../ffi_test_arm64.h"
#include <stdio.h>
#include <stddef.h>
#define CHECK(expr, expected) do { double value = (expr); ++cases; if (value != (expected)) { fprintf(stderr, "%s: %.17g != %.17g\n", #expr, value, (double)(expected)); return 1; } } while (0)
int main(void) {
    int cases = 0;
    CHECK(call_narrow(abi_narrow), 40147957488.0);
    CHECK(call_floats(abi_floats), 506);
    CHECK(call_mixed(abi_mixed), -2610657);
    CHECK(abi_var(1, 2.5, -3, 4.25, -5LL, -4), -35);
    CHECK(abi_var_spill(1,2,3,4,5,6,7,8,9,10,11,13.0), 662);
    CHECK(abi_var_hfa((struct pair){1,2}, (struct pair){3,4}, 5), 55);
    CHECK(call_struct(abi_struct), 47);
    CHECK(call_hfa_boundary(abi_hfa_boundary), 64);
    CHECK(call_array_hfa(abi_array_hfa), 154);
    CHECK(abi_var_array(1, (struct array_hfa){{1,2,3}}, 5.0), 20);
    CHECK(call_int_boundary(abi_int_boundary), 64);
    CHECK(abi_hfa_stack(1,2,3,4,5,6,7,8,1,2,3,4,5,6,7,8,-9,(struct pair){10,11},12), 107);
    printf("C-CONTROL general executed=%d\n", cases);
    printf("C-LAYOUT pair=%zu/%zu ints=%zu/%zu longs=%zu/%zu array_hfa=%zu/%zu pair.y=%zu\n",
        sizeof(struct pair), _Alignof(struct pair), sizeof(struct ints), _Alignof(struct ints),
        sizeof(struct longs), _Alignof(struct longs), sizeof(struct array_hfa), _Alignof(struct array_hfa), offsetof(struct pair,y));
    return 0;
}
