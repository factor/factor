! Copyright (C) 2008, 2023 Slava Pestov and Raghu Ranganathan.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays math kernel accessors sequences sequences.private
deques search-deques hashtables ;
IN: unrolled-lists

CONSTANT: unroll-factor 32

<PRIVATE

MIXIN: ?node
INSTANCE: f ?node
TUPLE: node { data array } { prev ?node } { next ?node } ;
INSTANCE: node ?node

PRIVATE>

TUPLE: unrolled-list
{ front ?node } { front-pos fixnum }
{ back ?node } { back-pos fixnum } ;

: <unrolled-list> ( -- list )
    unrolled-list new
        unroll-factor >>back-pos ; inline

: <hashed-unrolled-list> ( -- search-deque )
    20 <hashtable> <unrolled-list> <search-deque> ;

ERROR: empty-unrolled-list list ;

<PRIVATE

M: unrolled-list deque-empty?
    dup [ front>> ] [ back>> ] bi dup [
        eq? [ [ front-pos>> ] [ back-pos>> ] bi eq? ] [ drop f ] if
    ] [ 3drop t ] if ;

M: unrolled-list clear-deque
    f >>front
    0 >>front-pos
    f >>back
    unroll-factor >>back-pos
    drop ;

: <front-node> ( elt front -- node )
    [
        unroll-factor 0 <array>
        [ unroll-factor 1 - swap set-nth ] keep f
    ] dip [ node boa dup ] keep
    [ prev<< ] [ drop ] if* ; inline

: normalize-back ( list -- )
    dup back>> [
        dup prev>> [ drop ] [ swap front>> >>prev ] if
    ] [ dup front>> >>back ] if* drop ; inline

: clear-if-empty ( list -- )
    dup deque-empty? [ dup clear-deque ] when drop ;

: push-front/new ( elt list -- )
    unroll-factor 1 - >>front-pos
    [ <front-node> ] change-front
    normalize-back ; inline

: push-front/existing ( elt list front -- )
    [ [ 1 - ] change-front-pos ] dip
    [ front-pos>> ] [ data>> ] bi* set-nth-unsafe ; inline

M: unrolled-list push-front*
    dup [ front>> ] [ front-pos>> 0 eq? not ] bi
    [ drop ] [ and ] 2bi
    [ push-front/existing ] [ drop push-front/new ] if f ;

M: unrolled-list peek-front*
    dup front>>
    [ [ front-pos>> ] dip data>> nth-unsafe t ]
    [ drop f f ]
    if* ;

: pop-front/new ( list front -- )
    [ 0 >>front-pos ] dip
    [ f ] change-next drop dup [ f >>prev ] when >>front
    dup front>> [ normalize-back ] [ f >>back drop ] if ; inline

: pop-front/existing ( list front -- )
    [ dup front-pos>> ] [ data>> ] bi* [ 0 ] 2dip set-nth-unsafe
    [ 1 + ] change-front-pos
    clear-if-empty ; inline

M: unrolled-list pop-front*
    dup front>> [ empty-unrolled-list ] unless*
    over front-pos>> unroll-factor 1 - eq?
    [ pop-front/new ] [ pop-front/existing ] if ;

: <back-node> ( elt back -- node )
    [
        unroll-factor 0 <array> [ set-first ] keep
    ] dip [ f node boa dup ] keep
    [ next<< ] [ drop ] if* ; inline

: normalize-front ( list -- )
    dup front>> [
        dup next>> [ drop ] [ swap back>> >>next ] if
    ] [ dup back>> >>front ] if* drop ; inline

: push-back/new ( elt list -- )
    1 >>back-pos
    [ <back-node> ] change-back
    normalize-front ; inline

: push-back/existing ( elt list back -- )
    [ [ 1 + ] change-back-pos ] dip
    [ back-pos>> 1 - ] [ data>> ] bi* set-nth-unsafe ; inline

M: unrolled-list push-back*
    dup [ back>> ] [ back-pos>> unroll-factor eq? not ] bi
    [ drop ] [ and ] 2bi
    [ push-back/existing ] [ drop push-back/new ] if f ;

M: unrolled-list peek-back*
    dup back>>
    [ [ back-pos>> 1 - ] dip data>> nth-unsafe t ]
    [ drop f f ]
    if* ;

: pop-back/new ( list back -- )
    [ unroll-factor >>back-pos ] dip
    [ f ] change-prev drop dup [ f >>next ] when >>back
    dup back>> [ normalize-front ] [ f >>front drop ] if ; inline

: pop-back/existing ( list back -- )
    [ [ 1 - ] change-back-pos ] dip
    [ dup back-pos>> ] [ data>> ] bi* [ 0 ] 2dip set-nth-unsafe
    clear-if-empty ; inline

M: unrolled-list pop-back*
    dup back>> [ empty-unrolled-list ] unless*
    over back-pos>> 1 eq?
    [ pop-back/new ] [ pop-back/existing ] if ;

PRIVATE>

INSTANCE: unrolled-list deque
