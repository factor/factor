// -*-C-*-

// $Id: s48_bignumint.h,v 1.14 2005/12/21 02:36:52 spestov Exp $

// Copyright (c) 1989-1992 Massachusetts Institute of Technology

// This material was developed by the Scheme project at the Massachusetts
// Institute of Technology, Department of Electrical Engineering and
// Computer Science.  Permission to copy and modify this software, to
// redistribute either the original software or a modified version, and
// to use this software for any purpose is granted, subject to the
// following restrictions and understandings.

// 1. Any copy made of this software must include this copyright notice
// in full.

// 2. Users of this software agree to make their best efforts (a) to
// return to the MIT Scheme project any improvements or extensions that
// they make, so that these may be included in future releases; and (b)
// to inform MIT of noteworthy uses of this software.

// 3. All materials developed as a consequence of the use of this
// software shall duly acknowledge such use, in accordance with the usual
// standards of acknowledging credit in academic research.

// 4. MIT has made no warrantee or representation that the operation of
// this software will be error-free, and MIT is under no obligation to
// provide any services, by way of maintenance, update, or otherwise.

// 5. In conjunction with products arising from the use of this material,
// there shall be no use of the name of the Massachusetts Institute of
// Technology nor of any adaptation thereof in any advertising,
// promotional, or sales literature without prior written consent from
// MIT in each case.

namespace factor {

// Internal Interface to Bignum Code
#undef BIGNUM_ZERO_P
#undef BIGNUM_NEGATIVE_P

// The memory model is based on the following definitions, and on the
// definition of the type `bignum_type'.  The only other special
// definition is `CHAR_BIT', which is defined in the Ansi C header
// file "limits.h".

typedef fixnum bignum_digit_type;
typedef fixnum bignum_length_type;

#ifndef _WIN64
#ifdef FACTOR_64
typedef __int128_t bignum_twodigit_type;
#else
typedef int64_t bignum_twodigit_type;
#endif
#endif

// BIGNUM_TO_POINTER casts a bignum object to a digit array pointer.
#define BIGNUM_TO_POINTER(bignum) (reinterpret_cast<bignum_digit_type*>(bignum->data()))

// BIGNUM_EXCEPTION is invoked to handle assertion violations.
#define BIGNUM_EXCEPTION abort

#define BIGNUM_DIGIT_LENGTH (((sizeof(bignum_digit_type)) * CHAR_BIT) - 2)
#define BIGNUM_HALF_DIGIT_LENGTH (BIGNUM_DIGIT_LENGTH / 2)
#define BIGNUM_RADIX static_cast<bignum_digit_type>((static_cast<cell>(1)) << BIGNUM_DIGIT_LENGTH)
#define BIGNUM_RADIX_ROOT (static_cast<bignum_digit_type>(1) << BIGNUM_HALF_DIGIT_LENGTH)
#define BIGNUM_DIGIT_MASK (BIGNUM_RADIX - 1)
#define BIGNUM_HALF_DIGIT_MASK (BIGNUM_RADIX_ROOT - 1)

#define BIGNUM_START_PTR(bignum) ((BIGNUM_TO_POINTER(bignum)) + 1)

#define BIGNUM_LENGTH(bignum) (untag_fixnum((bignum)->capacity) - 1)

#define BIGNUM_NEGATIVE_P(bignum) (bignum->data()[0] != 0)
#define BIGNUM_SET_NEGATIVE_P(bignum, neg) (bignum->data()[0] = neg)

#define BIGNUM_ZERO_P(bignum) ((BIGNUM_LENGTH(bignum)) == 0)

#define BIGNUM_REF(bignum, index) (*((BIGNUM_START_PTR(bignum)) + (index)))

// These definitions are here to facilitate caching of the constants
// 0, 1, and -1.
#define BIGNUM_ZERO() untag<bignum>(special_objects[OBJ_BIGNUM_ZERO])
#define BIGNUM_ONE(neg_p) untag<bignum>(        \
            special_objects[neg_p ? OBJ_BIGNUM_NEG_ONE : OBJ_BIGNUM_POS_ONE])

#define HD_LOW(digit) ((digit) & BIGNUM_HALF_DIGIT_MASK)
#define HD_HIGH(digit) ((digit) >> BIGNUM_HALF_DIGIT_LENGTH)
#define HD_CONS(high, low) (((high) << BIGNUM_HALF_DIGIT_LENGTH) | (low))

#define BIGNUM_BITS_TO_DIGITS(n) \
  (((n) + (BIGNUM_DIGIT_LENGTH - 1)) / BIGNUM_DIGIT_LENGTH)

#define BIGNUM_DIGITS_FOR(type) \
  (BIGNUM_BITS_TO_DIGITS((sizeof(type)) * CHAR_BIT))

#ifndef BIGNUM_DISABLE_ASSERTION_CHECKS

#define BIGNUM_ASSERT(expression) \
  {                               \
    if (!(expression))            \
      BIGNUM_EXCEPTION();         \
  }

#endif // not BIGNUM_DISABLE_ASSERTION_CHECKS

}
