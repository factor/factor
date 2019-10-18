! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences generic arrays math sequences-internals vectors ;
IN: assocs

! associative array protocol

GENERIC: at* ( key assoc -- value/f ? )
GENERIC: set-at ( value key assoc -- )
GENERIC: new-assoc ( size exemplar -- newassoc )
G: assoc-find ( assoc quot -- key value ? )
    1 standard-combination ; inline ! quot: key value -- ?
GENERIC: delete-at ( key assoc -- )
GENERIC: clear-assoc ( assoc -- )
GENERIC: assoc-size ( assoc -- n )
GENERIC: assoc-like ( assoc exemplar -- newassoc )
! Additionally, clone should be implemented properly

! Generic operations on assocs

: key? ( key assoc -- ? )
    at* nip ;

: assoc-with 2swap [ >r -rot r> call ] 2keep ; inline

: assoc-find-with ( obj assoc quot -- key value ? )
    swap [ assoc-with rot ] assoc-find
    >r >r 2nip r> r> ; inline

: assoc-each ( assoc quot -- )
    swap [ rot call f ] assoc-find-with 3drop ; inline

: assoc-each-with ( obj assoc quot -- )
    swap [ assoc-with ] assoc-each 2drop ; inline

: assoc>map ( assoc quot exemplar -- array ) ! quot: key value -- object
    rot [ assoc-size swap new 0 ] keep [
        2swap >r >r rot r> r>
        [ 2slip swap set-nth ] 3keep 1+
    ] assoc-each drop nip ; inline

: assoc-map ( assoc quot -- assoc )
    swap [ [
        pick >r rot call 2array r> swap
    ] V{ } assoc>map nip ] keep assoc-like ; inline

: assoc-map-with ( obj assoc quot -- assoc )
    swap [ assoc-with 2swap ] assoc-map 2nip ; inline

: assoc-push-if ( accum quot key value -- accum )
    roll >r [ rot call ] 2keep rot r> swap
    [ [ >r 2array r> push ] keep ] [ 2nip ] if ; inline

: assoc-subset ( assoc quot -- subassoc )
    swap [
        V{ } clone -rot
        [ assoc-push-if ] assoc-each-with
    ] keep assoc-like ; inline

: assoc-subset-with ( obj assoc quot -- assoc )
    swap [ assoc-with rot ] assoc-subset 2nip ; inline

: at ( key assoc -- value/f )
    at* drop ;

: assoc-clone-like ( assoc exemplar -- newassoc )
    over assoc-size swap new-assoc
    swap [ swap pick set-at ] assoc-each ;

: keys ( assoc -- keys )
    [ drop ] { } assoc>map ;

: values ( assoc -- values )
    [ nip ] { } assoc>map ;

: delete-at* ( key assoc -- old )
    [ at ] 2keep delete-at ;

: assoc-empty? ( assoc -- ? )
    assoc-size zero? ;

: (assoc-stack) ( key i seq -- value )
    over 0 < [
        3drop f
    ] [
        3dup nth-unsafe dup [
            at* [
                >r 3drop r>
            ] [
                drop >r 1- r> (assoc-stack)
            ] if
        ] [
            2drop >r 1- r> (assoc-stack)
        ] if
    ] if ;

: assoc-stack ( key seq -- value )
    dup length 1- swap (assoc-stack) ;

: assoc-all? ( assoc quot -- ? )
    swap [ rot call not ] assoc-find-with 2nip not ; inline

: assoc-all-with? ( obj assoc quot -- ? )
    swap [ assoc-with rot ] assoc-all? 2nip ; inline

: subassoc? ( assoc1 assoc2 -- ? )
    swap [
        >r swap at* [ r> = ] [ r> 2drop f ] if
    ] assoc-all-with? ;

: assoc= ( assoc assoc -- ? )
    2dup subassoc? >r swap subassoc? r> and ;

: assoc-hashcode ( n assoc -- code )
    0 -rot [
        >r over r> hashcode* >r hashcode* 2/ r> bitxor bitxor
    ] assoc-each-with ;

: intersect ( assoc1 assoc2 -- intersection )
    [ drop swap at ] assoc-subset-with ;

: update ( assoc1 assoc2 -- )
    [ swap rot set-at ] assoc-each-with ;

: union ( assoc1 assoc2 -- union )
    >r clone dup r> update ;

: remove-all ( assoc seq -- subseq )
    [ swap key? not ] subset-with ;

: cache ( key assoc quot -- value )
    pick pick at [
        >r 3drop r>
    ] [
        pick rot >r >r call dup r> r> set-at
    ] if* ; inline

: change-at ( key assoc quot -- )
    [ >r at r> call ] 3keep drop set-at ; inline

: at+ ( n key assoc -- )
    [ [ 0 ] unless* + ] change-at ;

: map>assoc ( seq quot exemplar -- assoc )
    >r swap [ swap call 2array ] map-with r>
    assoc-like ; inline

: value-at ( value assoc -- key/f )
    [ nip = ] assoc-find-with 2drop ;

! Alist instance (on object so it works on all sequences)
! This is probably only useful on vectors, arrays and f
! and maybe some virtual sequences

UNION: alist POSTPONE: f vector array ;

: assoc ( key value -- {key,value} i )
    [ first = ] find-with swap ;
    
M: alist at*
    assoc [ dup second swap >boolean ] [ f ] if ;

M: alist set-at
    2dup assoc
    [ 2nip 1 swap set-nth ]
    [ drop >r swap 2array r> push ] if ;

M: alist new-assoc drop <vector> ;

M: alist assoc-find
    swap [ first2 rot call ] find-with
    swap [ first2 t ] [ drop f f f ] if ;

M: alist clear-assoc
    delete-all ;

M: alist delete-at
    tuck assoc nip
    [ swap delete-nth ] [ drop ] if* ;

M: alist assoc-size length ;

M: f assoc-like drop dup assoc-empty? [ drop f ] when ;

: (>alist) ( assoc exemplar -- alist )
    ! V{ } assoc-clone-like would be O(n^2)
    [ 2array ] swap assoc>map ;

: >alist ( assoc -- alist ) { } (>alist) ;
: >valist ( assoc -- alist ) V{ } (>alist) ;

M: alist assoc-like
    over sequence? [ like ] [ (>alist) ] if ;
