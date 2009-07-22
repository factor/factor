! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs math.order sequences ;
IN: compiler.cfg.comparisons

SYMBOLS: cc< cc<= cc= cc> cc>= cc/= ;

: negate-cc ( cc -- cc' )
    H{
        { cc< cc>= }
        { cc<= cc> }
        { cc> cc<= }
        { cc>= cc< }
        { cc= cc/= }
        { cc/= cc= }
    } at ;

: swap-cc ( cc -- cc' )
    H{
        { cc< cc> }
        { cc<= cc>= }
        { cc> cc< }
        { cc>= cc<= }
        { cc= cc= }
        { cc/= cc/= }
    } at ;

: evaluate-cc ( result cc -- ? )
    H{
        { cc<  { +lt+           } }
        { cc<= { +lt+ +eq+      } }
        { cc=  {      +eq+      } }
        { cc>= {      +eq+ +gt+ } }
        { cc>  {           +gt+ } }
        { cc/= { +lt+      +gt+ } }
    } at memq? ;