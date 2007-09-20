! Copyright (C) 2007 Robbert van Dalen.
! See http://factorcode.org/license.txt for BSD license.

IN: isequences.ops.sort
USING: generic kernel math sequences isequences.interface isequences.base ;


: <_g++ ( n s -- s )
    i-union ; inline

: <_g+- ( n s -- s ) -- <_ ; inline

: <_g-+ ( n s -- s ) swap -- swap <_ ; inline

: <_g-- ( n s -- s ) [ -- ] 2apply <_ ; inline

: <_g ( n s -- s )
    2dup [ neg? ] 2apply [ [ <_g-- ] [ <_g+- ] if ]
    [ [ <_g-+ ] [ <_g++ ] if ] if ; inline

M: object <_ <_g ;

: _<g++ ( n s -- s )
    i-diff ; inline

: _<g+- ( n s -- s ) -- _< ; inline

: _<g-+ ( n s -- s ) swap -- swap _< ; inline

: _<g-- ( n s -- s ) [ -- ] 2apply _< ; inline

: _<g ( n s -- s )
    2dup [ neg? ] 2apply [ [ _<g-- ] [ _<g+- ] if ]
    [ [ _<g-+ ] [ _<g++ ] if ] if ; inline

M: object _< _<g ;
