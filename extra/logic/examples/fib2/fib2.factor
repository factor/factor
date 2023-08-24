! Copyright (C) 2020 KUSUMOTO Norio.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs kernel logic math ;
IN: logic.examples.fib2

LOGIC-PREDS: fibo ;
LOGIC-VARS: F F1 F2 N N1 N2 ;

{ fibo 1 1 } fact
{ fibo 2 1 } fact
{ fibo N F } {
    { (>) N 2 }
    [ [ N of 1 - ] N1 is ] { fibo N1 F1 }
    [ [ N of 2 - ] N2 is ] { fibo N2 F2 }
    [ [ [ F1 of ] [ F2 of ] bi + ] F is ]
    [
        [
            [ N of ] [ F of ] bi
            [let :> ( nv fv ) { fibo nv fv } !! rule* ]
        ] invoke ]
} rule
