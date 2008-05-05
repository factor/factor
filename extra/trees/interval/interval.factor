! Copyright (c) 2008 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: trees trees.avl kernel math accessors math.intervals
math.order assocs ;
IN: trees.interval

TUPLE: int-node interval max-under value ;
: <int-node> ( value start end -- int-node )
    [ [a,b] ] keep rot int-node boa ;

: interval-choose-branch ( key node -- key left/right )
    dup left>> [
        max-under>> pick >= [ left>> ] [ right>> ] if
    ] [ right>> ] if* ;

: (interval-at*) ( key node -- value ? )
    [
        2dup value>> interval>> interval-contains?
        [ nip value>> value>> t ]
        [ interval-choose-branch (interval-at*) ] if
    ] [ drop f f ] if* ;

: interval-at* ( key tree -- value ? )
    root>> (interval-at*) ;

: interval-at ( key tree -- value ) interval-at* drop ;
: interval-key? ( key tree -- ? ) interval-at* nip ;

: update-max-under ( max key node -- )
    ! The outer conditional shouldn't be necessary
    [
        2dup key>> = [ 3drop ] [
            [ nip value>> [ max ] change-max-under drop ]
            [ choose-branch update-max-under ] 3bi
        ] if
    ] [ 2drop ] if* ;

: add-range ( value start end tree -- )
    [ >r over >r <int-node> r> r> set-at ]
    [ root>> swapd update-max-under ] 3bi ;

: add-single ( value key tree -- ) dupd add-range ;
