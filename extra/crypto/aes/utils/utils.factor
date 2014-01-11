! Copyright (C) 2013 Fred Alger
! See http://factorcode.org/license.txt for BSD license.
USING: arrays columns combinators generalizations grouping
kernel locals math math.bitwise prettyprint sequences
sequences.private ;
IN: crypto.aes.utils
: gb0 ( a -- a0 ) 0xff bitand ; inline
: gb1 ( a -- a1 ) -8 shift gb0 ; inline
: gb2 ( a -- a2 ) -16 shift gb0 ; inline
: gb3 ( a -- a3 ) -24 shift gb0 ; inline

#! pack 4 bytes into 32-bit unsigned int
#!  a3 is msb
: >ui32 ( a0 a1 a2 a3 -- a )
    [ 8 shift ] [ 16 shift ] [ 24 shift ] tri*
    bitor bitor bitor 32 bits ;

#! inverse of ui32
: ui32> ( word -- a0 a1 a2 a3 )
    [ gb0 ] keep [ gb1 ] keep [ gb2 ] keep gb3 ; inline

: ui32-rev> ( word -- a3 a2 a1 a0 )
    [ gb3 ] keep [ gb2 ] keep [ gb1 ] keep gb0 ; inline

: bytes>words ( seq -- seq )
    4 <sliced-groups> [ <reversed> first4 >ui32 ] V{ } map-as ;

: .t ( seq -- )
    reverse
    {
        [ [ gb0 ] map first4 >ui32 ]
        [ [ gb1 ] map first4 >ui32 ]
        [ [ gb2 ] map first4 >ui32 ]
        [ [ gb3 ] map first4 >ui32 ]
    } cleave .h .h .h .h ;


#! given 4 columns, output the first diagonal, i.e.
#!  C[0,0] C[1,1] C[2,2] C[3,3]
: first-diag ( c0 c1 c2 c3 -- a0 a1 a2 a3 )
    { [ gb3 ] [ gb2 ] [ gb1 ] [ gb0 ] } spread ;

: (4rot) ( c0 c1 c2 c3 -- c1 c2 c3 c0 ) 4 nrot ; inline
: second-diag ( c0 c1 c2 c3 -- a0 a1 a2 a3 ) (4rot) first-diag ;
: third-diag  ( c0 c1 c2 c3 -- a0 a1 a2 a3 ) (4rot) second-diag ;
: fourth-diag ( c0 c1 c2 c3 -- a0 a1 a2 a3 ) (4rot) third-diag ;

#! given 4 columns, output the first reverse diagonal, i.e.
#!  C[0,0] C[3,1] C[2,2] C[1,3]
:: (-rev) ( c0 c1 c2 c3 -- c0 c3 c2 c1 ) c0 c3 c2 c1 ; inline
: -first-diag  ( c0 c1 c2 c3 -- a0 a1 a2 a3 ) (-rev) first-diag ;
: -second-diag ( c0 c1 c2 c3 -- a0 a1 a2 a3 ) (-rev) (4rot) first-diag ;
: -third-diag  ( c0 c1 c2 c3 -- a0 a1 a2 a3 ) (-rev) (4rot) second-diag ;
: -fourth-diag ( c0 c1 c2 c3 -- a0 a1 a2 a3 ) (-rev) (4rot) third-diag ;

:: set-first4-unsafe ( seq a0 a1 a2 a3 -- )
    a0 0 seq set-nth-unsafe
    a1 1 seq set-nth-unsafe
    a2 2 seq set-nth-unsafe
    a3 3 seq set-nth-unsafe ;

: 4th-from-end ( seq -- el )
    [ length 4 - ] keep nth ;

