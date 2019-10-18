! Rewritten by Matthew Willis, July 2006
! Copyright (C) 2004 Chris Double.
! See http://factorcode.org/license.txt for BSD license.

USING: lists lists.lazy math kernel sequences quotations ;
IN: lists.lazy.examples

: naturals ( -- list ) 0 lfrom ;
: positives ( -- list ) 1 lfrom ;
: evens ( -- list ) 0 [ 2 + ] lfrom-by ;
: odds ( -- list ) 1 lfrom [ 2 mod 1 = ] lfilter ;
: powers-of-2 ( -- list ) 1 [ 2 * ] lfrom-by ;
: ones ( -- list ) 1 [ ] lfrom-by ;
: squares ( -- list ) naturals [ dup * ] lmap-lazy ;
: first-five-squares ( -- list ) 5 squares ltake list>array ;
