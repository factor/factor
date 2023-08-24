! Copyright (C) 2008, 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays fry kernel locals math namespaces
sequences sequences.private sorting ;
IN: splitting.monotonic

<PRIVATE

:: monotonic-split-impl ( seq quot slice-quot n -- pieces )
    V{ } clone :> accum

    0 0 seq [ ] [
        [ 1 + ] 2dip [
            quot call [
                [ seq slice-quot call accum push ] keep dup
            ] unless
        ] keep
    ] map-reduce drop

    n = [ drop ] [ n seq slice-quot call accum push ] if

    accum { } like ; inline

: (monotonic-split) ( seq quot slice-quot -- pieces )
    pick length [ 3drop { } ] [ monotonic-split-impl ] if-zero ; inline

PRIVATE>

: monotonic-split ( seq quot: ( obj1 obj2 -- ? ) -- pieces )
    [ subseq-unsafe ] (monotonic-split) ; inline

: monotonic-split-slice ( seq quot: ( obj1 obj2 -- ? ) -- pieces )
    [ <slice-unsafe> ] (monotonic-split) ; inline

TUPLE: downward-slice < slice ;
TUPLE: stable-slice < slice ;
TUPLE: upward-slice < slice ;

: downward-slices ( seq -- slices )
    [ > ] [ downward-slice boa ] (monotonic-split)
    [ length 1 > ] filter ;

: stable-slices ( seq -- slices )
    [ = ] [ stable-slice boa ] (monotonic-split)
    [ length 1 > ] filter ;

: upward-slices ( seq -- slices )
    [ < ] [ upward-slice boa ] (monotonic-split)
    [ length 1 > ] filter ;

: trends ( seq -- slices )
    dup length dup 1 > [
        drop
        [ downward-slices ]
        [ stable-slices ]
        [ upward-slices ] tri 3append [ from>> ] sort-by
    ] [
        zero? [ drop { } ] [ [ 0 1 ] dip stable-slice boa ] if
    ] if ;
