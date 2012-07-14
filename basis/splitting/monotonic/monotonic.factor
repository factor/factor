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
    [ drop { } ] [ (monotonic-split) ] if-empty ; inline

<PRIVATE

: (monotonic-slice) ( seq quot class -- slices )
    [
        dupd '[
            [ length iota ] [ ] [ 1 circular boa ] tri
            [ @ not [ 1 + , ] [ drop ] if ] 3each
        ] { } make
        2dup {
            [ nip empty? ]
            [ [ length ] [ last ] bi* = not ]
        } 2|| [ over length suffix ] when
        0 prefix 2 <clumps>
        swap
    ] dip
    '[ first2 _ _ boa ] map ; inline

PRIVATE>

: monotonic-slice ( seq quot: ( obj1 obj2 -- ? ) class -- slices )
    pick length dup 1 >
    [ drop (monotonic-slice) ]
    [ zero? [ 2drop ] [ nip [ 0 1 ] 2dip boa 1array ] if ]
    if ; inline

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
    dup length dup 1 > [
        drop
        [ downward-slices ]
        [ stable-slices ]
        [ upward-slices ] tri 3append [ from>> ] sort-with
    ] [
        zero? [ ] [ [ 0 1 ] dip stable-slice boa ] if
    ] if ;
