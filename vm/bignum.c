/* :tabSize=2:indentSize=2:noTabs=true:

Copyright (C) 1989-94 Massachusetts Institute of Technology
Portions copyright (C) 2004-2008 Slava Pestov

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

/* Changes for Scheme 48:
 *  - Converted to ANSI.
 *  - Added bitwise operations.
 *  - Added s48 to the beginning of all externally visible names.
 *  - Cached the bignum representations of -1, 0, and 1.
 */

/* Changes for Factor:
 *  - Adapt bignumint.h for Factor memory manager
 *  - Add more bignum <-> C type conversions
 *  - Remove unused functions
 *  - Add local variable GC root recording
 *  - Remove s48 prefix from function names
 *  - Various fixes for Win64
 */

#include "master.h"
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>        /* abort */
#include <math.h>

/* Exports */

int
bignum_equal_p(bignum_type x, bignum_type y)
{
  return
    ((BIGNUM_ZERO_P (x))
     ? (BIGNUM_ZERO_P (y))
     : ((! (BIGNUM_ZERO_P (y)))
        && ((BIGNUM_NEGATIVE_P (x))
            ? (BIGNUM_NEGATIVE_P (y))
            : (! (BIGNUM_NEGATIVE_P (y))))
        && (bignum_equal_p_unsigned (x, y))));
}

enum bignum_comparison
bignum_compare(bignum_type x, bignum_type y)
{
  return
    ((BIGNUM_ZERO_P (x))
     ? ((BIGNUM_ZERO_P (y))
        ? bignum_comparison_equal
        : (BIGNUM_NEGATIVE_P (y))
        ? bignum_comparison_greater
        : bignum_comparison_less)
     : (BIGNUM_ZERO_P (y))
     ? ((BIGNUM_NEGATIVE_P (x))
        ? bignum_comparison_less
        : bignum_comparison_greater)
     : (BIGNUM_NEGATIVE_P (x))
     ? ((BIGNUM_NEGATIVE_P (y))
        ? (bignum_compare_unsigned (y, x))
        : (bignum_comparison_less))
     : ((BIGNUM_NEGATIVE_P (y))
        ? (bignum_comparison_greater)
        : (bignum_compare_unsigned (x, y))));
}

/* allocates memory */
bignum_type
bignum_add(bignum_type x, bignum_type y)
{
  return
    ((BIGNUM_ZERO_P (x))
     ? (y)
     : (BIGNUM_ZERO_P (y))
     ? (x)
     : ((BIGNUM_NEGATIVE_P (x))
        ? ((BIGNUM_NEGATIVE_P (y))
           ? (bignum_add_unsigned (x, y, 1))
           : (bignum_subtract_unsigned (y, x)))
        : ((BIGNUM_NEGATIVE_P (y))
           ? (bignum_subtract_unsigned (x, y))
           : (bignum_add_unsigned (x, y, 0)))));
}

/* allocates memory */
bignum_type
bignum_subtract(bignum_type x, bignum_type y)
{
  return
    ((BIGNUM_ZERO_P (x))
     ? ((BIGNUM_ZERO_P (y))
        ? (y)
        : (bignum_new_sign (y, (! (BIGNUM_NEGATIVE_P (y))))))
     : ((BIGNUM_ZERO_P (y))
        ? (x)
        : ((BIGNUM_NEGATIVE_P (x))
           ? ((BIGNUM_NEGATIVE_P (y))
              ? (bignum_subtract_unsigned (y, x))
              : (bignum_add_unsigned (x, y, 1)))
           : ((BIGNUM_NEGATIVE_P (y))
              ? (bignum_add_unsigned (x, y, 0))
              : (bignum_subtract_unsigned (x, y))))));
}

/* allocates memory */
bignum_type
bignum_multiply(bignum_type x, bignum_type y)
{
  bignum_length_type x_length = (BIGNUM_LENGTH (x));
  bignum_length_type y_length = (BIGNUM_LENGTH (y));
  int negative_p =
    ((BIGNUM_NEGATIVE_P (x))
     ? (! (BIGNUM_NEGATIVE_P (y)))
     : (BIGNUM_NEGATIVE_P (y)));
  if (BIGNUM_ZERO_P (x))
    return (x);
  if (BIGNUM_ZERO_P (y))
    return (y);
  if (x_length == 1)
    {
      bignum_digit_type digit = (BIGNUM_REF (x, 0));
      if (digit == 1)
        return (bignum_maybe_new_sign (y, negative_p));
      if (digit < BIGNUM_RADIX_ROOT)
        return (bignum_multiply_unsigned_small_factor (y, digit, negative_p));
    }
  if (y_length == 1)
    {
      bignum_digit_type digit = (BIGNUM_REF (y, 0));
      if (digit == 1)
        return (bignum_maybe_new_sign (x, negative_p));
      if (digit < BIGNUM_RADIX_ROOT)
        return (bignum_multiply_unsigned_small_factor (x, digit, negative_p));
    }
  return (bignum_multiply_unsigned (x, y, negative_p));
}

/* allocates memory */
void
bignum_divide(bignum_type numerator, bignum_type denominator,
                  bignum_type * quotient, bignum_type * remainder)
{
  if (BIGNUM_ZERO_P (denominator))
    {
      divide_by_zero_error();
      return;
    }
  if (BIGNUM_ZERO_P (numerator))
    {
      (*quotient) = numerator;
      (*remainder) = numerator;
    }
  else
    {
      int r_negative_p = (BIGNUM_NEGATIVE_P (numerator));
      int q_negative_p =
        ((BIGNUM_NEGATIVE_P (denominator)) ? (! r_negative_p) : r_negative_p);
      switch (bignum_compare_unsigned (numerator, denominator))
        {
        case bignum_comparison_equal:
          {
            (*quotient) = (BIGNUM_ONE (q_negative_p));
            (*remainder) = (BIGNUM_ZERO ());
            break;
          }
        case bignum_comparison_less:
          {
            (*quotient) = (BIGNUM_ZERO ());
            (*remainder) = numerator;
            break;
          }
        case bignum_comparison_greater:
          {
            if ((BIGNUM_LENGTH (denominator)) == 1)
              {
                bignum_digit_type digit = (BIGNUM_REF (denominator, 0));
                if (digit == 1)
                  {
                    (*quotient) =
                      (bignum_maybe_new_sign (numerator, q_negative_p));
                    (*remainder) = (BIGNUM_ZERO ());
                    break;
                  }
                else if (digit < BIGNUM_RADIX_ROOT)
                  {
                    bignum_divide_unsigned_small_denominator
                      (numerator, digit,
                       quotient, remainder,
                       q_negative_p, r_negative_p);
                    break;
                  }
                else
                  {
                    bignum_divide_unsigned_medium_denominator
                      (numerator, digit,
                       quotient, remainder,
                       q_negative_p, r_negative_p);
                    break;
                  }
              }
            bignum_divide_unsigned_large_denominator
              (numerator, denominator,
               quotient, remainder,
               q_negative_p, r_negative_p);
            break;
          }
        }
    }
}

/* allocates memory */
bignum_type
bignum_quotient(bignum_type numerator, bignum_type denominator)
{
  if (BIGNUM_ZERO_P (denominator))
    {
      divide_by_zero_error();
      return (BIGNUM_OUT_OF_BAND);
    }
  if (BIGNUM_ZERO_P (numerator))
    return numerator;
  {
    int q_negative_p =
      ((BIGNUM_NEGATIVE_P (denominator))
       ? (! (BIGNUM_NEGATIVE_P (numerator)))
       : (BIGNUM_NEGATIVE_P (numerator)));
    switch (bignum_compare_unsigned (numerator, denominator))
      {
      case bignum_comparison_equal:
        return (BIGNUM_ONE (q_negative_p));
      case bignum_comparison_less:
        return (BIGNUM_ZERO ());
      case bignum_comparison_greater:
      default:                                        /* to appease gcc -Wall */
        {
          bignum_type quotient;
          if ((BIGNUM_LENGTH (denominator)) == 1)
            {
              bignum_digit_type digit = (BIGNUM_REF (denominator, 0));
              if (digit == 1)
                return (bignum_maybe_new_sign (numerator, q_negative_p));
              if (digit < BIGNUM_RADIX_ROOT)
                bignum_divide_unsigned_small_denominator
                  (numerator, digit,
                   (&quotient), ((bignum_type *) 0),
                   q_negative_p, 0);
              else
                bignum_divide_unsigned_medium_denominator
                  (numerator, digit,
                   (&quotient), ((bignum_type *) 0),
                   q_negative_p, 0);
            }
          else
            bignum_divide_unsigned_large_denominator
              (numerator, denominator,
               (&quotient), ((bignum_type *) 0),
               q_negative_p, 0);
          return (quotient);
        }
      }
  }
}

/* allocates memory */
bignum_type
bignum_remainder(bignum_type numerator, bignum_type denominator)
{
  if (BIGNUM_ZERO_P (denominator))
    {
      divide_by_zero_error();
      return (BIGNUM_OUT_OF_BAND);
    }
  if (BIGNUM_ZERO_P (numerator))
    return numerator;
  switch (bignum_compare_unsigned (numerator, denominator))
    {
    case bignum_comparison_equal:
      return (BIGNUM_ZERO ());
    case bignum_comparison_less:
      return numerator;
    case bignum_comparison_greater:
    default:                                        /* to appease gcc -Wall */
      {
        bignum_type remainder;
        if ((BIGNUM_LENGTH (denominator)) == 1)
          {
            bignum_digit_type digit = (BIGNUM_REF (denominator, 0));
            if (digit == 1)
              return (BIGNUM_ZERO ());
            if (digit < BIGNUM_RADIX_ROOT)
              return
                (bignum_remainder_unsigned_small_denominator
                 (numerator, digit, (BIGNUM_NEGATIVE_P (numerator))));
            bignum_divide_unsigned_medium_denominator
              (numerator, digit,
               ((bignum_type *) 0), (&remainder),
               0, (BIGNUM_NEGATIVE_P (numerator)));
          }
        else
          bignum_divide_unsigned_large_denominator
            (numerator, denominator,
             ((bignum_type *) 0), (&remainder),
             0, (BIGNUM_NEGATIVE_P (numerator)));
        return (remainder);
      }
    }
}

#define FOO_TO_BIGNUM(name,type,utype) \
  bignum_type name##_to_bignum(type n)                                 \
  {                                                                    \
    int negative_p;                                                    \
    bignum_digit_type result_digits [BIGNUM_DIGITS_FOR(type)];         \
    bignum_digit_type * end_digits = result_digits;                    \
    /* Special cases win when these small constants are cached. */     \
    if (n == 0) return (BIGNUM_ZERO ());                               \
    if (n == 1) return (BIGNUM_ONE (0));                               \
    if (n < 0 && n == -1) return (BIGNUM_ONE (1));                     \
    {                                                                  \
      utype accumulator = ((negative_p = (n < 0)) ? (-n) : n);         \
      do                                                               \
        {                                                              \
          (*end_digits++) = (accumulator & BIGNUM_DIGIT_MASK);         \
          accumulator >>= BIGNUM_DIGIT_LENGTH;                         \
        }                                                              \
      while (accumulator != 0);                                        \
    }                                                                  \
    {                                                                  \
      bignum_type result =                                             \
        (allot_bignum ((end_digits - result_digits), negative_p));     \
      bignum_digit_type * scan_digits = result_digits;                 \
      bignum_digit_type * scan_result = (BIGNUM_START_PTR (result));   \
      while (scan_digits < end_digits)                                 \
        (*scan_result++) = (*scan_digits++);                           \
      return (result);                                                 \
    }                                                                  \
  }
  
/* all below allocate memory */
FOO_TO_BIGNUM(cell,CELL,CELL)
FOO_TO_BIGNUM(fixnum,F_FIXNUM,CELL)
FOO_TO_BIGNUM(long_long,s64,u64)
FOO_TO_BIGNUM(ulong_long,u64,u64)

#define BIGNUM_TO_FOO(name,type,utype) \
  type bignum_to_##name(bignum_type bignum) \
  { \
    if (BIGNUM_ZERO_P (bignum)) \
      return (0); \
    { \
      utype accumulator = 0; \
      bignum_digit_type * start = (BIGNUM_START_PTR (bignum)); \
      bignum_digit_type * scan = (start + (BIGNUM_LENGTH (bignum))); \
      while (start < scan) \
        accumulator = ((accumulator << BIGNUM_DIGIT_LENGTH) + (*--scan)); \
      return ((BIGNUM_NEGATIVE_P (bignum)) ? (-((type)accumulator)) : accumulator); \
    } \
  }

/* all of the below allocate memory */
BIGNUM_TO_FOO(cell,CELL,CELL);
BIGNUM_TO_FOO(fixnum,F_FIXNUM,CELL);
BIGNUM_TO_FOO(long_long,s64,u64)
BIGNUM_TO_FOO(ulong_long,u64,u64)

double
bignum_to_double(bignum_type bignum)
{
  if (BIGNUM_ZERO_P (bignum))
    return (0);
  {
    double accumulator = 0;
    bignum_digit_type * start = (BIGNUM_START_PTR (bignum));
    bignum_digit_type * scan = (start + (BIGNUM_LENGTH (bignum)));
    while (start < scan)
      accumulator = ((accumulator * BIGNUM_RADIX) + (*--scan));
    return ((BIGNUM_NEGATIVE_P (bignum)) ? (-accumulator) : accumulator);
  }
}

#define DTB_WRITE_DIGIT(factor) \
{ \
  significand *= (factor); \
  digit = ((bignum_digit_type) significand); \
  (*--scan) = digit; \
  significand -= ((double) digit); \
}

/* allocates memory */
bignum_type
double_to_bignum(double x)
{
  if (x == 1.0/0.0 || x == -1.0/0.0 || x != x) return (BIGNUM_ZERO ());
  int exponent;
  double significand = (frexp (x, (&exponent)));
  if (exponent <= 0) return (BIGNUM_ZERO ());
  if (exponent == 1) return (BIGNUM_ONE (x < 0));
  if (significand < 0) significand = (-significand);
  {
    bignum_length_type length = (BIGNUM_BITS_TO_DIGITS (exponent));
    bignum_type result = (allot_bignum (length, (x < 0)));
    bignum_digit_type * start = (BIGNUM_START_PTR (result));
    bignum_digit_type * scan = (start + length);
    bignum_digit_type digit;
    int odd_bits = (exponent % BIGNUM_DIGIT_LENGTH);
    if (odd_bits > 0)
      DTB_WRITE_DIGIT ((F_FIXNUM)1 << odd_bits);
    while (start < scan)
      {
        if (significand == 0)
          {
            while (start < scan)
              (*--scan) = 0;
            break;
          }
        DTB_WRITE_DIGIT (BIGNUM_RADIX);
      }
    return (result);
  }
}

#undef DTB_WRITE_DIGIT

/* Comparisons */

int
bignum_equal_p_unsigned(bignum_type x, bignum_type y)
{
  bignum_length_type length = (BIGNUM_LENGTH (x));
  if (length != (BIGNUM_LENGTH (y)))
    return (0);
  else
    {
      bignum_digit_type * scan_x = (BIGNUM_START_PTR (x));
      bignum_digit_type * scan_y = (BIGNUM_START_PTR (y));
      bignum_digit_type * end_x = (scan_x + length);
      while (scan_x < end_x)
        if ((*scan_x++) != (*scan_y++))
          return (0);
      return (1);
    }
}

enum bignum_comparison
bignum_compare_unsigned(bignum_type x, bignum_type y)
{
  bignum_length_type x_length = (BIGNUM_LENGTH (x));
  bignum_length_type y_length = (BIGNUM_LENGTH (y));
  if (x_length < y_length)
    return (bignum_comparison_less);
  if (x_length > y_length)
    return (bignum_comparison_greater);
  {
    bignum_digit_type * start_x = (BIGNUM_START_PTR (x));
    bignum_digit_type * scan_x = (start_x + x_length);
    bignum_digit_type * scan_y = ((BIGNUM_START_PTR (y)) + y_length);
    while (start_x < scan_x)
      {
        bignum_digit_type digit_x = (*--scan_x);
        bignum_digit_type digit_y = (*--scan_y);
        if (digit_x < digit_y)
          return (bignum_comparison_less);
        if (digit_x > digit_y)
          return (bignum_comparison_greater);
      }
  }
  return (bignum_comparison_equal);
}

/* Addition */

/* allocates memory */
bignum_type
bignum_add_unsigned(bignum_type x, bignum_type y, int negative_p)
{
  if ((BIGNUM_LENGTH (y)) > (BIGNUM_LENGTH (x)))
    {
      bignum_type z = x;
      x = y;
      y = z;
    }
  {
    bignum_length_type x_length = (BIGNUM_LENGTH (x));
    
    REGISTER_BIGNUM(x);
    REGISTER_BIGNUM(y);
    bignum_type r = (allot_bignum ((x_length + 1), negative_p));
    UNREGISTER_BIGNUM(y);
    UNREGISTER_BIGNUM(x);

    bignum_digit_type sum;
    bignum_digit_type carry = 0;
    bignum_digit_type * scan_x = (BIGNUM_START_PTR (x));
    bignum_digit_type * scan_r = (BIGNUM_START_PTR (r));
    {
      bignum_digit_type * scan_y = (BIGNUM_START_PTR (y));
      bignum_digit_type * end_y = (scan_y + (BIGNUM_LENGTH (y)));
      while (scan_y < end_y)
        {
          sum = ((*scan_x++) + (*scan_y++) + carry);
          if (sum < BIGNUM_RADIX)
            {
              (*scan_r++) = sum;
              carry = 0;
            }
          else
            {
              (*scan_r++) = (sum - BIGNUM_RADIX);
              carry = 1;
            }
        }
    }
    {
      bignum_digit_type * end_x = ((BIGNUM_START_PTR (x)) + x_length);
      if (carry != 0)
        while (scan_x < end_x)
          {
            sum = ((*scan_x++) + 1);
            if (sum < BIGNUM_RADIX)
              {
                (*scan_r++) = sum;
                carry = 0;
                break;
              }
            else
              (*scan_r++) = (sum - BIGNUM_RADIX);
          }
      while (scan_x < end_x)
        (*scan_r++) = (*scan_x++);
    }
    if (carry != 0)
      {
        (*scan_r) = 1;
        return (r);
      }
    return (bignum_shorten_length (r, x_length));
  }
}

/* Subtraction */

/* allocates memory */
bignum_type
bignum_subtract_unsigned(bignum_type x, bignum_type y)
{
  int negative_p = 0;
  switch (bignum_compare_unsigned (x, y))
    {
    case bignum_comparison_equal:
      return (BIGNUM_ZERO ());
    case bignum_comparison_less:
      {
        bignum_type z = x;
        x = y;
        y = z;
      }
      negative_p = 1;
      break;
    case bignum_comparison_greater:
      negative_p = 0;
      break;
    }
  {
    bignum_length_type x_length = (BIGNUM_LENGTH (x));
    
    REGISTER_BIGNUM(x);
    REGISTER_BIGNUM(y);
    bignum_type r = (allot_bignum (x_length, negative_p));
    UNREGISTER_BIGNUM(y);
    UNREGISTER_BIGNUM(x);

    bignum_digit_type difference;
    bignum_digit_type borrow = 0;
    bignum_digit_type * scan_x = (BIGNUM_START_PTR (x));
    bignum_digit_type * scan_r = (BIGNUM_START_PTR (r));
    {
      bignum_digit_type * scan_y = (BIGNUM_START_PTR (y));
      bignum_digit_type * end_y = (scan_y + (BIGNUM_LENGTH (y)));
      while (scan_y < end_y)
        {
          difference = (((*scan_x++) - (*scan_y++)) - borrow);
          if (difference < 0)
            {
              (*scan_r++) = (difference + BIGNUM_RADIX);
              borrow = 1;
            }
          else
            {
              (*scan_r++) = difference;
              borrow = 0;
            }
        }
    }
    {
      bignum_digit_type * end_x = ((BIGNUM_START_PTR (x)) + x_length);
      if (borrow != 0)
        while (scan_x < end_x)
          {
            difference = ((*scan_x++) - borrow);
            if (difference < 0)
              (*scan_r++) = (difference + BIGNUM_RADIX);
            else
              {
                (*scan_r++) = difference;
                borrow = 0;
                break;
              }
          }
      BIGNUM_ASSERT (borrow == 0);
      while (scan_x < end_x)
        (*scan_r++) = (*scan_x++);
    }
    return (bignum_trim (r));
  }
}

/* Multiplication
   Maximum value for product_low or product_high:
        ((R * R) + (R * (R - 2)) + (R - 1))
   Maximum value for carry: ((R * (R - 1)) + (R - 1))
        where R == BIGNUM_RADIX_ROOT */

/* allocates memory */
bignum_type
bignum_multiply_unsigned(bignum_type x, bignum_type y, int negative_p)
{
  if ((BIGNUM_LENGTH (y)) > (BIGNUM_LENGTH (x)))
    {
      bignum_type z = x;
      x = y;
      y = z;
    }
  {
    bignum_digit_type carry;
    bignum_digit_type y_digit_low;
    bignum_digit_type y_digit_high;
    bignum_digit_type x_digit_low;
    bignum_digit_type x_digit_high;
    bignum_digit_type product_low;
    bignum_digit_type * scan_r;
    bignum_digit_type * scan_y;
    bignum_length_type x_length = (BIGNUM_LENGTH (x));
    bignum_length_type y_length = (BIGNUM_LENGTH (y));

    REGISTER_BIGNUM(x);
    REGISTER_BIGNUM(y);
    bignum_type r =
      (allot_bignum_zeroed ((x_length + y_length), negative_p));
    UNREGISTER_BIGNUM(y);
    UNREGISTER_BIGNUM(x);

    bignum_digit_type * scan_x = (BIGNUM_START_PTR (x));
    bignum_digit_type * end_x = (scan_x + x_length);
    bignum_digit_type * start_y = (BIGNUM_START_PTR (y));
    bignum_digit_type * end_y = (start_y + y_length);
    bignum_digit_type * start_r = (BIGNUM_START_PTR (r));
#define x_digit x_digit_high
#define y_digit y_digit_high
#define product_high carry
    while (scan_x < end_x)
      {
        x_digit = (*scan_x++);
        x_digit_low = (HD_LOW (x_digit));
        x_digit_high = (HD_HIGH (x_digit));
        carry = 0;
        scan_y = start_y;
        scan_r = (start_r++);
        while (scan_y < end_y)
          {
            y_digit = (*scan_y++);
            y_digit_low = (HD_LOW (y_digit));
            y_digit_high = (HD_HIGH (y_digit));
            product_low =
              ((*scan_r) +
               (x_digit_low * y_digit_low) +
               (HD_LOW (carry)));
            product_high =
              ((x_digit_high * y_digit_low) +
               (x_digit_low * y_digit_high) +
               (HD_HIGH (product_low)) +
               (HD_HIGH (carry)));
            (*scan_r++) =
              (HD_CONS ((HD_LOW (product_high)), (HD_LOW (product_low))));
            carry =
              ((x_digit_high * y_digit_high) +
               (HD_HIGH (product_high)));
          }
        (*scan_r) += carry;
      }
    return (bignum_trim (r));
#undef x_digit
#undef y_digit
#undef product_high
  }
}

/* allocates memory */
bignum_type
bignum_multiply_unsigned_small_factor(bignum_type x, bignum_digit_type y,
                                      int negative_p)
{
  bignum_length_type length_x = (BIGNUM_LENGTH (x));

  REGISTER_BIGNUM(x);
  bignum_type p = (allot_bignum ((length_x + 1), negative_p));
  UNREGISTER_BIGNUM(x);

  bignum_destructive_copy (x, p);
  (BIGNUM_REF (p, length_x)) = 0;
  bignum_destructive_scale_up (p, y);
  return (bignum_trim (p));
}

void
bignum_destructive_add(bignum_type bignum, bignum_digit_type n)
{
  bignum_digit_type * scan = (BIGNUM_START_PTR (bignum));
  bignum_digit_type digit;
  digit = ((*scan) + n);
  if (digit < BIGNUM_RADIX)
    {
      (*scan) = digit;
      return;
    }
  (*scan++) = (digit - BIGNUM_RADIX);
  while (1)
    {
      digit = ((*scan) + 1);
      if (digit < BIGNUM_RADIX)
        {
          (*scan) = digit;
          return;
        }
      (*scan++) = (digit - BIGNUM_RADIX);
    }
}

void
bignum_destructive_scale_up(bignum_type bignum, bignum_digit_type factor)
{
  bignum_digit_type carry = 0;
  bignum_digit_type * scan = (BIGNUM_START_PTR (bignum));
  bignum_digit_type two_digits;
  bignum_digit_type product_low;
#define product_high carry
  bignum_digit_type * end = (scan + (BIGNUM_LENGTH (bignum)));
  BIGNUM_ASSERT ((factor > 1) && (factor < BIGNUM_RADIX_ROOT));
  while (scan < end)
    {
      two_digits = (*scan);
      product_low = ((factor * (HD_LOW (two_digits))) + (HD_LOW (carry)));
      product_high =
        ((factor * (HD_HIGH (two_digits))) +
         (HD_HIGH (product_low)) +
         (HD_HIGH (carry)));
      (*scan++) = (HD_CONS ((HD_LOW (product_high)), (HD_LOW (product_low))));
      carry = (HD_HIGH (product_high));
    }
  /* A carry here would be an overflow, i.e. it would not fit.
     Hopefully the callers allocate enough space that this will
     never happen.
   */
  BIGNUM_ASSERT (carry == 0);
  return;
#undef product_high
}

/* Division */

/* For help understanding this algorithm, see:
   Knuth, Donald E., "The Art of Computer Programming",
   volume 2, "Seminumerical Algorithms"
   section 4.3.1, "Multiple-Precision Arithmetic". */

/* allocates memory */
void
bignum_divide_unsigned_large_denominator(bignum_type numerator,
                                         bignum_type denominator,
                                         bignum_type * quotient,
                                         bignum_type * remainder,
                                         int q_negative_p,
                                         int r_negative_p)
{
  bignum_length_type length_n = ((BIGNUM_LENGTH (numerator)) + 1);
  bignum_length_type length_d = (BIGNUM_LENGTH (denominator));

  REGISTER_BIGNUM(numerator);
  REGISTER_BIGNUM(denominator);

  bignum_type q =
    ((quotient != ((bignum_type *) 0))
     ? (allot_bignum ((length_n - length_d), q_negative_p))
     : BIGNUM_OUT_OF_BAND);

  REGISTER_BIGNUM(q);
  bignum_type u = (allot_bignum (length_n, r_negative_p));
  UNREGISTER_BIGNUM(q);

  UNREGISTER_BIGNUM(denominator);
  UNREGISTER_BIGNUM(numerator);

  int shift = 0;
  BIGNUM_ASSERT (length_d > 1);
  {
    bignum_digit_type v1 = (BIGNUM_REF ((denominator), (length_d - 1)));
    while (v1 < (BIGNUM_RADIX / 2))
      {
        v1 <<= 1;
        shift += 1;
      }
  }
  if (shift == 0)
    {
      bignum_destructive_copy (numerator, u);
      (BIGNUM_REF (u, (length_n - 1))) = 0;
      bignum_divide_unsigned_normalized (u, denominator, q);
    }
  else
    {
      REGISTER_BIGNUM(numerator);
      REGISTER_BIGNUM(denominator);
      REGISTER_BIGNUM(u);
      REGISTER_BIGNUM(q);
      bignum_type v = (allot_bignum (length_d, 0));
      UNREGISTER_BIGNUM(q);
      UNREGISTER_BIGNUM(u);
      UNREGISTER_BIGNUM(denominator);
      UNREGISTER_BIGNUM(numerator);

      bignum_destructive_normalization (numerator, u, shift);
      bignum_destructive_normalization (denominator, v, shift);
      bignum_divide_unsigned_normalized (u, v, q);
      if (remainder != ((bignum_type *) 0))
        bignum_destructive_unnormalization (u, shift);
    }

  REGISTER_BIGNUM(u);
  if(q)
    q = bignum_trim (q);
  UNREGISTER_BIGNUM(u);

  REGISTER_BIGNUM(q);
  u = bignum_trim (u);
  UNREGISTER_BIGNUM(q);

  if (quotient != ((bignum_type *) 0))
    (*quotient) = q;

  if (remainder != ((bignum_type *) 0))
    (*remainder) = u;

  return;
}

void
bignum_divide_unsigned_normalized(bignum_type u, bignum_type v, bignum_type q)
{
  bignum_length_type u_length = (BIGNUM_LENGTH (u));
  bignum_length_type v_length = (BIGNUM_LENGTH (v));
  bignum_digit_type * u_start = (BIGNUM_START_PTR (u));
  bignum_digit_type * u_scan = (u_start + u_length);
  bignum_digit_type * u_scan_limit = (u_start + v_length);
  bignum_digit_type * u_scan_start = (u_scan - v_length);
  bignum_digit_type * v_start = (BIGNUM_START_PTR (v));
  bignum_digit_type * v_end = (v_start + v_length);
  bignum_digit_type * q_scan = NULL;
  bignum_digit_type v1 = (v_end[-1]);
  bignum_digit_type v2 = (v_end[-2]);
  bignum_digit_type ph;        /* high half of double-digit product */
  bignum_digit_type pl;        /* low half of double-digit product */
  bignum_digit_type guess;
  bignum_digit_type gh;        /* high half-digit of guess */
  bignum_digit_type ch;        /* high half of double-digit comparand */
  bignum_digit_type v2l = (HD_LOW (v2));
  bignum_digit_type v2h = (HD_HIGH (v2));
  bignum_digit_type cl;        /* low half of double-digit comparand */
#define gl ph                        /* low half-digit of guess */
#define uj pl
#define qj ph
  bignum_digit_type gm;                /* memory loc for reference parameter */
  if (q != BIGNUM_OUT_OF_BAND)
    q_scan = ((BIGNUM_START_PTR (q)) + (BIGNUM_LENGTH (q)));
  while (u_scan_limit < u_scan)
    {
      uj = (*--u_scan);
      if (uj != v1)
        {
          /* comparand =
             (((((uj * BIGNUM_RADIX) + uj1) % v1) * BIGNUM_RADIX) + uj2);
             guess = (((uj * BIGNUM_RADIX) + uj1) / v1); */
          cl = (u_scan[-2]);
          ch = (bignum_digit_divide (uj, (u_scan[-1]), v1, (&gm)));
          guess = gm;
        }
      else
        {
          cl = (u_scan[-2]);
          ch = ((u_scan[-1]) + v1);
          guess = (BIGNUM_RADIX - 1);
        }
      while (1)
        {
          /* product = (guess * v2); */
          gl = (HD_LOW (guess));
          gh = (HD_HIGH (guess));
          pl = (v2l * gl);
          ph = ((v2l * gh) + (v2h * gl) + (HD_HIGH (pl)));
          pl = (HD_CONS ((HD_LOW (ph)), (HD_LOW (pl))));
          ph = ((v2h * gh) + (HD_HIGH (ph)));
          /* if (comparand >= product) */
          if ((ch > ph) || ((ch == ph) && (cl >= pl)))
            break;
          guess -= 1;
          /* comparand += (v1 << BIGNUM_DIGIT_LENGTH) */
          ch += v1;
          /* if (comparand >= (BIGNUM_RADIX * BIGNUM_RADIX)) */
          if (ch >= BIGNUM_RADIX)
            break;
        }
      qj = (bignum_divide_subtract (v_start, v_end, guess, (--u_scan_start)));
      if (q != BIGNUM_OUT_OF_BAND)
        (*--q_scan) = qj;
    }
  return;
#undef gl
#undef uj
#undef qj
}

bignum_digit_type
bignum_divide_subtract(bignum_digit_type * v_start,
                       bignum_digit_type * v_end,
                       bignum_digit_type guess,
                       bignum_digit_type * u_start)
{
  bignum_digit_type * v_scan = v_start;
  bignum_digit_type * u_scan = u_start;
  bignum_digit_type carry = 0;
  if (guess == 0) return (0);
  {
    bignum_digit_type gl = (HD_LOW (guess));
    bignum_digit_type gh = (HD_HIGH (guess));
    bignum_digit_type v;
    bignum_digit_type pl;
    bignum_digit_type vl;
#define vh v
#define ph carry
#define diff pl
    while (v_scan < v_end)
      {
        v = (*v_scan++);
        vl = (HD_LOW (v));
        vh = (HD_HIGH (v));
        pl = ((vl * gl) + (HD_LOW (carry)));
        ph = ((vl * gh) + (vh * gl) + (HD_HIGH (pl)) + (HD_HIGH (carry)));
        diff = ((*u_scan) - (HD_CONS ((HD_LOW (ph)), (HD_LOW (pl)))));
        if (diff < 0)
          {
            (*u_scan++) = (diff + BIGNUM_RADIX);
            carry = ((vh * gh) + (HD_HIGH (ph)) + 1);
          }
        else
          {
            (*u_scan++) = diff;
            carry = ((vh * gh) + (HD_HIGH (ph)));
          }
      }
    if (carry == 0)
      return (guess);
    diff = ((*u_scan) - carry);
    if (diff < 0)
      (*u_scan) = (diff + BIGNUM_RADIX);
    else
      {
        (*u_scan) = diff;
        return (guess);
      }
#undef vh
#undef ph
#undef diff
  }
  /* Subtraction generated carry, implying guess is one too large.
     Add v back in to bring it back down. */
  v_scan = v_start;
  u_scan = u_start;
  carry = 0;
  while (v_scan < v_end)
    {
      bignum_digit_type sum = ((*v_scan++) + (*u_scan) + carry);
      if (sum < BIGNUM_RADIX)
        {
          (*u_scan++) = sum;
          carry = 0;
        }
      else
        {
          (*u_scan++) = (sum - BIGNUM_RADIX);
          carry = 1;
        }
    }
  if (carry == 1)
    {
      bignum_digit_type sum = ((*u_scan) + carry);
      (*u_scan) = ((sum < BIGNUM_RADIX) ? sum : (sum - BIGNUM_RADIX));
    }
  return (guess - 1);
}

/* allocates memory */
void
bignum_divide_unsigned_medium_denominator(bignum_type numerator,
                                          bignum_digit_type denominator,
                                          bignum_type * quotient,
                                          bignum_type * remainder,
                                          int q_negative_p,
                                          int r_negative_p)
{
  bignum_length_type length_n = (BIGNUM_LENGTH (numerator));
  bignum_length_type length_q;
  bignum_type q;
  int shift = 0;
  /* Because `bignum_digit_divide' requires a normalized denominator. */
  while (denominator < (BIGNUM_RADIX / 2))
    {
      denominator <<= 1;
      shift += 1;
    }
  if (shift == 0)
    {
      length_q = length_n;

      REGISTER_BIGNUM(numerator);
      q = (allot_bignum (length_q, q_negative_p));
      UNREGISTER_BIGNUM(numerator);

      bignum_destructive_copy (numerator, q);
    }
  else
    {
      length_q = (length_n + 1);

      REGISTER_BIGNUM(numerator);
      q = (allot_bignum (length_q, q_negative_p));
      UNREGISTER_BIGNUM(numerator);

      bignum_destructive_normalization (numerator, q, shift);
    }
  {
    bignum_digit_type r = 0;
    bignum_digit_type * start = (BIGNUM_START_PTR (q));
    bignum_digit_type * scan = (start + length_q);
    bignum_digit_type qj;

    while (start < scan)
      {
        r = (bignum_digit_divide (r, (*--scan), denominator, (&qj)));
        (*scan) = qj;
      }

    q = bignum_trim (q);

    if (remainder != ((bignum_type *) 0))
      {
        if (shift != 0)
          r >>= shift;

        REGISTER_BIGNUM(q);
        (*remainder) = (bignum_digit_to_bignum (r, r_negative_p));
        UNREGISTER_BIGNUM(q);
      }

    if (quotient != ((bignum_type *) 0))
      (*quotient) = q;
  }
  return;
}

void
bignum_destructive_normalization(bignum_type source, bignum_type target,
                                 int shift_left)
{
  bignum_digit_type digit;
  bignum_digit_type * scan_source = (BIGNUM_START_PTR (source));
  bignum_digit_type carry = 0;
  bignum_digit_type * scan_target = (BIGNUM_START_PTR (target));
  bignum_digit_type * end_source = (scan_source + (BIGNUM_LENGTH (source)));
  bignum_digit_type * end_target = (scan_target + (BIGNUM_LENGTH (target)));
  int shift_right = (BIGNUM_DIGIT_LENGTH - shift_left);
  bignum_digit_type mask = (((CELL)1 << shift_right) - 1);
  while (scan_source < end_source)
    {
      digit = (*scan_source++);
      (*scan_target++) = (((digit & mask) << shift_left) | carry);
      carry = (digit >> shift_right);
    }
  if (scan_target < end_target)
    (*scan_target) = carry;
  else
    BIGNUM_ASSERT (carry == 0);
  return;
}

void
bignum_destructive_unnormalization(bignum_type bignum, int shift_right)
{
  bignum_digit_type * start = (BIGNUM_START_PTR (bignum));
  bignum_digit_type * scan = (start + (BIGNUM_LENGTH (bignum)));
  bignum_digit_type digit;
  bignum_digit_type carry = 0;
  int shift_left = (BIGNUM_DIGIT_LENGTH - shift_right);
  bignum_digit_type mask = (((F_FIXNUM)1 << shift_right) - 1);
  while (start < scan)
    {
      digit = (*--scan);
      (*scan) = ((digit >> shift_right) | carry);
      carry = ((digit & mask) << shift_left);
    }
  BIGNUM_ASSERT (carry == 0);
  return;
}

/* This is a reduced version of the division algorithm, applied to the
   case of dividing two bignum digits by one bignum digit.  It is
   assumed that the numerator, denominator are normalized. */

#define BDD_STEP(qn, j) \
{ \
  uj = (u[j]); \
  if (uj != v1) \
    { \
      uj_uj1 = (HD_CONS (uj, (u[j + 1]))); \
      guess = (uj_uj1 / v1); \
      comparand = (HD_CONS ((uj_uj1 % v1), (u[j + 2]))); \
    } \
  else \
    { \
      guess = (BIGNUM_RADIX_ROOT - 1); \
      comparand = (HD_CONS (((u[j + 1]) + v1), (u[j + 2]))); \
    } \
  while ((guess * v2) > comparand) \
    { \
      guess -= 1; \
      comparand += (v1 << BIGNUM_HALF_DIGIT_LENGTH); \
      if (comparand >= BIGNUM_RADIX) \
        break; \
    } \
  qn = (bignum_digit_divide_subtract (v1, v2, guess, (&u[j]))); \
}

bignum_digit_type
bignum_digit_divide(bignum_digit_type uh, bignum_digit_type ul,
                    bignum_digit_type v,
                    bignum_digit_type * q) /* return value */
{
  bignum_digit_type guess;
  bignum_digit_type comparand;
  bignum_digit_type v1 = (HD_HIGH (v));
  bignum_digit_type v2 = (HD_LOW (v));
  bignum_digit_type uj;
  bignum_digit_type uj_uj1;
  bignum_digit_type q1;
  bignum_digit_type q2;
  bignum_digit_type u [4];
  if (uh == 0)
    {
      if (ul < v)
        {
          (*q) = 0;
          return (ul);
        }
      else if (ul == v)
        {
          (*q) = 1;
          return (0);
        }
    }
  (u[0]) = (HD_HIGH (uh));
  (u[1]) = (HD_LOW (uh));
  (u[2]) = (HD_HIGH (ul));
  (u[3]) = (HD_LOW (ul));
  v1 = (HD_HIGH (v));
  v2 = (HD_LOW (v));
  BDD_STEP (q1, 0);
  BDD_STEP (q2, 1);
  (*q) = (HD_CONS (q1, q2));
  return (HD_CONS ((u[2]), (u[3])));
}

#undef BDD_STEP

#define BDDS_MULSUB(vn, un, carry_in) \
{ \
  product = ((vn * guess) + carry_in); \
  diff = (un - (HD_LOW (product))); \
  if (diff < 0) \
    { \
      un = (diff + BIGNUM_RADIX_ROOT); \
      carry = ((HD_HIGH (product)) + 1); \
    } \
  else \
    { \
      un = diff; \
      carry = (HD_HIGH (product)); \
    } \
}

#define BDDS_ADD(vn, un, carry_in) \
{ \
  sum = (vn + un + carry_in); \
  if (sum < BIGNUM_RADIX_ROOT) \
    { \
      un = sum; \
      carry = 0; \
    } \
  else \
    { \
      un = (sum - BIGNUM_RADIX_ROOT); \
      carry = 1; \
    } \
}

bignum_digit_type
bignum_digit_divide_subtract(bignum_digit_type v1, bignum_digit_type v2,
                             bignum_digit_type guess, bignum_digit_type * u)
{
  {
    bignum_digit_type product;
    bignum_digit_type diff;
    bignum_digit_type carry;
    BDDS_MULSUB (v2, (u[2]), 0);
    BDDS_MULSUB (v1, (u[1]), carry);
    if (carry == 0)
      return (guess);
    diff = ((u[0]) - carry);
    if (diff < 0)
      (u[0]) = (diff + BIGNUM_RADIX);
    else
      {
        (u[0]) = diff;
        return (guess);
      }
  }
  {
    bignum_digit_type sum;
    bignum_digit_type carry;
    BDDS_ADD(v2, (u[2]), 0);
    BDDS_ADD(v1, (u[1]), carry);
    if (carry == 1)
      (u[0]) += 1;
  }
  return (guess - 1);
}

#undef BDDS_MULSUB
#undef BDDS_ADD

/* allocates memory */
void
bignum_divide_unsigned_small_denominator(bignum_type numerator,
                                         bignum_digit_type denominator,
                                         bignum_type * quotient,
                                         bignum_type * remainder,
                                         int q_negative_p,
                                         int r_negative_p)
{
  REGISTER_BIGNUM(numerator);
  bignum_type q = (bignum_new_sign (numerator, q_negative_p));
  UNREGISTER_BIGNUM(numerator);

  bignum_digit_type r = (bignum_destructive_scale_down (q, denominator));

  q = (bignum_trim (q));

  if (remainder != ((bignum_type *) 0))
  {
    REGISTER_BIGNUM(q);
    (*remainder) = (bignum_digit_to_bignum (r, r_negative_p));
    UNREGISTER_BIGNUM(q);
  }

  (*quotient) = q;

  return;
}

/* Given (denominator > 1), it is fairly easy to show that
   (quotient_high < BIGNUM_RADIX_ROOT), after which it is easy to see
   that all digits are < BIGNUM_RADIX. */

bignum_digit_type
bignum_destructive_scale_down(bignum_type bignum, bignum_digit_type denominator)
{
  bignum_digit_type numerator;
  bignum_digit_type remainder = 0;
  bignum_digit_type two_digits;
#define quotient_high remainder
  bignum_digit_type * start = (BIGNUM_START_PTR (bignum));
  bignum_digit_type * scan = (start + (BIGNUM_LENGTH (bignum)));
  BIGNUM_ASSERT ((denominator > 1) && (denominator < BIGNUM_RADIX_ROOT));
  while (start < scan)
    {
      two_digits = (*--scan);
      numerator = (HD_CONS (remainder, (HD_HIGH (two_digits))));
      quotient_high = (numerator / denominator);
      numerator = (HD_CONS ((numerator % denominator), (HD_LOW (two_digits))));
      (*scan) = (HD_CONS (quotient_high, (numerator / denominator)));
      remainder = (numerator % denominator);
    }
  return (remainder);
#undef quotient_high
}

/* allocates memory */
bignum_type
bignum_remainder_unsigned_small_denominator(
       bignum_type n, bignum_digit_type d, int negative_p)
{
  bignum_digit_type two_digits;
  bignum_digit_type * start = (BIGNUM_START_PTR (n));
  bignum_digit_type * scan = (start + (BIGNUM_LENGTH (n)));
  bignum_digit_type r = 0;
  BIGNUM_ASSERT ((d > 1) && (d < BIGNUM_RADIX_ROOT));
  while (start < scan)
    {
      two_digits = (*--scan);
      r =
        ((HD_CONS (((HD_CONS (r, (HD_HIGH (two_digits)))) % d),
                   (HD_LOW (two_digits))))
         % d);
    }
  return (bignum_digit_to_bignum (r, negative_p));
}

/* allocates memory */
bignum_type
bignum_digit_to_bignum(bignum_digit_type digit, int negative_p)
{
  if (digit == 0)
    return (BIGNUM_ZERO ());
  else
    {
      bignum_type result = (allot_bignum (1, negative_p));
      (BIGNUM_REF (result, 0)) = digit;
      return (result);
    }
}

/* allocates memory */
bignum_type
allot_bignum(bignum_length_type length, int negative_p)
{
  BIGNUM_ASSERT ((length >= 0) || (length < BIGNUM_RADIX));
  bignum_type result = allot_array_internal(BIGNUM_TYPE,length + 1);
  BIGNUM_SET_NEGATIVE_P (result, negative_p);
  return (result);
}

/* allocates memory */
bignum_type
allot_bignum_zeroed(bignum_length_type length, int negative_p)
{
  bignum_type result = allot_bignum(length,negative_p);
  bignum_digit_type * scan = (BIGNUM_START_PTR (result));
  bignum_digit_type * end = (scan + length);
  while (scan < end)
    (*scan++) = 0;
  return (result);
}

#define BIGNUM_REDUCE_LENGTH(source, length) \
     source = reallot_array(source,length + 1)

/* allocates memory */
bignum_type
bignum_shorten_length(bignum_type bignum, bignum_length_type length)
{
  bignum_length_type current_length = (BIGNUM_LENGTH (bignum));
  BIGNUM_ASSERT ((length >= 0) || (length <= current_length));
  if (length < current_length)
    {
      BIGNUM_REDUCE_LENGTH (bignum, length);
      BIGNUM_SET_NEGATIVE_P (bignum, (length != 0) && (BIGNUM_NEGATIVE_P (bignum)));
    }
  return (bignum);
}

/* allocates memory */
bignum_type
bignum_trim(bignum_type bignum)
{
  bignum_digit_type * start = (BIGNUM_START_PTR (bignum));
  bignum_digit_type * end = (start + (BIGNUM_LENGTH (bignum)));
  bignum_digit_type * scan = end;
  while ((start <= scan) && ((*--scan) == 0))
    ;
  scan += 1;
  if (scan < end)
    {
      bignum_length_type length = (scan - start);
      BIGNUM_REDUCE_LENGTH (bignum, length);
      BIGNUM_SET_NEGATIVE_P (bignum, (length != 0) && (BIGNUM_NEGATIVE_P (bignum)));
    }
  return (bignum);
}

/* Copying */

/* allocates memory */
bignum_type
bignum_new_sign(bignum_type bignum, int negative_p)
{
  REGISTER_BIGNUM(bignum);
  bignum_type result =
    (allot_bignum ((BIGNUM_LENGTH (bignum)), negative_p));
  UNREGISTER_BIGNUM(bignum);

  bignum_destructive_copy (bignum, result);
  return (result);
}

/* allocates memory */
bignum_type
bignum_maybe_new_sign(bignum_type bignum, int negative_p)
{
  if ((BIGNUM_NEGATIVE_P (bignum)) ? negative_p : (! negative_p))
    return (bignum);
  else
    {
      bignum_type result =
        (allot_bignum ((BIGNUM_LENGTH (bignum)), negative_p));
      bignum_destructive_copy (bignum, result);
      return (result);
    }
}

void
bignum_destructive_copy(bignum_type source, bignum_type target)
{
  bignum_digit_type * scan_source = (BIGNUM_START_PTR (source));
  bignum_digit_type * end_source =
    (scan_source + (BIGNUM_LENGTH (source)));
  bignum_digit_type * scan_target = (BIGNUM_START_PTR (target));
  while (scan_source < end_source)
    (*scan_target++) = (*scan_source++);
  return;
}

/*
 * Added bitwise operations (and oddp).
 */

/* allocates memory */
bignum_type
bignum_bitwise_not(bignum_type x)
{
  return bignum_subtract(BIGNUM_ONE(1), x);
}

/* allocates memory */
bignum_type
bignum_arithmetic_shift(bignum_type arg1, F_FIXNUM n)
{
  if (BIGNUM_NEGATIVE_P(arg1) && n < 0)
    return bignum_bitwise_not(bignum_magnitude_ash(bignum_bitwise_not(arg1), n));
  else
    return bignum_magnitude_ash(arg1, n);
}

#define AND_OP 0
#define IOR_OP 1
#define XOR_OP 2

/* allocates memory */
bignum_type
bignum_bitwise_and(bignum_type arg1, bignum_type arg2)
{
  return(
         (BIGNUM_NEGATIVE_P (arg1))
         ? (BIGNUM_NEGATIVE_P (arg2))
           ? bignum_negneg_bitwise_op(AND_OP, arg1, arg2)
           : bignum_posneg_bitwise_op(AND_OP, arg2, arg1)
         : (BIGNUM_NEGATIVE_P (arg2))
           ? bignum_posneg_bitwise_op(AND_OP, arg1, arg2)
           : bignum_pospos_bitwise_op(AND_OP, arg1, arg2)
         );
}

/* allocates memory */
bignum_type
bignum_bitwise_ior(bignum_type arg1, bignum_type arg2)
{
  return(
         (BIGNUM_NEGATIVE_P (arg1))
         ? (BIGNUM_NEGATIVE_P (arg2))
           ? bignum_negneg_bitwise_op(IOR_OP, arg1, arg2)
           : bignum_posneg_bitwise_op(IOR_OP, arg2, arg1)
         : (BIGNUM_NEGATIVE_P (arg2))
           ? bignum_posneg_bitwise_op(IOR_OP, arg1, arg2)
           : bignum_pospos_bitwise_op(IOR_OP, arg1, arg2)
         );
}

/* allocates memory */
bignum_type
bignum_bitwise_xor(bignum_type arg1, bignum_type arg2)
{
  return(
         (BIGNUM_NEGATIVE_P (arg1))
         ? (BIGNUM_NEGATIVE_P (arg2))
           ? bignum_negneg_bitwise_op(XOR_OP, arg1, arg2)
           : bignum_posneg_bitwise_op(XOR_OP, arg2, arg1)
         : (BIGNUM_NEGATIVE_P (arg2))
           ? bignum_posneg_bitwise_op(XOR_OP, arg1, arg2)
           : bignum_pospos_bitwise_op(XOR_OP, arg1, arg2)
         );
}

/* allocates memory */
/* ash for the magnitude */
/* assume arg1 is a big number, n is a long */
bignum_type
bignum_magnitude_ash(bignum_type arg1, F_FIXNUM n)
{
  bignum_type result = NULL;
  bignum_digit_type *scan1;
  bignum_digit_type *scanr;
  bignum_digit_type *end;

  F_FIXNUM digit_offset,bit_offset;

  if (BIGNUM_ZERO_P (arg1)) return (arg1);

  if (n > 0) {
    digit_offset = n / BIGNUM_DIGIT_LENGTH;
    bit_offset =   n % BIGNUM_DIGIT_LENGTH;

    REGISTER_BIGNUM(arg1);
    result = allot_bignum_zeroed (BIGNUM_LENGTH (arg1) + digit_offset + 1,
                                     BIGNUM_NEGATIVE_P(arg1));
    UNREGISTER_BIGNUM(arg1);

    scanr = BIGNUM_START_PTR (result) + digit_offset;
    scan1 = BIGNUM_START_PTR (arg1);
    end = scan1 + BIGNUM_LENGTH (arg1);
    
    while (scan1 < end) {
      *scanr = *scanr | (*scan1 & BIGNUM_DIGIT_MASK) << bit_offset;
      *scanr = *scanr & BIGNUM_DIGIT_MASK;
      scanr++;
      *scanr = *scan1++ >> (BIGNUM_DIGIT_LENGTH - bit_offset);
      *scanr = *scanr & BIGNUM_DIGIT_MASK;
    }
  }
  else if (n < 0
           && (-n >= (BIGNUM_LENGTH (arg1) * (bignum_length_type) BIGNUM_DIGIT_LENGTH)))
    result = BIGNUM_ZERO ();

  else if (n < 0) {
    digit_offset = -n / BIGNUM_DIGIT_LENGTH;
    bit_offset =   -n % BIGNUM_DIGIT_LENGTH;
    
    REGISTER_BIGNUM(arg1);
    result = allot_bignum_zeroed (BIGNUM_LENGTH (arg1) - digit_offset,
                                     BIGNUM_NEGATIVE_P(arg1));
    UNREGISTER_BIGNUM(arg1);
    
    scanr = BIGNUM_START_PTR (result);
    scan1 = BIGNUM_START_PTR (arg1) + digit_offset;
    end = scanr + BIGNUM_LENGTH (result) - 1;
    
    while (scanr < end) {
      *scanr =  (*scan1++ & BIGNUM_DIGIT_MASK) >> bit_offset ;
      *scanr = (*scanr | 
        *scan1 << (BIGNUM_DIGIT_LENGTH - bit_offset)) & BIGNUM_DIGIT_MASK;
      scanr++;
    }
    *scanr =  (*scan1++ & BIGNUM_DIGIT_MASK) >> bit_offset ;
  }
  else if (n == 0) result = arg1;
  
  return (bignum_trim (result));
}

/* allocates memory */
bignum_type
bignum_pospos_bitwise_op(int op, bignum_type arg1, bignum_type arg2)
{
  bignum_type result;
  bignum_length_type max_length;

  bignum_digit_type *scan1, *end1, digit1;
  bignum_digit_type *scan2, *end2, digit2;
  bignum_digit_type *scanr, *endr;

  max_length =  (BIGNUM_LENGTH(arg1) > BIGNUM_LENGTH(arg2))
               ? BIGNUM_LENGTH(arg1) : BIGNUM_LENGTH(arg2);

  REGISTER_BIGNUM(arg1);
  REGISTER_BIGNUM(arg2);
  result = allot_bignum(max_length, 0);
  UNREGISTER_BIGNUM(arg2);
  UNREGISTER_BIGNUM(arg1);

  scanr = BIGNUM_START_PTR(result);
  scan1 = BIGNUM_START_PTR(arg1);
  scan2 = BIGNUM_START_PTR(arg2);
  endr = scanr + max_length;
  end1 = scan1 + BIGNUM_LENGTH(arg1);
  end2 = scan2 + BIGNUM_LENGTH(arg2);

  while (scanr < endr) {
    digit1 = (scan1 < end1) ? *scan1++ : 0;
    digit2 = (scan2 < end2) ? *scan2++ : 0;
    *scanr++ = (op == AND_OP) ? digit1 & digit2 :
               (op == IOR_OP) ? digit1 | digit2 :
                                digit1 ^ digit2;
  }
  return bignum_trim(result);
}

/* allocates memory */
bignum_type
bignum_posneg_bitwise_op(int op, bignum_type arg1, bignum_type arg2)
{
  bignum_type result;
  bignum_length_type max_length;

  bignum_digit_type *scan1, *end1, digit1;
  bignum_digit_type *scan2, *end2, digit2, carry2;
  bignum_digit_type *scanr, *endr;

  char neg_p = op == IOR_OP || op == XOR_OP;

  max_length =  (BIGNUM_LENGTH(arg1) > BIGNUM_LENGTH(arg2) + 1)
               ? BIGNUM_LENGTH(arg1) : BIGNUM_LENGTH(arg2) + 1;

  REGISTER_BIGNUM(arg1);
  REGISTER_BIGNUM(arg2);
  result = allot_bignum(max_length, neg_p);
  UNREGISTER_BIGNUM(arg2);
  UNREGISTER_BIGNUM(arg1);

  scanr = BIGNUM_START_PTR(result);
  scan1 = BIGNUM_START_PTR(arg1);
  scan2 = BIGNUM_START_PTR(arg2);
  endr = scanr + max_length;
  end1 = scan1 + BIGNUM_LENGTH(arg1);
  end2 = scan2 + BIGNUM_LENGTH(arg2);

  carry2 = 1;

  while (scanr < endr) {
    digit1 = (scan1 < end1) ? *scan1++ : 0;
    digit2 = (~((scan2 < end2) ? *scan2++ : 0) & BIGNUM_DIGIT_MASK)
             + carry2;

    if (digit2 < BIGNUM_RADIX)
      carry2 = 0;
    else
      {
        digit2 = (digit2 - BIGNUM_RADIX);
        carry2 = 1;
      }
    
    *scanr++ = (op == AND_OP) ? digit1 & digit2 :
               (op == IOR_OP) ? digit1 | digit2 :
                                digit1 ^ digit2;
  }
  
  if (neg_p)
    bignum_negate_magnitude(result);

  return bignum_trim(result);
}

/* allocates memory */
bignum_type
bignum_negneg_bitwise_op(int op, bignum_type arg1, bignum_type arg2)
{
  bignum_type result;
  bignum_length_type max_length;

  bignum_digit_type *scan1, *end1, digit1, carry1;
  bignum_digit_type *scan2, *end2, digit2, carry2;
  bignum_digit_type *scanr, *endr;

  char neg_p = op == AND_OP || op == IOR_OP;

  max_length =  (BIGNUM_LENGTH(arg1) > BIGNUM_LENGTH(arg2))
               ? BIGNUM_LENGTH(arg1) + 1 : BIGNUM_LENGTH(arg2) + 1;

  REGISTER_BIGNUM(arg1);
  REGISTER_BIGNUM(arg2);
  result = allot_bignum(max_length, neg_p);
  UNREGISTER_BIGNUM(arg2);
  UNREGISTER_BIGNUM(arg1);

  scanr = BIGNUM_START_PTR(result);
  scan1 = BIGNUM_START_PTR(arg1);
  scan2 = BIGNUM_START_PTR(arg2);
  endr = scanr + max_length;
  end1 = scan1 + BIGNUM_LENGTH(arg1);
  end2 = scan2 + BIGNUM_LENGTH(arg2);

  carry1 = 1;
  carry2 = 1;

  while (scanr < endr) {
    digit1 = (~((scan1 < end1) ? *scan1++ : 0) & BIGNUM_DIGIT_MASK) + carry1;
    digit2 = (~((scan2 < end2) ? *scan2++ : 0) & BIGNUM_DIGIT_MASK) + carry2;

    if (digit1 < BIGNUM_RADIX)
      carry1 = 0;
    else
      {
        digit1 = (digit1 - BIGNUM_RADIX);
        carry1 = 1;
      }
    
    if (digit2 < BIGNUM_RADIX)
      carry2 = 0;
    else
      {
        digit2 = (digit2 - BIGNUM_RADIX);
        carry2 = 1;
      }
    
    *scanr++ = (op == AND_OP) ? digit1 & digit2 :
               (op == IOR_OP) ? digit1 | digit2 :
                                digit1 ^ digit2;
  }

  if (neg_p)
    bignum_negate_magnitude(result);

  return bignum_trim(result);
}

void
bignum_negate_magnitude(bignum_type arg)
{
  bignum_digit_type *scan;
  bignum_digit_type *end;
  bignum_digit_type digit;
  bignum_digit_type carry;

  scan = BIGNUM_START_PTR(arg);
  end = scan + BIGNUM_LENGTH(arg);

  carry = 1;

  while (scan < end) {
    digit = (~*scan & BIGNUM_DIGIT_MASK) + carry;

    if (digit < BIGNUM_RADIX)
      carry = 0;
    else
      {
        digit = (digit - BIGNUM_RADIX);
        carry = 1;
      }
    
    *scan++ = digit;
  }
}

/* Allocates memory */
bignum_type
bignum_integer_length(bignum_type bignum)
{
  bignum_length_type index = ((BIGNUM_LENGTH (bignum)) - 1);
  bignum_digit_type digit = (BIGNUM_REF (bignum, index));
  
  REGISTER_BIGNUM(bignum);
  bignum_type result = (allot_bignum (2, 0));
  UNREGISTER_BIGNUM(bignum);
  
  (BIGNUM_REF (result, 0)) = index;
  (BIGNUM_REF (result, 1)) = 0;
  bignum_destructive_scale_up (result, BIGNUM_DIGIT_LENGTH);
  while (digit > 1)
    {
      bignum_destructive_add (result, ((bignum_digit_type) 1));
      digit >>= 1;
    }
  return (bignum_trim (result));
}

/* Allocates memory */
int
bignum_logbitp(int shift, bignum_type arg)
{
  return((BIGNUM_NEGATIVE_P (arg)) 
         ? !bignum_unsigned_logbitp (shift, bignum_bitwise_not (arg))
         : bignum_unsigned_logbitp (shift,arg));
}

int
bignum_unsigned_logbitp(int shift, bignum_type bignum)
{
  bignum_length_type len = (BIGNUM_LENGTH (bignum));
  int index = shift / BIGNUM_DIGIT_LENGTH;
  if (index >= len)
    return 0;
  bignum_digit_type digit = (BIGNUM_REF (bignum, index));
  int p = shift % BIGNUM_DIGIT_LENGTH;
  bignum_digit_type mask = ((F_FIXNUM)1) << p;
  return (digit & mask) ? 1 : 0;
}

/* Allocates memory */
bignum_type
digit_stream_to_bignum(unsigned int n_digits,
                       unsigned int (*producer)(unsigned int),
                       unsigned int radix,
                       int negative_p)
{
  BIGNUM_ASSERT ((radix > 1) && (radix <= BIGNUM_RADIX_ROOT));
  if (n_digits == 0)
    return (BIGNUM_ZERO ());
  if (n_digits == 1)
    {
      F_FIXNUM digit = ((F_FIXNUM) ((*producer) (0)));
      return (fixnum_to_bignum (negative_p ? (- digit) : digit));
    }
  {
    bignum_length_type length;
    {
      unsigned int radix_copy = radix;
      unsigned int log_radix = 0;
      while (radix_copy > 0)
        {
          radix_copy >>= 1;
          log_radix += 1;
        }
      /* This length will be at least as large as needed. */
      length = (BIGNUM_BITS_TO_DIGITS (n_digits * log_radix));
    }
    {
      bignum_type result = (allot_bignum_zeroed (length, negative_p));
      while ((n_digits--) > 0)
        {
          bignum_destructive_scale_up (result, ((bignum_digit_type) radix));
          bignum_destructive_add
            (result, ((bignum_digit_type) ((*producer) (n_digits))));
        }
      return (bignum_trim (result));
    }
  }
}
