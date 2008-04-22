! Copyright (c) 2008 Eric Mertens
! See http://factorcode.org/license.txt for BSD license.
USING: sequences combinators kernel sequences.lib math assocs namespaces ;
IN: project-euler.151

SYMBOL: table

: (pick-sheet) ( seq i -- newseq )
    [
        <=> sgn
        {
            { -1 [ ] }
            {  0 [ 1- ] }
            {  1 [ 1+ ] }
        } case
    ] curry map-index ;

DEFER: (euler151)

: pick-sheet ( seq i -- res )
    2dup swap nth dup zero? [
        3drop 0
    ] [
        [ (pick-sheet) (euler151) ] dip *
    ] if ;

: (euler151) ( x -- y )
    table get [ {
        { { 0 0 0 1 } [ 0 ] }
        { { 0 0 1 0 } [ { 0 0 0 1 } (euler151) 1+ ] }
        { { 0 1 0 0 } [ { 0 0 1 1 } (euler151) 1+ ] }
        { { 1 0 0 0 } [ { 0 1 1 1 } (euler151) 1+ ] }
        [ [ dup length [ pick-sheet ] with map sum ] [ sum ] bi / ]
     } case ] cache ;

: euler151 ( -- n )
    [
        H{ } clone table set
        { 1 1 1 1 } (euler151)
    ] with-scope ;
