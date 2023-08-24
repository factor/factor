! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators combinators.short-circuit
compiler.tree.propagation.transforms kernel math
sequences sequences.private ;
IN: sequences.unrolled

<PRIVATE
: (unrolled-each-integer) ( quot n -- )
    swap '[ _ call( i -- ) ] each-integer ;

<< \ (unrolled-each-integer) [
    <iota> [ '[ _ swap call( i -- ) ] ] [ ] map-as '[ _ cleave ]
] 1 define-partial-eval >>

: (unrolled-collect) ( quot into -- quot' )
    '[ dup @ swap _ set-nth-unsafe ] ; inline

PRIVATE>

: unrolled-each-integer ( n quot: ( i -- ) -- )
    swap (unrolled-each-integer) ; inline

: unrolled-collect ( n quot: ( n -- value ) into -- )
    (unrolled-collect) unrolled-each-integer ; inline

: unrolled-map-integers-as ( n quot: ( n -- value ) exemplar -- newseq )
    overd [ [ unrolled-collect ] keep ] new-like ; inline

ERROR: unrolled-bounds-error
    seq unroll-length ;

ERROR: unrolled-2bounds-error
    xseq yseq unroll-length ;

<PRIVATE
: unrolled-bounds-check ( seq len quot -- seq len quot )
    2over swap length > [ 2over unrolled-bounds-error ] when ; inline

:: unrolled-2bounds-check ( xseq yseq len quot -- xseq yseq len quot )
    { [ len xseq length > ] [ len yseq length > ] } 0||
    [ xseq yseq len unrolled-2bounds-error ]
    [ xseq yseq len quot ] if ; inline

: (unrolled-each) ( seq len quot -- len quot )
    swapd '[ _ nth-unsafe @ ] ; inline

: (unrolled-each-index) ( seq len quot -- len quot )
    swapd '[ dup _ nth-unsafe swap @ ] ; inline

: (unrolled-2each) ( xseq yseq len quot -- len quot )
    [ '[ _ ] 2dip ] dip 2length-operator nip ; inline

: unrolled-each-unsafe ( seq len quot: ( x -- ) -- )
    (unrolled-each) unrolled-each-integer ; inline

: unrolled-2each-unsafe ( xseq yseq len quot: ( x y -- ) -- )
    (unrolled-2each) unrolled-each-integer ; inline

: unrolled-each-index-unsafe ( seq len quot: ( x -- ) -- )
    (unrolled-each-index) unrolled-each-integer ; inline

: unrolled-map-as-unsafe ( seq len quot: ( x -- newx ) exemplar -- newseq )
    [ (unrolled-each) ] dip unrolled-map-integers-as ; inline

: unrolled-2map-as-unsafe ( xseq yseq len quot: ( x y -- newx ) exemplar -- newseq )
    [ (unrolled-2each) ] dip unrolled-map-integers-as ; inline

: unrolled-map-unsafe ( seq len quot: ( x -- newx ) -- newseq )
    pick unrolled-map-as-unsafe ; inline

: unrolled-2map-unsafe ( xseq yseq len quot: ( x y -- newx ) -- newseq )
    reach unrolled-2map-as-unsafe ; inline

PRIVATE>

: unrolled-each ( seq len quot: ( x -- ) -- )
    unrolled-bounds-check unrolled-each-unsafe ; inline

: unrolled-2each ( xseq yseq len quot: ( x y -- ) -- )
    unrolled-2bounds-check unrolled-2each-unsafe ; inline

: unrolled-each-index ( seq len quot: ( x i -- ) -- )
    unrolled-bounds-check unrolled-each-index-unsafe ; inline

: unrolled-map-as ( seq len quot: ( x -- newx ) exemplar -- newseq )
    [ unrolled-bounds-check ] dip unrolled-map-as-unsafe ; inline

: unrolled-2map-as ( xseq yseq len quot: ( x y -- newx ) exemplar -- newseq )
    [ unrolled-2bounds-check ] dip unrolled-2map-as-unsafe ; inline

: unrolled-map ( seq len quot: ( x -- newx ) -- newseq )
    pick unrolled-map-as ; inline

: unrolled-2map ( xseq yseq len quot: ( x y -- newx ) -- newseq )
    reach unrolled-2map-as ; inline

: unrolled-map-index ( seq len quot: ( x i -- newx ) -- newseq )
    [ dup length <iota> ] 2dip unrolled-2map ; inline
