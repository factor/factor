/* Native self-check for the independent compiler ABI fixture. */
#include "fixture.c"
#include <assert.h>
#include <stdio.h>
int main(void) {
    assert(call_narrow(abi_narrow) == 40147957488.0);
    assert(call_floats(abi_floats) == 506.0);
    assert(call_mixed(abi_mixed) == -2610657.0);
    assert(call_struct(abi_struct) == 47.0);
    assert(call_hfa_boundary(abi_hfa_boundary) == 64.0);
    assert(call_int_boundary(abi_int_boundary) == 64.0);
    assert(call_array_hfa(abi_array_hfa) == 154.0);
    assert(abi_var(1, 2.5, -3, 4.25, -5LL, -4) == -35.0);
    assert(abi_var_spill(1,2,3,4,5,6,7,8,9,10,11,13.0) == 662.0);
    assert(abi_var_hfa((struct pair){1,2},(struct pair){3,4},5) == 55.0);
    assert(abi_var_array(1,(struct array_hfa){{1,2,3}},5.0) == 20.0);
    puts("11 native C oracle controls passed");
    return 0;
}
