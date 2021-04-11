! Copyright (C) 2021 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays constructors growable kernel math
multiline sequences vectors ;
IN: cursors2

TUPLE: cursor ;
TUPLE: sequence-input-cursor < cursor seq n ;
CONSTRUCTOR: <sequence-input-cursor> sequence-input-cursor ( seq n -- obj ) ;

TUPLE: sequence-output-cursor < cursor seq n ;
CONSTRUCTOR: <sequence-output-cursor> sequence-output-cursor ( seq n -- obj ) ;

TUPLE: mapping-cursor < cursor output input ;
CONSTRUCTOR: <mapping-cursor> mapping-cursor ( output input -- obj ) ;

TUPLE: alist-cusor < cursor alist n ;

GENERIC: cursor-at ( cursor -- obj/f ? )
M: sequence-input-cursor cursor-at
    [ n>> ] [ seq>> ] bi
    2dup bounds-check? [ nth t ] [ 2drop f f ] if ;

GENERIC: cursor-inc-input ( cursor -- cursor' )
M: sequence-input-cursor cursor-inc-input
    [ seq>> ] [ n>> ] bi 1 + <sequence-input-cursor> ;
M: mapping-cursor cursor-inc-input
    [ cursor-inc-input ] change-input ;


GENERIC: cursor-put ( obj cursor -- cursor' )
M: sequence-output-cursor cursor-put
    [ n>> ] [ seq>> ] bi
    [ set-nth ] 2keep swap 1 + <sequence-output-cursor> ;

M: mapping-cursor cursor-put
    [ cursor-put ] change-output ;

GENERIC: input>output-cursor ( cursor -- cursor' )
M: array input>output-cursor length 0 <array> 0 <sequence-output-cursor> ;
M: vector input>output-cursor capacity <vector> 0 <sequence-output-cursor> ;
M: sequence-input-cursor input>output-cursor seq>> length <vector> 0 <sequence-output-cursor> ;


GENERIC: >input-cursor ( obj -- cursor )
M: array >input-cursor 0 <sequence-input-cursor> ;
M: vector >input-cursor 0 <sequence-input-cursor> ;


: input>mapping-cursor ( input-cursor -- mapping-cursor )
    >input-cursor [ input>output-cursor ] keep <mapping-cursor> ;


: (find2) ( cursor quot: ( cursor obj -- ? ) -- cursor/f elt/f ? )
    over cursor-at [
        [ swap [ f f ] if* ] 3keep
        roll [ nip t ] [ drop [ cursor-inc-input ] dip (find2) ] if
    ] [
        2drop f f
    ] if ; inline recursive

: find2 ( obj quot -- elt/f i/f )
    [ >input-cursor ] dip (find2) ; inline



: each-cursor-advance ( cursor elt quot: ( cursor elt -- ) -- )
    [ call ] 3keep nip
    [ cursor-inc-input ] dip ; inline

: mapping-cursor-advance ( cursor elt quot: ( cursor elt -- out ) -- mapping-cursor' quot )
    [ call ] 3keep nip
    [
        [ output>> cursor-put ] [ input>> cursor-inc-input ] bi <mapping-cursor>
    ] dip ; inline

: filter-cursor-advance ( cursor elt quot: ( cursor elt -- ? ) -- mapping-cursor' quot )
    [ call ] 3keep
    [
        swapd
        '[ _ [ _ swap output>> cursor-put ] [ output>> ] if ]
        [ input>> cursor-inc-input ] bi <mapping-cursor>
    ] dip ; inline

: (each2) ( cursor quot: ( cursor obj -- ) -- )
    over cursor-at [
        swap each-cursor-advance (each2)
    ] [
        3drop
    ] if ; inline recursive

: each2 ( obj quot -- elt/f i/f )
    [ >input-cursor ] dip (each2) ; inline


: (map2) ( cursor quot: ( cursor obj -- obj' ) -- out )
    over input>> cursor-at [
        swap mapping-cursor-advance (map2)
    ] [
        2drop output>>
    ] if ; inline recursive

: map2 ( obj quot -- obj' )
    [ input>mapping-cursor ] dip (map2) ; inline


: (filter2) ( cursor quot: ( cursor obj -- obj' ) -- out )
    over input>> cursor-at [
        swap filter-cursor-advance (filter2)
    ] [
        2drop output>>
    ] if ; inline recursive

: filter2 ( obj quot -- obj' )
    [ input>mapping-cursor ] dip (filter2) ; inline
