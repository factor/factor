/* Native guest foundation only: this does not test the Factor VM. */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
int main(void) {
    uint32_t endian = 0x01020304;
    volatile uint64_t x = UINT64_C(0x123456789abcdef0);
    volatile double d = 1.25;
    char data[32] = {0};
    FILE *f = tmpfile();
    if (!f || fwrite("native-bsd-file-io", 1, 18, f) != 18 || fflush(f)) return 1;
    rewind(f);
    if (fread(data, 1, 18, f) != 18 || memcmp(data, "native-bsd-file-io", 18)) return 2;
    fclose(f);
    if (x / 7 != UINT64_C(0x0299c335ccf668fd) || fabs(d * 2.5 - 3.125) > 1e-12) return 3;
    printf("NATIVE_FOUNDATION_PASS pointer_bits=%zu endian=%s integer=PASS fp=PASS file_io=PASS\n", sizeof(void *) * 8, *(unsigned char *)&endian == 1 ? "big" : "little");
    return 0;
}
