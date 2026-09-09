/* Include precisely the production export macro and outgoing definitions. */
#include "ffi_test.h"
#include "ffi_test_varargs_outgoing.c"
#include "ffi_test_varargs_promotions.c"
void *memcpy(void *, const void *, __SIZE_TYPE__);
#include "ffi_test_small.h"
