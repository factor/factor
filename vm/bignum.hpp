namespace factor
{

/* 

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

struct factor_vm;
bignum * digit_stream_to_bignum(unsigned int n_digits, unsigned int (*producer)(unsigned int,factor_vm*), unsigned int radix, int negative_p);

}
