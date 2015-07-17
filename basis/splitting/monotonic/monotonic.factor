! Copyright (C) 2008, 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays fry kernel locals make math namespaces
sequences sorting ;
IN: splitting.monotonic

<PRIVATE

: (monotonic-split) ( seq quot -- newseq )
    [ V{ } clone V{ } clone ] 2dip [ ] swap '[
        [ [ suffix! ] keep ] dip
        [ @ [ suffix! V{ } clone ] unless ] keep
    ] map-reduce suffix! suffix! { } like ; inline

PRIVATE>

: monotonic-split ( seq quot: ( obj1 obj2 -- ? ) -- newseq )
    over empty? [ 2drop { } ] [ (monotonic-split) ] if ; inline

<PRIVATE

:: (monotonic-slice) ( seq quot: ( obj1 obj2 -- ? ) slice-class -- slices )
    seq length :> len
    [
        0 ,

        0 seq [ ] [
            [ 1 + ] 2dip
            [ quot call [ dup , ] unless ] keep
        ] map-reduce 2drop

        len building get ?last = [ len , ] unless

    ] { } make dup rest-slice [ seq slice-class boa ] 2map ; inline

PRIVATE>

: monotonic-slice ( seq quot: ( obj1 obj2 -- ? ) slice-class -- slices )
    pick length dup 1 > [
        drop (monotonic-slice)
    ] [
        zero? [ 3drop { } ] [ nip [ 0 1 ] 2dip boa 1array ] if
    ] if ; inline

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
        zero? [ drop { } ] [ [ 0 1 ] dip stable-slice boa ] if
    ] if ;
