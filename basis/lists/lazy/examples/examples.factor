! Rewritten by Matthew Willis, July 2006
! Copyright (C) 2004 Chris Double.
! See https://factorcode.org/license.txt for BSD license.

USING: kernel lists lists.lazy math ;
IN: lists.lazy.examples

: naturals ( -- list ) 0 lfrom ;
: positives ( -- list ) 1 lfrom ;
: evens ( -- list ) 0 [ 2 + ] lfrom-by ;
: odds ( -- list ) 1 lfrom [ 2 mod 1 = ] lfilter ;
: powers-of-2 ( -- list ) 1 [ 2 * ] lfrom-by ;
: ones ( -- list ) 1 [ ] lfrom-by ;
: squares ( -- list ) naturals [ dup * ] lmap-lazy ;
: first-five-squares ( -- list ) 5 squares ltake list>array ;
