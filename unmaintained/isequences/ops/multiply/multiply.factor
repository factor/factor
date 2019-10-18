! Copyright (C) 2007 Robbert van Dalen.
! See http://factorcode.org/license.txt for BSD license.

IN: isequences.ops.multiply
USING: generic kernel math math.functions sequences
isequences.interface isequences.base ;

: _*g++ ( n s -- s )
    swap i-length dup zero?
    [ 2drop 0 ]
    [ dup odd? [ over ] [ 0 ] if -rot 2/ swap _*g++ dup ++ ++ ]
    if ;

: _*g+- ( n s -- s ) -- _* -- ; inline

: _*g-+ ( n s -- s ) swap -- swap _* ; inline

: _*g-- ( n s -- s ) [ -- ] 2apply _* ; inline

: _*g ( n s -- s )
    2dup [ neg? ] 2apply [ [ _*g-- ] [ _*g+- ] if ]
    [ [ _*g-+ ] [ _*g++ ] if ] if ; inline

M: object _* _*g ;
M: integer _* swap i-length abs * ;

