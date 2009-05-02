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

#define BIGNUM_OUT_OF_BAND ((F_BIGNUM *) 0)

enum bignum_comparison
{
  bignum_comparison_equal = 0,
  bignum_comparison_less = -1,
  bignum_comparison_greater = 1
};

int bignum_equal_p(F_BIGNUM *, F_BIGNUM *);
enum bignum_comparison bignum_compare(F_BIGNUM *, F_BIGNUM *);
F_BIGNUM * bignum_add(F_BIGNUM *, F_BIGNUM *);
F_BIGNUM * bignum_subtract(F_BIGNUM *, F_BIGNUM *);
F_BIGNUM * bignum_negate(F_BIGNUM *);
F_BIGNUM * bignum_multiply(F_BIGNUM *, F_BIGNUM *);
void
bignum_divide(F_BIGNUM * numerator, F_BIGNUM * denominator,
		  F_BIGNUM * * quotient, F_BIGNUM * * remainder);
F_BIGNUM * bignum_quotient(F_BIGNUM *, F_BIGNUM *);
F_BIGNUM * bignum_remainder(F_BIGNUM *, F_BIGNUM *);
F_BIGNUM * fixnum_to_bignum(F_FIXNUM);
F_BIGNUM * cell_to_bignum(CELL);
F_BIGNUM * long_long_to_bignum(s64 n);
F_BIGNUM * ulong_long_to_bignum(u64 n);
F_FIXNUM bignum_to_fixnum(F_BIGNUM *);
CELL bignum_to_cell(F_BIGNUM *);
s64 bignum_to_long_long(F_BIGNUM *);
u64 bignum_to_ulong_long(F_BIGNUM *);
F_BIGNUM * double_to_bignum(double);
double bignum_to_double(F_BIGNUM *);

/* Added bitwise operators. */

F_BIGNUM * bignum_bitwise_not(F_BIGNUM *);
F_BIGNUM * bignum_arithmetic_shift(F_BIGNUM *, F_FIXNUM);
F_BIGNUM * bignum_bitwise_and(F_BIGNUM *, F_BIGNUM *);
F_BIGNUM * bignum_bitwise_ior(F_BIGNUM *, F_BIGNUM *);
F_BIGNUM * bignum_bitwise_xor(F_BIGNUM *, F_BIGNUM *);

/* Forward references */
int bignum_equal_p_unsigned(F_BIGNUM *, F_BIGNUM *);
enum bignum_comparison bignum_compare_unsigned(F_BIGNUM *, F_BIGNUM *);
F_BIGNUM * bignum_add_unsigned(F_BIGNUM *, F_BIGNUM *, int);
F_BIGNUM * bignum_subtract_unsigned(F_BIGNUM *, F_BIGNUM *);
F_BIGNUM * bignum_multiply_unsigned(F_BIGNUM *, F_BIGNUM *, int);
F_BIGNUM * bignum_multiply_unsigned_small_factor
  (F_BIGNUM *, bignum_digit_type, int);
void bignum_destructive_scale_up(F_BIGNUM *, bignum_digit_type);
void bignum_destructive_add(F_BIGNUM *, bignum_digit_type);
void bignum_divide_unsigned_large_denominator
  (F_BIGNUM *, F_BIGNUM *, F_BIGNUM * *, F_BIGNUM * *, int, int);
void bignum_destructive_normalization(F_BIGNUM *, F_BIGNUM *, int);
void bignum_destructive_unnormalization(F_BIGNUM *, int);
void bignum_divide_unsigned_normalized(F_BIGNUM *, F_BIGNUM *, F_BIGNUM *);
bignum_digit_type bignum_divide_subtract
  (bignum_digit_type *, bignum_digit_type *, bignum_digit_type,
   bignum_digit_type *);
void bignum_divide_unsigned_medium_denominator
  (F_BIGNUM *, bignum_digit_type, F_BIGNUM * *, F_BIGNUM * *, int, int);
bignum_digit_type bignum_digit_divide
  (bignum_digit_type, bignum_digit_type, bignum_digit_type, bignum_digit_type *);
bignum_digit_type bignum_digit_divide_subtract
  (bignum_digit_type, bignum_digit_type, bignum_digit_type, bignum_digit_type *);
void bignum_divide_unsigned_small_denominator
  (F_BIGNUM *, bignum_digit_type, F_BIGNUM * *, F_BIGNUM * *, int, int);
bignum_digit_type bignum_destructive_scale_down
  (F_BIGNUM *, bignum_digit_type);
F_BIGNUM * bignum_remainder_unsigned_small_denominator
  (F_BIGNUM *, bignum_digit_type, int);
F_BIGNUM * bignum_digit_to_bignum(bignum_digit_type, int);
F_BIGNUM * allot_bignum(bignum_length_type, int);
F_BIGNUM * allot_bignum_zeroed(bignum_length_type, int);
F_BIGNUM * bignum_shorten_length(F_BIGNUM *, bignum_length_type);
F_BIGNUM * bignum_trim(F_BIGNUM *);
F_BIGNUM * bignum_new_sign(F_BIGNUM *, int);
F_BIGNUM * bignum_maybe_new_sign(F_BIGNUM *, int);
void bignum_destructive_copy(F_BIGNUM *, F_BIGNUM *);

/* Added for bitwise operations. */
F_BIGNUM * bignum_magnitude_ash(F_BIGNUM * arg1, F_FIXNUM n);
F_BIGNUM * bignum_pospos_bitwise_op(int op, F_BIGNUM *, F_BIGNUM *);
F_BIGNUM * bignum_posneg_bitwise_op(int op, F_BIGNUM *, F_BIGNUM *);
F_BIGNUM * bignum_negneg_bitwise_op(int op, F_BIGNUM *, F_BIGNUM *);
void        bignum_negate_magnitude(F_BIGNUM *);

F_BIGNUM * bignum_integer_length(F_BIGNUM * arg1);
int bignum_unsigned_logbitp(int shift, F_BIGNUM * bignum);
int bignum_logbitp(int shift, F_BIGNUM * arg);
F_BIGNUM * digit_stream_to_bignum(unsigned int n_digits,
                                   unsigned int (*producer)(unsigned int),
                                   unsigned int radix,
                                   int negative_p);
