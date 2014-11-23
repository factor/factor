! Copyright (C) 2010 Daniel Ehrenberg
! Copyright (C) 2005, 2011 John Benediktsson, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays growable.private hash-sets
hashtables.private kernel kernel.private math math.private
sequences sequences.private sets sets.private slots.private
vectors ;
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

: new-key@ ( key hash -- array n ? )
    [ array>> 2dup hash@ 0 f (new-key@) ] keep swap
    [ over [ hash-deleted- ] [ hash-count+ ] if swap or t ] [ 2drop f ] if ; inline

: set-nth-item ( key seq n -- )
    2 fixnum+fast set-slot ; inline

: (adjoin) ( key hash -- ? )
    dupd new-key@ [ set-nth-item ] dip ; inline

: (rehash) ( seq hash -- )
    [ (adjoin) drop ] curry each ; inline

: hash-large? ( hash -- ? )
    [ count>> 3 fixnum*fast ]
    [ array>> length>> 1 fixnum-shift-fast ] bi fixnum>= ; inline

: each-member ( ... array quot: ( ... elt -- ... ) -- ... )
    [ if ] curry [ dup tombstone? [ drop ] ] prepose each ; inline

: grow-hash ( hash -- )
    { hash-set } declare [
        [ array>> ]
        [ cardinality 1 + ]
        [ reset-hash ] tri
    ] keep [ (adjoin) drop ] curry each-member ;

: ?grow-hash ( hash -- )
    dup hash-large? [ grow-hash ] [ drop ] if ; inline

PRIVATE>

: <hash-set> ( capacity -- hash-set )
    [ 0 0 ] dip <hash-array> hash-set boa ; inline

M: hash-set in?
     key@ 2nip ;

M: hash-set clear-set
    [ init-hash ] [ array>> [ drop ((empty)) ] map! drop ] bi ;

M: hash-set delete
    [ nip ] [ key@ ] 2bi [
        [ ((tombstone)) ] 2dip set-nth-item
        hash-deleted+
    ] [
        3drop
    ] if ;

M: hash-set cardinality
    [ count>> ] [ deleted>> ] bi - ; inline

: rehash ( hash-set -- )
    [ members ] [ clear-set ] [ (rehash) ] tri ;

M: hash-set adjoin
    dup ?grow-hash (adjoin) drop ;

M: hash-set ?adjoin
    dup ?grow-hash (adjoin) ;

M: hash-set members
    [ array>> 0 swap ] [ cardinality f <array> ] bi [
        [ [ over ] dip set-nth-unsafe 1 + ] curry each-member
    ] keep nip ;

M: hash-set clone
    (clone) [ clone ] change-array ; inline

M: hash-set equal?
    over hash-set? [ set= ] [ 2drop f ] if ;

: >hash-set ( members -- hash-set )
    dup length <hash-set> [ (rehash) ] keep ; inline

M: hash-set set-like
    drop dup hash-set? [ ?members >hash-set ] unless ; inline

INSTANCE: hash-set set

! Overrides for performance

<PRIVATE

: and-tombstones ( quot: ( elt -- ? ) -- quot: ( elt -- ? ) )
    [ if ] curry [ dup tombstone? [ drop t ] ] prepose ; inline

: not-tombstones ( quot: ( elt -- ? ) -- quot: ( elt -- ? ) )
    [ if ] curry [ dup tombstone? [ drop f ] ] prepose ; inline

: array/tester ( hash-set1 hash-set2 -- array quot )
    [ array>> ] dip [ in? ] curry ; inline

: filter-members ( hash-set array quot: ( elt -- ? ) -- accum )
    [ dup ] prepose rot cardinality <vector> [
        [ push-unsafe ] curry [ [ drop ] if ] curry
        compose each
    ] keep ; inline

PRIVATE>

M: hash-set intersect
    over hash-set? [
        small/large dupd array/tester not-tombstones
        filter-members >hash-set
    ] [ (intersect) >hash-set ] if ;

M: hash-set intersects?
    over hash-set? [
        small/large array/tester not-tombstones any?
    ] [ small/large sequence/tester any? ] if ;

M: hash-set union
    over hash-set? [
        small/large [ array>> ] [ clone ] bi*
        [ [ adjoin ] curry each-member ] keep
    ] [ (union) >hash-set ] if ;

M: hash-set diff
    over hash-set? [
        dupd array/tester [ not ] compose not-tombstones
        filter-members >hash-set
    ] [ (diff) >hash-set ] if ;

M: hash-set subset?
    over hash-set? [
        2dup [ cardinality ] bi@ > [ 2drop f ] [
            array/tester and-tombstones all?
        ] if
    ] [ call-next-method ] if ;

M: hash-set set=
    over hash-set? [
        2dup [ cardinality ] bi@ eq? [
            array/tester and-tombstones all?
        ] [ 2drop f ] if
    ] [ call-next-method ] if ;

! Default methods

M: f fast-set drop 0 <hash-set> ;

M: sequence fast-set >hash-set ;

M: sequence duplicates
    dup length <hash-set> [ ?adjoin not ] curry filter ;

M: sequence all-unique?
    dup length <hash-set> [ ?adjoin ] curry all? ;
