#include <stdio.h>
extern int m88k_sjlj_acceptance(int);
extern int m88k_cxx17_exceptions(int);
int main(void) {
    const int inputs[] = { 42, 43, 0, -7, 1234 };
    unsigned i;
    int failed = 0;
    for (i = 0; i < sizeof(inputs) / sizeof(inputs[0]); ++i) {
        int result = m88k_sjlj_acceptance(inputs[i]);
        printf("m88k SjLj poison input=%d errors=%d\n", inputs[i], result);
        failed |= result;
    }
    if (m88k_cxx17_exceptions(0) != 0 || m88k_cxx17_exceptions(42) != 42)
        failed |= 64;
    printf("m88k SjLj %s\n", failed ? "FAIL" : "PASS");
    return failed != 0;
}
