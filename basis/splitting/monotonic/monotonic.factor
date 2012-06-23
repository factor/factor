! Copyright (C) 2008, 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays circular combinators
combinators.short-circuit compiler.utilities fry grouping
kernel make math math.order namespaces sequences sorting ;
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

: monotonic-split ( seq quot: ( obj1 obj2 -- ? ) -- newseq )
    over empty? [ 2drop { } ] [ (monotonic-split) ] if ; inline

<PRIVATE

: (monotonic-slice) ( seq quot class -- slices )
    [
        dupd '[
            [ length iota ] [ ] [ <circular> 1 over change-circular-start ] tri
            [ @ not [ 1 + , ] [ drop ] if ] 3each
        ] { } make
        2dup {
            [ nip empty? ]
            [ [ length ] [ last ] bi* = not ]
        } 2|| [ over length suffix ] when
        0 prefix 2 clump
        swap
    ] dip
    '[ first2 _ _ boa ] map ; inline

PRIVATE>

: monotonic-slice ( seq quot: ( obj1 obj2 -- ? ) class -- slices )
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
            [ upward-slices ] tri 3append [ from>> ] sort-with
        ]
    } case ;
