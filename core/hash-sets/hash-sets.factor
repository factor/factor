! Copyright (C) 2010 Daniel Ehrenberg
! Copyright (C) 2005, 2011 John Benediktsson, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays hash-sets hashtables.private kernel
kernel.private math math.private sequences sequences.private
sets sets.private slots.private vectors ;
IN: hash-sets

TUPLE: hash-set
{ count array-capacity }
{ deleted array-capacity }
{ array array } ;

<PRIVATE

: hash@ ( key array -- i )
    [ hashcode >fixnum ] dip wrap ; inline

: probe ( array i probe# -- array i probe# )
    1 fixnum+fast [ fixnum+fast over wrap ] keep ; inline

: no-key ( key array -- array n ? ) nip f f ; inline

: (key@) ( key array i probe# -- array n ? )
    [ 3dup swap array-nth ] dip over ((empty)) eq?
    [ 4drop no-key ] [
        [ = ] dip swap
        [ drop rot drop t ]
        [ probe (key@) ]
        if
    ] if ; inline recursive

: key@ ( key hash -- array n ? )
    array>> dup length>> 0 eq?
    [ no-key ] [ 2dup hash@ 0 (key@) ] if ; inline

: <hash-array> ( n -- array )
    1 + next-power-of-2 2 * ((empty)) <array> ; inline

: reset-hash ( n hash -- )
    swap <hash-array> >>array init-hash ; inline

: (new-key@) ( key array i probe# j -- array i j empty? )
    [ 2dup swap array-nth ] 2dip pick tombstone?
    [
        rot ((empty)) eq?
        [ nip [ drop ] 3dip t ]
        [ pick or [ probe ] dip (new-key@) ]
        if
    ] [
        [ [ pick ] dip = ] 2dip rot
        [ nip [ drop ] 3dip f ]
        [ [ probe ] dip (new-key@) ]
        if
    ] if ; inline recursive

: new-key@ ( key hash -- array n )
    [ array>> 2dup hash@ 0 f (new-key@) ] keep swap
    [ over [ hash-deleted- ] [ hash-count+ ] if swap or ] [ 2drop ] if ; inline

: set-nth-item ( key seq n -- )
    2 fixnum+fast set-slot ; inline

: (adjoin) ( key hash -- )
    dupd new-key@ set-nth-item ; inline

: (rehash) ( seq hash -- )
    [ (adjoin) ] curry each ; inline

: hash-large? ( hash -- ? )
    [ count>> 3 fixnum*fast 1 fixnum+fast ]
    [ array>> length>> 1 fixnum-shift-fast ] bi fixnum> ; inline

: grow-hash ( hash -- )
    { hash-set } declare [
        [ members { array } declare ]
        [ cardinality 1 + ]
        [ reset-hash ] tri
    ] keep (rehash) ;

: ?grow-hash ( hash -- )
    dup hash-large? [ grow-hash ] [ drop ] if ; inline

PRIVATE>

: <hash-set> ( n -- hash )
    hash-set new [ reset-hash ] keep ; inline

M: hash-set in? ( key hash -- ? )
     key@ 2nip ;

M: hash-set clear-set ( hash -- )
    [ init-hash ] [ array>> [ drop ((empty)) ] map! drop ] bi ;

M: hash-set delete ( key hash -- )
    [ nip ] [ key@ ] 2bi [
        [ ((tombstone)) ] 2dip set-nth-item
        hash-deleted+
    ] [
        3drop
    ] if ;

M: hash-set cardinality ( hash -- n )
    [ count>> ] [ deleted>> ] bi - ; inline

: rehash ( hash -- )
    [ members ] [ clear-set ] [ (rehash) ] tri ;

M: hash-set adjoin ( key hash -- )
    dup ?grow-hash (adjoin) ;

<PRIVATE

: push-unsafe ( elt seq -- )
    [ length ] keep
    [ underlying>> set-array-nth ]
    [ [ 1 fixnum+fast { array-capacity } declare ] dip length<< ]
    2bi ; inline

PRIVATE>

M: hash-set members
    [ array>> [ length ] keep ] [ cardinality <vector> ] bi [
        [
            [ array-nth ] dip over tombstone?
            [ 2drop ] [ push-unsafe ] if
        ] 2curry each-integer
    ] keep { } like ;

M: hash-set clone
    (clone) [ clone ] change-array ; inline

M: hash-set equal?
    over hash-set? [ set= ] [ 2drop f ] if ;

: >hash-set ( members -- hash-set )
    dup length <hash-set> [ (rehash) ] keep ;

M: hash-set set-like
    drop dup hash-set? [ ?members >hash-set ] unless ; inline

INSTANCE: hash-set set

M: hash-set intersect small/large sequence/tester filter >hash-set ;

M: hash-set union (union) >hash-set ;

M: hash-set diff sequence/tester [ not ] compose filter >hash-set ;

M: f fast-set drop 0 <hash-set> ;

M: sequence fast-set >hash-set ;

M: sequence duplicates
    dup length <hash-set> [ ?adjoin not ] curry filter ;

<PRIVATE

: (all-unique?) ( elt hash -- ? )
    2dup in? [ 2drop f ] [ adjoin t ] if ; inline

PRIVATE>

M: sequence all-unique?
    dup length <hash-set> [ (all-unique?) ] curry all? ;
