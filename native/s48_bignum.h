/* -*-C-*-

$Id$

Copyright (c) 1989-1992 Massachusetts Institute of Technology

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

/* External Interface to Bignum Code */

/* The `unsigned long' type is used for the conversion procedures
   `bignum_to_long' and `long_to_bignum'.  Older implementations of C
   don't support this type; if you have such an implementation you can
   disable these procedures using the following flag (alternatively
   you could write alternate versions that don't require this type). */
/* #define BIGNUM_NO_ULONG */

typedef ARRAY * bignum_type;
#define BIGNUM_OUT_OF_BAND ((bignum_type) 0)

enum bignum_comparison
{
  bignum_comparison_equal = 0,
  bignum_comparison_less = -1,
  bignum_comparison_greater = 1
};

typedef void * bignum_procedure_context;
extern int s48_bignum_equal_p(bignum_type, bignum_type);
extern enum bignum_comparison s48_bignum_test(bignum_type);
extern enum bignum_comparison s48_bignum_compare(bignum_type, bignum_type);
extern bignum_type s48_bignum_add(bignum_type, bignum_type);
extern bignum_type s48_bignum_subtract(bignum_type, bignum_type);
extern bignum_type s48_bignum_negate(bignum_type);
extern bignum_type s48_bignum_multiply(bignum_type, bignum_type);
extern int s48_bignum_divide(bignum_type numerator, bignum_type denominator,
			     void * quotient, void * remainder);
extern bignum_type s48_bignum_quotient(bignum_type, bignum_type);
extern bignum_type s48_bignum_remainder(bignum_type, bignum_type);
extern bignum_type s48_long_to_bignum(long);
extern bignum_type s48_ulong_to_bignum(unsigned long);
extern long s48_bignum_to_long(bignum_type);
extern unsigned long s48_bignum_to_ulong(bignum_type);
extern bignum_type s48_double_to_bignum(double);
extern double s48_bignum_to_double(bignum_type);
extern int s48_bignum_fits_in_word_p(bignum_type, long word_length,
				     int twos_complement_p);
extern bignum_type s48_bignum_length_in_bits(bignum_type);
extern bignum_type s48_bignum_length_upper_limit(void);
extern bignum_type s48_digit_stream_to_bignum
       (unsigned int n_digits,
	unsigned int (*producer(bignum_procedure_context)),
	bignum_procedure_context context,
	unsigned int radix,
	int negative_p);
extern long s48_bignum_max_digit_stream_radix(void);

/* Added bitwise operators. */

extern bignum_type s48_bignum_bitwise_not(bignum_type),
                   s48_bignum_arithmetic_shift(bignum_type, long),
                   s48_bignum_bitwise_and(bignum_type, bignum_type),
                   s48_bignum_bitwise_ior(bignum_type, bignum_type),
                   s48_bignum_bitwise_xor(bignum_type, bignum_type);

extern int s48_bignum_oddp(bignum_type);
extern long s48_bignum_bit_count(bignum_type);
