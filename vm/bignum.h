/* :tabSize=2:indentSize=2:noTabs=true:

Copyright (C) 1989-1992 Massachusetts Institute of Technology
Portions copyright (C) 2004-2007 Slava Pestov

This material was developed by the Scheme project at the Massachusetts
Institute of Technology, Department of Electrical Engineering and
Computer Science.  Permission to copy and modify this software, to
redistribute either the original software or a modified version, and
to use this software for any purpose is granted, subject to the
following restrictions and understandings.

1. Any copy made of this software must include this copyright notice
in full.

2. Users of this software agree to make their best efforts (a) to
return to the MIT Scheme project any improvements or extensions that
they make, so that these may be included in future releases; and (b)
to inform MIT of noteworthy uses of this software.

3. All materials developed as a consequence of the use of this
software shall duly acknowledge such use, in accordance with the usual
standards of acknowledging credit in academic research.

4. MIT has made no warrantee or representation that the operation of
this software will be error-free, and MIT is under no obligation to
provide any services, by way of maintenance, update, or otherwise.

5. In conjunction with products arising from the use of this material,
there shall be no use of the name of the Massachusetts Institute of
Technology nor of any adaptation thereof in any advertising,
promotional, or sales literature without prior written consent from
MIT in each case. */

typedef F_ARRAY * bignum_type;
#define BIGNUM_OUT_OF_BAND ((bignum_type) 0)

enum bignum_comparison
{
  bignum_comparison_equal = 0,
  bignum_comparison_less = -1,
  bignum_comparison_greater = 1
};

int bignum_equal_p(bignum_type, bignum_type);
enum bignum_comparison bignum_compare(bignum_type, bignum_type);
bignum_type bignum_add(bignum_type, bignum_type);
bignum_type bignum_subtract(bignum_type, bignum_type);
bignum_type bignum_negate(bignum_type);
bignum_type bignum_multiply(bignum_type, bignum_type);
void
bignum_divide(bignum_type numerator, bignum_type denominator,
		  bignum_type * quotient, bignum_type * remainder);
bignum_type bignum_quotient(bignum_type, bignum_type);
bignum_type bignum_remainder(bignum_type, bignum_type);
DLLEXPORT bignum_type fixnum_to_bignum(F_FIXNUM);
DLLEXPORT bignum_type cell_to_bignum(CELL);
DLLEXPORT bignum_type long_to_bignum(long);
DLLEXPORT bignum_type long_long_to_bignum(s64 n);
DLLEXPORT bignum_type ulong_long_to_bignum(u64 n);
DLLEXPORT bignum_type ulong_to_bignum(unsigned long);
F_FIXNUM bignum_to_fixnum(bignum_type);
CELL bignum_to_cell(bignum_type);
long bignum_to_long(bignum_type);
unsigned long bignum_to_ulong(bignum_type);
s64 bignum_to_long_long(bignum_type);
u64 bignum_to_ulong_long(bignum_type);
bignum_type double_to_bignum(double);
double bignum_to_double(bignum_type);

/* Added bitwise operators. */

DLLEXPORT bignum_type bignum_bitwise_not(bignum_type),
                   bignum_arithmetic_shift(bignum_type, long),
                   bignum_bitwise_and(bignum_type, bignum_type),
                   bignum_bitwise_ior(bignum_type, bignum_type),
                   bignum_bitwise_xor(bignum_type, bignum_type);

/* Forward references */
int bignum_equal_p_unsigned(bignum_type, bignum_type);
enum bignum_comparison bignum_compare_unsigned(bignum_type, bignum_type);
bignum_type bignum_add_unsigned(bignum_type, bignum_type, int);
bignum_type bignum_subtract_unsigned(bignum_type, bignum_type);
bignum_type bignum_multiply_unsigned(bignum_type, bignum_type, int);
bignum_type bignum_multiply_unsigned_small_factor
  (bignum_type, bignum_digit_type, int);
void bignum_destructive_scale_up(bignum_type, bignum_digit_type);
void bignum_destructive_add(bignum_type, bignum_digit_type);
void bignum_divide_unsigned_large_denominator
  (bignum_type, bignum_type, bignum_type *, bignum_type *, int, int);
void bignum_destructive_normalization(bignum_type, bignum_type, int);
void bignum_destructive_unnormalization(bignum_type, int);
void bignum_divide_unsigned_normalized(bignum_type, bignum_type, bignum_type);
bignum_digit_type bignum_divide_subtract
  (bignum_digit_type *, bignum_digit_type *, bignum_digit_type,
   bignum_digit_type *);
void bignum_divide_unsigned_medium_denominator
  (bignum_type, bignum_digit_type, bignum_type *, bignum_type *, int, int);
bignum_digit_type bignum_digit_divide
  (bignum_digit_type, bignum_digit_type, bignum_digit_type, bignum_digit_type *);
bignum_digit_type bignum_digit_divide_subtract
  (bignum_digit_type, bignum_digit_type, bignum_digit_type, bignum_digit_type *);
void bignum_divide_unsigned_small_denominator
  (bignum_type, bignum_digit_type, bignum_type *, bignum_type *, int, int);
bignum_digit_type bignum_destructive_scale_down
  (bignum_type, bignum_digit_type);
bignum_type bignum_remainder_unsigned_small_denominator
  (bignum_type, bignum_digit_type, int);
bignum_type bignum_digit_to_bignum(bignum_digit_type, int);
bignum_type allot_bignum(bignum_length_type, int);
bignum_type allot_bignum_zeroed(bignum_length_type, int);
bignum_type bignum_shorten_length(bignum_type, bignum_length_type);
bignum_type bignum_trim(bignum_type);
bignum_type bignum_new_sign(bignum_type, int);
bignum_type bignum_maybe_new_sign(bignum_type, int);
void bignum_destructive_copy(bignum_type, bignum_type);

/* Added for bitwise operations. */
bignum_type bignum_magnitude_ash(bignum_type arg1, long n);
bignum_type bignum_pospos_bitwise_op(int op, bignum_type, bignum_type);
bignum_type bignum_posneg_bitwise_op(int op, bignum_type, bignum_type);
bignum_type bignum_negneg_bitwise_op(int op, bignum_type, bignum_type);
void        bignum_negate_magnitude(bignum_type);

bignum_type bignum_integer_length(bignum_type arg1);
int bignum_unsigned_logbitp(int shift, bignum_type bignum);
int bignum_logbitp(int shift, bignum_type arg);
bignum_type digit_stream_to_bignum(unsigned int n_digits,
                                   unsigned int (*producer)(unsigned int),
                                   unsigned int radix,
                                   int negative_p);
