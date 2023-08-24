! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.vectors sequences ;
IN: math.vectors.homogeneous

: (homogeneous-xyz) ( h -- xyz )
    but-last ; inline

: (homogeneous-w) ( h -- w )
    last ; inline

: h+ ( a b -- c )
    2dup [ (homogeneous-w) ] bi@ over =
    [ [ [ (homogeneous-xyz) ] bi@ v+ ] dip suffix ] [
        drop
        [ [ (homogeneous-xyz) ] [ (homogeneous-w)   ] bi* v*n    ]
        [ [ (homogeneous-w)   ] [ (homogeneous-xyz) ] bi* n*v v+ ]
        [ [ (homogeneous-w)   ] [ (homogeneous-w)   ] bi* * suffix ] 2tri
    ] if ;

: n*h ( n h -- nh )
    [ (homogeneous-xyz) n*v ] [ (homogeneous-w) suffix ] bi ;

: h*n ( h n -- nh )
    swap n*h ;

: hneg ( h -- -h )
    -1.0 swap n*h ;

: h- ( a b -- c )
    hneg h+ ;

: v>h ( v -- h )
    1.0 suffix ;

: h>v ( h -- v )
    [ (homogeneous-xyz) ] [ (homogeneous-w) ] bi v/n ;
