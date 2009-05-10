namespace factor
{

/* :tabSize=2:indentSize=2:noTabs=true:

Copyright (C) 1989-1992 Massachusetts Institute of Technology
Portions copyright (C) 2004-2009 Slava Pestov

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

#define BIGNUM_OUT_OF_BAND ((bignum *) 0)

enum bignum_comparison
{
  bignum_comparison_equal = 0,
  bignum_comparison_less = -1,
  bignum_comparison_greater = 1
};

int bignum_equal_p(bignum *, bignum *);
enum bignum_comparison bignum_compare(bignum *, bignum *);
bignum * bignum_add(bignum *, bignum *);
bignum * bignum_subtract(bignum *, bignum *);
bignum * bignum_negate(bignum *);
bignum * bignum_multiply(bignum *, bignum *);
void
bignum_divide(bignum * numerator, bignum * denominator,
		  bignum * * quotient, bignum * * remainder);
bignum * bignum_quotient(bignum *, bignum *);
bignum * bignum_remainder(bignum *, bignum *);
bignum * fixnum_to_bignum(fixnum);
bignum * cell_to_bignum(cell);
bignum * long_long_to_bignum(s64 n);
bignum * ulong_long_to_bignum(u64 n);
fixnum bignum_to_fixnum(bignum *);
cell bignum_to_cell(bignum *);
s64 bignum_to_long_long(bignum *);
u64 bignum_to_ulong_long(bignum *);
bignum * double_to_bignum(double);
double bignum_to_double(bignum *);

/* Added bitwise operators. */

bignum * bignum_bitwise_not(bignum *);
bignum * bignum_arithmetic_shift(bignum *, fixnum);
bignum * bignum_bitwise_and(bignum *, bignum *);
bignum * bignum_bitwise_ior(bignum *, bignum *);
bignum * bignum_bitwise_xor(bignum *, bignum *);

/* Forward references */
int bignum_equal_p_unsigned(bignum *, bignum *);
enum bignum_comparison bignum_compare_unsigned(bignum *, bignum *);
bignum * bignum_add_unsigned(bignum *, bignum *, int);
bignum * bignum_subtract_unsigned(bignum *, bignum *);
bignum * bignum_multiply_unsigned(bignum *, bignum *, int);
bignum * bignum_multiply_unsigned_small_factor
  (bignum *, bignum_digit_type, int);
void bignum_destructive_scale_up(bignum *, bignum_digit_type);
void bignum_destructive_add(bignum *, bignum_digit_type);
void bignum_divide_unsigned_large_denominator
  (bignum *, bignum *, bignum * *, bignum * *, int, int);
void bignum_destructive_normalization(bignum *, bignum *, int);
void bignum_destructive_unnormalization(bignum *, int);
void bignum_divide_unsigned_normalized(bignum *, bignum *, bignum *);
bignum_digit_type bignum_divide_subtract
  (bignum_digit_type *, bignum_digit_type *, bignum_digit_type,
   bignum_digit_type *);
void bignum_divide_unsigned_medium_denominator
  (bignum *, bignum_digit_type, bignum * *, bignum * *, int, int);
bignum_digit_type bignum_digit_divide
  (bignum_digit_type, bignum_digit_type, bignum_digit_type, bignum_digit_type *);
bignum_digit_type bignum_digit_divide_subtract
  (bignum_digit_type, bignum_digit_type, bignum_digit_type, bignum_digit_type *);
void bignum_divide_unsigned_small_denominator
  (bignum *, bignum_digit_type, bignum * *, bignum * *, int, int);
bignum_digit_type bignum_destructive_scale_down
  (bignum *, bignum_digit_type);
bignum * bignum_remainder_unsigned_small_denominator
  (bignum *, bignum_digit_type, int);
bignum * bignum_digit_to_bignum(bignum_digit_type, int);
bignum * allot_bignum(bignum_length_type, int);
bignum * allot_bignum_zeroed(bignum_length_type, int);
bignum * bignum_shorten_length(bignum *, bignum_length_type);
bignum * bignum_trim(bignum *);
bignum * bignum_new_sign(bignum *, int);
bignum * bignum_maybe_new_sign(bignum *, int);
void bignum_destructive_copy(bignum *, bignum *);

/* Added for bitwise operations. */
bignum * bignum_magnitude_ash(bignum * arg1, fixnum n);
bignum * bignum_pospos_bitwise_op(int op, bignum *, bignum *);
bignum * bignum_posneg_bitwise_op(int op, bignum *, bignum *);
bignum * bignum_negneg_bitwise_op(int op, bignum *, bignum *);
void        bignum_negate_magnitude(bignum *);

bignum * bignum_integer_length(bignum * arg1);
int bignum_unsigned_logbitp(int shift, bignum * bignum);
int bignum_logbitp(int shift, bignum * arg);
bignum * digit_stream_to_bignum(unsigned int n_digits,
                                   unsigned int (*producer)(unsigned int),
                                   unsigned int radix,
                                   int negative_p);

}
