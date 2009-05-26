! Copyright (C) 2008, 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: make namespaces sequences kernel fry arrays compiler.utilities
math accessors circular grouping combinators sorting math.order ;
IN: splitting.monotonic

<PRIVATE

: ,, ( obj -- ) building get last push ;
: v, ( -- ) V{ } clone , ;
: ,v ( -- ) building get dup last empty? [ dup pop* ] when drop ;

: (monotonic-split) ( seq quot -- newseq )
    [
        [ dup unclip suffix ] dip
        v, '[ over ,, @ [ v, ] unless ] 2each ,v
    ] { } make ; inline

PRIVATE>

: monotonic-split ( seq quot -- newseq )
    over empty? [ 2drop { } ] [ (monotonic-split) ] if ; inline

<PRIVATE

: (monotonic-slice) ( seq quot class -- slices )
    [
        dupd '[
            [ length ] [ ] [ <circular> 1 over change-circular-start ] tri
            [ @ not [ , ] [ drop ] if ] 3each
        ] { } make
        dup empty? [ over length 1- prefix ] when -1 prefix 2 clump
        swap
    ] dip
    '[ first2 [ 1+ ] bi@ _ _ boa ] map ; inline

PRIVATE>

: monotonic-slice ( seq quot class -- slices )
    pick length {
        { 0 [ 2drop ] }
        { 1 [ nip [ 0 1 rot ] dip boa 1array ] }
        [ drop (monotonic-slice) ]
    } case ; inline

TUPLE: downward-slice < slice ;
TUPLE: stable-slice < slice ;
TUPLE: upward-slice < slice ;

: downward-slices ( seq -- slices )
    [ > ] downward-slice monotonic-slice [ length 1 > ] filter ;

: stable-slices ( seq -- slices )
    [ = ] stable-slice monotonic-slice [ length 1 > ] filter ;

: upward-slices ( seq -- slices )
    [ < ] upward-slice monotonic-slice [ length 1 > ] filter ;

: trends ( seq -- slices )
    dup length {
        { 0 [ ] }
        { 1 [ [ 0 1 ] dip stable-slice boa ] }
        [
            drop
            [ downward-slices ]
            [ stable-slices ]
            [ upward-slices ] tri 3append [ [ from>> ] compare ] sort
        ]
    } case ;
