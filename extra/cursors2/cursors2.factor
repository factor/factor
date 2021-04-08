! Copyright (C) 2021 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays constructors growable kernel math
sequences vectors ;
IN: cursors2

TUPLE: cursor ;
TUPLE: sequence-input-cursor < cursor seq n ;
CONSTRUCTOR: <sequence-input-cursor> sequence-input-cursor ( seq n -- obj ) ;

TUPLE: sequence-output-cursor < cursor seq n ;
CONSTRUCTOR: <sequence-output-cursor> sequence-output-cursor ( seq n -- obj ) ;

TUPLE: mapping-cursor < cursor input output ;
CONSTRUCTOR: <mapping-cursor> mapping-cursor ( input output -- obj ) ;

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
    >input-cursor dup input>output-cursor <mapping-cursor> ;


: (find2) ( cursor quot: ( cursor obj -- ? ) -- cursor/f elt/f ? )
    over cursor-at [
        [ swap [ f f ] if* ] 3keep
        roll [ nip t ] [ drop [ cursor-inc-input ] dip (find2) ] if
    ] [
        2drop f f
    ] if ; inline recursive

: find2 ( obj quot -- elt/f i/f )
    [ >input-cursor ] dip (find2) ; inline


: (each2) ( cursor quot: ( cursor obj -- ) -- )
    over cursor-at [
        [ swap call ] 3keep drop
        [ cursor-inc-input ] dip (each2)
    ] [
        3drop
    ] if ; inline recursive

: each2 ( obj quot -- elt/f i/f )
    [ >input-cursor ] dip (each2) ; inline


: (map2) ( cursor quot: ( cursor obj -- obj' ) -- out )
    over input>> cursor-at [
        [ swap call ] 3keep drop
        [ [ cursor-put ] change-output [ cursor-inc-input ] change-input ] dip (map2)
    ] [
        2drop output>>
    ] if ; inline recursive

: map2 ( obj quot -- obj' )
    [ input>mapping-cursor ] dip (map2) ; inline
