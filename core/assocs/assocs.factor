! Copyright (C) 2007, 2010 Daniel Ehrenberg, Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math sequences sequences.private
vectors ;
IN: assocs

MIXIN: assoc

GENERIC: at* ( key assoc -- value/f ? )
GENERIC: value-at* ( value assoc -- key/f ? )
GENERIC: set-at ( value key assoc -- )
GENERIC: new-assoc ( capacity exemplar -- newassoc )
GENERIC: delete-at ( key assoc -- )
GENERIC: clear-assoc ( assoc -- )
GENERIC: assoc-size ( assoc -- n )
GENERIC: assoc-like ( assoc exemplar -- newassoc )
GENERIC: assoc-clone-like ( assoc exemplar -- newassoc )
GENERIC: >alist ( assoc -- newassoc )

M: assoc assoc-like drop ; inline

: ?at ( key assoc -- value/key ? )
    2dup at* [ 2nip t ] [ 2drop f ] if ; inline

: maybe-set-at ( value key assoc -- changed? )
    3dup at* [ = [ 3drop f ] [ set-at t ] if ] [ 2drop set-at t ] if ;

<PRIVATE

: (assoc-each) ( assoc quot -- seq quot' )
    [ >alist ] dip [ first2 ] prepose ; inline

: (assoc-stack) ( key i seq -- value )
    over 0 < [
        3drop f
    ] [
        3dup nth-unsafe at*
        [ [ 3drop ] dip ] [ drop [ 1 - ] dip (assoc-stack) ] if
    ] if ; inline recursive

: search-alist ( key alist -- pair/f i/f )
    [ first = ] with find swap ; inline

: substituter ( assoc -- quot )
    [ ?at drop ] curry ; inline

: with-assoc ( assoc quot: ( ..a value key assoc -- ..b ) -- quot: ( ..a key value -- ..b ) )
    curry [ swap ] prepose ; inline

PRIVATE>

: assoc-find ( ... assoc quot: ( ... key value -- ... ? ) -- ... key value ? )
    (assoc-each) find swap [ first2 t ] [ drop f f f ] if ; inline

: key? ( key assoc -- ? ) at* nip ; inline

: assoc-each ( ... assoc quot: ( ... key value -- ... ) -- ... )
    (assoc-each) each ; inline

: assoc>map ( ... assoc quot: ( ... key value -- ... elt ) exemplar -- ... seq )
    [ >alist ] 2dip [ [ first2 ] prepose ] dip map-as ; inline

: assoc-map-as ( ... assoc quot: ( ... key value -- ... newkey newvalue ) exemplar -- ... newassoc )
    [ [ 2array ] compose { } assoc>map ] dip assoc-like ; inline

: assoc-map ( ... assoc quot: ( ... key value -- ... newkey newvalue ) -- ... newassoc )
    over assoc-map-as ; inline

: assoc-filter-as ( ... assoc quot: ( ... key value -- ... ? ) exemplar -- ... subassoc )
    [ (assoc-each) filter ] dip assoc-like ; inline

: assoc-filter ( ... assoc quot: ( ... key value -- ... ? ) -- ... subassoc )
    over assoc-filter-as ; inline

: assoc-filter! ( ... assoc quot: ( ... key value -- ... ? ) -- ... assoc )
    [
        over [ [ [ drop ] 2bi ] dip [ delete-at ] 2curry unless ] 2curry
        assoc-each
    ] [ drop ] 2bi ; inline

: assoc-partition ( ... assoc quot: ( ... key value -- ... ? ) -- ... true-assoc false-assoc )
    [ (assoc-each) partition ] [ drop ] 2bi
    [ assoc-like ] curry bi@ ; inline

: assoc-any? ( ... assoc quot: ( ... key value -- ... ? ) -- ... ? )
    assoc-find 2nip ; inline

: assoc-all? ( ... assoc quot: ( ... key value -- ... ? ) -- ... ? )
    [ not ] compose assoc-any? not ; inline

: at ( key assoc -- value/f )
    at* drop ; inline

M: assoc assoc-clone-like ( assoc exemplar -- newassoc )
    [ dup assoc-size ] dip new-assoc
    [ [ set-at ] with-assoc assoc-each ] keep ; inline

: keys ( assoc -- keys )
    [ drop ] { } assoc>map ;

: values ( assoc -- values )
    [ nip ] { } assoc>map ;

: delete-at* ( key assoc -- old ? )
    [ at* ] 2keep delete-at ;

: rename-at ( newkey key assoc -- )
    [ delete-at* ] keep [ set-at ] with-assoc [ 2drop ] if ;

: assoc-empty? ( assoc -- ? )
    assoc-size 0 = ;

: assoc-stack ( key seq -- value )
    [ length 1 - ] keep (assoc-stack) ; flushable

: assoc-subset? ( assoc1 assoc2 -- ? )
    [ at* [ = ] [ 2drop f ] if ] with-assoc assoc-all? ;

: assoc= ( assoc1 assoc2 -- ? )
    2dup [ assoc-size ] bi@ eq? [ assoc-subset? ] [ 2drop f ] if ;

: assoc-hashcode ( n assoc -- code )
    >alist hashcode* ;

: assoc-intersect ( assoc1 assoc2 -- intersection )
    swap [ nip key? ] curry assoc-filter ;

: assoc-union! ( assoc1 assoc2 -- assoc1 )
    over [ set-at ] with-assoc assoc-each ;

: assoc-union ( assoc1 assoc2 -- union )
    [ [ [ assoc-size ] bi@ + ] [ drop ] 2bi new-assoc ] 2keep
    [ assoc-union! ] bi@ ;

: assoc-combine ( seq -- union )
    H{ } clone [ assoc-union! ] reduce ;

: assoc-refine ( seq -- assoc )
    [ f ] [ [ ] [ assoc-intersect ] map-reduce ] if-empty ;

: assoc-differ ( key -- quot )
    [ nip key? not ] curry ; inline

: assoc-diff ( assoc1 assoc2 -- diff )
    assoc-differ assoc-filter ;

: assoc-diff! ( assoc1 assoc2 -- assoc1 )
    assoc-differ assoc-filter! ;

: substitute ( seq assoc -- newseq )
    substituter map ;

: cache ( ... key assoc quot: ( ... key -- ... value ) -- ... value )
    [ [ at* ] 2keep ] dip
    [ [ nip call dup ] [ drop ] 3bi set-at ] 3curry
    [ drop ] prepose
    unless ; inline

: 2cache ( ... key1 key2 assoc quot: ( ... key1 key2 -- ... value ) -- ... value )
    [ 2array ] 2dip [ first2 ] prepose cache ; inline

: change-at ( ..a key assoc quot: ( ..a value -- ..b newvalue ) -- ..b )
    [ [ at ] dip call ] [ drop ] 3bi set-at ; inline

: at+ ( n key assoc -- ) [ 0 or + ] change-at ; inline

: inc-at ( key assoc -- ) [ 1 ] 2dip at+ ; inline

: map>assoc ( ... seq quot: ( ... elt -- ... key value ) exemplar -- ... assoc )
    dup sequence? [
        [ [ 2array ] compose ] dip map-as
    ] [
        [ over assoc-size ] dip new-assoc
        [ [ swapd set-at ] curry compose each ] keep
    ] if ; inline

: extract-keys ( seq assoc -- subassoc )
    [ [ dupd at ] curry ] keep map>assoc ;

M: assoc value-at* swap [ = nip ] curry assoc-find nip ;

: value-at ( value assoc -- key/f ) value-at* drop ;

: value? ( value assoc -- ? ) value-at* nip ;

: push-at ( value key assoc -- )
    [ ?push ] change-at ;

: zip ( keys values -- alist )
    [ 2array ] { } 2map-as ; inline

: unzip ( assoc -- keys values )
    dup assoc-empty? [ drop { } { } ] [ >alist flip first2 ] if ;

M: sequence at*
    search-alist [ second t ] [ f ] if ;

M: sequence set-at
    2dup search-alist
    [ 2nip set-second ]
    [ drop [ swap 2array ] dip push ] if ;

M: sequence new-assoc drop <vector> ; inline

M: sequence clear-assoc delete-all ; inline

M: sequence delete-at
    [ nip ] [ search-alist nip ] 2bi
    [ swap remove-nth! drop ] [ drop ] if* ;

M: sequence assoc-size length ; inline

M: sequence assoc-clone-like
    [ >alist ] dip clone-like ; inline

M: sequence assoc-like
    [ >alist ] dip like ; inline

M: sequence >alist ; inline

! Override sequence => assoc instance for f
M: f at* 2drop f f ; inline

M: f assoc-size drop 0 ; inline

M: f clear-assoc drop ; inline

M: f assoc-like drop dup assoc-empty? [ drop f ] when ; inline

INSTANCE: sequence assoc

TUPLE: enum { seq read-only } ;

C: <enum> enum

M: enum at*
    seq>> 2dup bounds-check?
    [ nth t ] [ 2drop f f ] if ; inline

M: enum set-at seq>> set-nth ; inline

M: enum delete-at seq>> remove-nth! drop ; inline

M: enum >alist ( enum -- alist )
    seq>> [ length iota ] keep zip ; inline

M: enum assoc-size seq>> length ; inline

M: enum clear-assoc seq>> delete-all ; inline

INSTANCE: enum assoc
