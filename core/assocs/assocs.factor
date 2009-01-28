! Copyright (C) 2007, 2008 Daniel Ehrenberg, Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences arrays math sequences.private vectors
accessors ;
IN: assocs

MIXIN: assoc

GENERIC: at* ( key assoc -- value/f ? )
GENERIC: set-at ( value key assoc -- )
GENERIC: new-assoc ( capacity exemplar -- newassoc )
GENERIC: delete-at ( key assoc -- )
GENERIC: clear-assoc ( assoc -- )
GENERIC: assoc-size ( assoc -- n )
GENERIC: assoc-like ( assoc exemplar -- newassoc )

M: assoc assoc-like drop ;

GENERIC: assoc-clone-like ( assoc exemplar -- newassoc )

GENERIC: >alist ( assoc -- newassoc )

: (assoc-each) ( assoc quot -- seq quot' )
    [ >alist ] dip [ first2 ] prepose ; inline

: assoc-find ( assoc quot -- key value ? )
    (assoc-each) find swap [ first2 t ] [ drop f f f ] if ; inline

: key? ( key assoc -- ? ) at* nip ; inline

: assoc-each ( assoc quot -- )
    (assoc-each) each ; inline

: assoc>map ( assoc quot exemplar -- seq )
    [ accumulator [ assoc-each ] dip ] dip like ; inline

: assoc-map-as ( assoc quot exemplar -- newassoc )
    [ [ 2array ] compose V{ } assoc>map ] dip assoc-like ; inline

: assoc-map ( assoc quot -- newassoc )
    over assoc-map-as ; inline

: assoc-push-if ( key value quot accum -- )
    [ 2keep rot ] dip swap
    [ [ 2array ] dip push ] [ 3drop ] if ; inline

: assoc-pusher ( quot -- quot' accum )
    V{ } clone [ [ assoc-push-if ] 2curry ] keep ; inline

: assoc-filter-as ( assoc quot exemplar -- subassoc )
    [ assoc-pusher [ assoc-each ] dip ] dip assoc-like ; inline

: assoc-filter ( assoc quot -- subassoc )
    over assoc-filter-as ; inline

: assoc-contains? ( assoc quot -- ? )
    assoc-find 2nip ; inline

: assoc-all? ( assoc quot -- ? )
    [ not ] compose assoc-contains? not ; inline

: at ( key assoc -- value/f )
    at* drop ; inline

M: assoc assoc-clone-like ( assoc exemplar -- newassoc )
    over assoc-size swap new-assoc
    swap [ swap pick set-at ] assoc-each ;

: keys ( assoc -- keys )
    [ drop ] { } assoc>map ;

: values ( assoc -- values )
    [ nip ] { } assoc>map ;

: delete-at* ( key assoc -- old ? )
    [ at* ] 2keep delete-at ;

: rename-at ( newkey key assoc -- )
    tuck delete-at* [ -rot set-at ] [ 3drop ] if ;

: assoc-empty? ( assoc -- ? )
    assoc-size zero? ;

: (assoc-stack) ( key i seq -- value )
    over 0 < [
        3drop f
    ] [
        3dup nth-unsafe at*
        [ [ 3drop ] dip ] [ drop [ 1- ] dip (assoc-stack) ] if
    ] if ; inline recursive

: assoc-stack ( key seq -- value )
    dup length 1- swap (assoc-stack) ; flushable

: assoc-subset? ( assoc1 assoc2 -- ? )
    [ swapd at* [ = ] [ 2drop f ] if ] curry assoc-all? ;

: assoc= ( assoc1 assoc2 -- ? )
    [ assoc-subset? ] [ swap assoc-subset? ] 2bi and ;

: assoc-hashcode ( n assoc -- code )
    [
        [ over ] dip hashcode* 2/ [ dupd hashcode* ] dip bitxor
    ] { } assoc>map hashcode* ;

: assoc-intersect ( assoc1 assoc2 -- intersection )
    swap [ nip key? ] curry assoc-filter ;

: update ( assoc1 assoc2 -- )
    swap [ swapd set-at ] curry assoc-each ;

: assoc-union ( assoc1 assoc2 -- union )
    [ [ [ assoc-size ] bi@ + ] [ drop ] 2bi new-assoc ] 2keep
    [ dupd update ] bi@ ;

: assoc-combine ( seq -- union )
    H{ } clone [ dupd update ] reduce ;

: assoc-diff ( assoc1 assoc2 -- diff )
    [ nip key? not ] curry assoc-filter ;

: remove-all ( assoc seq -- subseq )
    swap [ key? not ] curry filter ;

: (substitute)
    [ dupd at* [ nip ] [ drop ] if ] curry ; inline

: substitute-here ( seq assoc -- )
    (substitute) change-each ;

: substitute ( seq assoc -- newseq )
    (substitute) map ;

: cache ( key assoc quot -- value )
    2over at* [
        [ 3drop ] dip
    ] [
        drop pick rot [ call dup ] 2dip set-at
    ] if ; inline

: change-at ( key assoc quot -- )
    [ [ at ] dip call ] 3keep drop set-at ; inline

: at+ ( n key assoc -- ) [ 0 or + ] change-at ; inline

: inc-at ( key assoc -- ) [ 1 ] 2dip at+ ; inline

: map>assoc ( seq quot exemplar -- assoc )
    [ [ 2array ] compose { } map-as ] dip assoc-like ; inline

: extract-keys ( seq assoc -- subassoc )
    [ [ dupd at ] curry ] keep map>assoc ;

GENERIC: value-at* ( value assoc -- key/f ? )

M: assoc value-at* swap [ = nip ] curry assoc-find nip ;

: value-at ( value assoc -- key/f ) value-at* drop ;

: value? ( value assoc -- ? ) value-at* nip ;

: push-at ( value key assoc -- )
    [ ?push ] change-at ;

: zip ( keys values -- alist )
    2array flip ; inline

: unzip ( assoc -- keys values )
    dup assoc-empty? [ drop { } { } ] [ >alist flip first2 ] if ;

: search-alist ( key alist -- pair/f i/f )
    [ first = ] with find swap ; inline

M: sequence at*
    search-alist [ second t ] [ f ] if ;

M: sequence set-at
    2dup search-alist
    [ 2nip set-second ]
    [ drop [ swap 2array ] dip push ] if ;

M: sequence new-assoc drop <vector> ;

M: sequence clear-assoc delete-all ;

M: sequence delete-at
    tuck search-alist nip
    [ swap delete-nth ] [ drop ] if* ;

M: sequence assoc-size length ;

M: sequence assoc-clone-like
    [ >alist ] dip clone-like ;

M: sequence assoc-like
    [ >alist ] dip like ;

M: sequence >alist ;

! Override sequence => assoc instance for f
M: f clear-assoc drop ;

M: f assoc-like drop dup assoc-empty? [ drop f ] when ;

INSTANCE: sequence assoc

TUPLE: enum seq ;

C: <enum> enum

M: enum at*
    seq>> 2dup bounds-check?
    [ nth t ] [ 2drop f f ] if ;

M: enum set-at seq>> set-nth ;

M: enum delete-at seq>> delete-nth ;

M: enum >alist ( enum -- alist )
    seq>> [ length ] keep zip ;

M: enum assoc-size seq>> length ;

M: enum clear-assoc seq>> delete-all ;

INSTANCE: enum assoc
