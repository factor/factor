#include <stdio.h>
extern int m88k_commute_both_zero(void), m88k_commute_both(void);
extern int m88k_commute_left(int), m88k_commute_right(int);
extern unsigned long long m88k_commute_wide(unsigned, unsigned);
int main(void) {
    int values[] = { 0, 1, -1, 42, -7, 1234 };
    unsigned i;
    if (m88k_commute_both_zero() != 0 || m88k_commute_both() != 12) return 1;
    for (i = 0; i < sizeof(values)/sizeof(values[0]); ++i)
        if (m88k_commute_left(values[i]) != (7 ^ values[i]) ||
            m88k_commute_right(values[i]) != (values[i] ^ 7)) return 2;
    if (m88k_commute_wide(0x12345678u, 0xabcdef01u) !=
        (unsigned long long)(0x12345678u ^ 0xabcdef01u)) return 3;
    puts("m88k constant commutation gate PASS: both-zero both-distinct left right");
    return 0;
}
