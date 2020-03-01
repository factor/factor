! Copyright (C) 2019-2020 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: factlog kernel lists assocs math ;
IN: factlog.examples.fib

LOGIC-PREDS: fibo ;
LOGIC-VARS: F F1 F2 N N1 L ;

{ fibo N L{ F F1 F2 . L } } {
    { (>) N 1 }
    [ [ N of 1 - ] N1 is ]
    { fibo N1 L{ F1 F2 . L } }
    [ [ [ F1 of ] [ F2 of ] bi + ] F is ] !!
} rule

{ fibo 0 L{ 0 } } !! rule

{ fibo 1 L{ 1 0 } } fact
