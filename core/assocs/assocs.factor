! Copyright (C) 2007, 2010 Daniel Ehrenberg, Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
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
GENERIC: keys ( assoc -- keys )
GENERIC: values ( assoc -- values )
GENERIC: unzip ( assoc -- keys values )

M: assoc assoc-like drop ; inline

: key? ( key assoc -- ? ) at* nip ; inline

: ?at ( key assoc -- value/key ? )
    2dup at* [ 2nip t ] [ 2drop f ] if ; inline

: ?of ( assoc key -- value/key ? )
    swap ?at ; inline

: maybe-set-at ( value key assoc -- changed? )
    3dup at* [ = [ 3drop f ] [ set-at t ] if ] [ 2drop set-at t ] if ;

<PRIVATE

: assoc-operator ( assoc quot -- alist quot' )
    [ >alist ] dip [ first2 ] prepose ; inline

: assoc-stack-from ( key i seq -- value/f )
    over 0 < [
        3drop f
    ] [
        3dup nth-unsafe at*
        [ 3nip ] [ drop [ 1 - ] dip assoc-stack-from ] if
    ] if ; inline recursive

: search-alist ( key alist -- pair/f i/f )
    [ first = ] with find swap ; inline

: substituter ( assoc -- quot )
    [ ?at drop ] curry ; inline

PRIVATE>

: assoc-find ( ... assoc quot: ( ... key value -- ... ? ) -- ... key value ? )
    assoc-operator find swap [ first2-unsafe t ] [ drop f f f ] if ; inline

: assoc-each ( ... assoc quot: ( ... key value -- ... ) -- ... )
    assoc-operator each ; inline

: assoc>map ( ... assoc quot: ( ... key value -- ... elt ) exemplar -- ... seq )
    [ assoc-operator ] dip map-as ; inline

: assoc-map-as ( ... assoc quot: ( ... key value -- ... newkey newvalue ) exemplar -- ... newassoc )
    [ [ 2array ] compose { } assoc>map ] dip assoc-like ; inline

: assoc-map ( ... assoc quot: ( ... key value -- ... newkey newvalue ) -- ... newassoc )
    over assoc-map-as ; inline

: assoc-filter-as ( ... assoc quot: ( ... key value -- ... ? ) exemplar -- ... subassoc )
    [ assoc-operator filter ] dip assoc-like ; inline

: assoc-filter ( ... assoc quot: ( ... key value -- ... ? ) -- ... subassoc )
    over assoc-filter-as ; inline

: assoc-reject-as ( ... assoc quot: ( ... key value -- ... ? ) exemplar -- ... subassoc )
    [ [ not ] compose ] [ assoc-filter-as ] bi* ; inline

: assoc-reject ( ... assoc quot: ( ... key value -- ... ? ) -- ... subassoc )
    over assoc-reject-as ; inline

: assoc-filter! ( ... assoc quot: ( ... key value -- ... ? ) -- ... assoc )
    [
        over [ [ [ drop ] 2bi ] dip [ delete-at ] 2curry unless ] 2curry
        assoc-each
    ] [ drop ] 2bi ; inline

: assoc-reject! ( ... assoc quot: ( ... key value -- ... ? ) -- ... assoc )
    [ not ] compose assoc-filter! ; inline

: sift-keys ( assoc -- assoc' )
    [ drop ] assoc-filter ; inline

: sift-values ( assoc -- assoc' )
    [ nip ] assoc-filter ; inline

: harvest-keys ( assoc -- assoc' )
    [ drop empty? ] assoc-reject ; inline

: harvest-values ( assoc -- assoc' )
    [ nip empty? ] assoc-reject ; inline

: assoc-partition ( ... assoc quot: ( ... key value -- ... ? ) -- ... true-assoc false-assoc )
    [ assoc-operator partition ] [ drop ] 2bi
    [ assoc-like ] curry bi@ ; inline

: assoc-any? ( ... assoc quot: ( ... key value -- ... ? ) -- ... ? )
    assoc-find 2nip ; inline

: assoc-all? ( ... assoc quot: ( ... key value -- ... ? ) -- ... ? )
    [ not ] compose assoc-any? not ; inline

: at ( key assoc -- value/f )
    at* drop ; inline

: of ( assoc key -- value/f )
    swap at ; inline

M: assoc keys [ drop ] { } assoc>map ;

M: assoc values [ nip ] { } assoc>map ;

: delete-at* ( key assoc -- value/f ? )
    [ at* ] [ delete-at ] 2bi ;

: ?delete-at ( key assoc -- value/key ? )
    [ ?at ] [ delete-at ] 2bi ;

: rename-at ( newkey key assoc -- )
    [ delete-at* ] keep '[ swap _ set-at ] [ 2drop ] if ;

: assoc-empty? ( assoc -- ? )
    assoc-size 0 = ; inline

: assoc-stack ( key seq -- value )
    index-of-last assoc-stack-from ; flushable

: assoc-subset? ( assoc1 assoc2 -- ? )
    '[ swap _ at* [ = ] [ 2drop f ] if ] assoc-all? ;

: assoc= ( assoc1 assoc2 -- ? )
    2dup [ assoc-size ] bi@ = [ assoc-subset? ] [ 2drop f ] if ;

: assoc-hashcode ( n assoc -- code )
    >alist hashcode* ;

: assoc-intersect ( assoc1 assoc2 -- intersection )
    swap [ nip key? ] curry assoc-filter ;

: assoc-union! ( assoc1 assoc2 -- assoc1 )
    over '[ swap _ set-at ] assoc-each ; inline

: assoc-union-as ( assoc1 assoc2 exemplar -- union )
    [ [ [ assoc-size ] bi@ + ] dip new-assoc ] 2keepd
    [ assoc-union! ] bi@ ;

: assoc-union ( assoc1 assoc2 -- union )
    over assoc-union-as ;

: assoc-union-all ( seq -- union )
    H{ } clone [ assoc-union! ] reduce ;

M: assoc assoc-clone-like
    over [ assoc-size ] [ new-assoc ] [ assoc-union! ] tri* ; inline

: assoc-intersect-all ( seq -- assoc )
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
    [ 2array ] 2dip [ first2-unsafe ] prepose cache ; inline

: change-at ( ..a key assoc quot: ( ..a value -- ..b newvalue ) -- ..b )
    [ [ at ] dip call ] [ drop ] 3bi set-at ; inline

: ?change-at ( ..a key assoc quot: ( ..a value -- ..b newvalue ) -- ..b )
    2over [ set-at ] 2curry compose [ at* ] dip [ drop ] if ; inline

: at+ ( n key assoc -- ) [ 0 or + ] change-at ; inline

: inc-at ( key assoc -- ) [ 1 ] 2dip at+ ; inline

: map>assoc ( ... seq quot: ( ... elt -- ... key value ) exemplar -- ... assoc )
    dup sequence? [
        [ [ 2array ] compose ] dip map-as
    ] [
        [ over assoc-size ] dip new-assoc
        [ [ swapd set-at ] curry compose each ] keep
    ] if ; inline

: map>alist ( ... seq quot: ( ... elt -- ... key value ) -- ... alist )
    { } map>assoc ; inline

: extract-keys ( seq assoc -- subassoc )
    [ [ dupd at ] curry ] keep map>assoc ;

M: assoc value-at* swap [ = nip ] curry assoc-find nip ;

: value-at ( value assoc -- key/f ) value-at* drop ;

: ?value-at ( value assoc -- key/value ? )
    2dup value-at* [ 2nip t ] [ 2drop f ] if ; inline

: value? ( value assoc -- ? ) value-at* nip ;

: push-at ( value key assoc -- )
    [ ?push ] change-at ;

: zip-as ( keys values exemplar -- assoc )
    dup sequence? [
        [ 2array ] swap 2map-as
    ] [
        [ 2dup min-length ] dip new-assoc
        [ '[ swap _ set-at ] 2each ] keep
    ] if ; inline

: zip ( keys values -- alist )
    { } zip-as ; inline

: zip-index-as ( values exemplar -- assoc )
    [ dup length <iota> ] dip zip-as ; inline

: zip-index ( values -- alist )
    { } zip-index-as ; inline

M: assoc unzip
    dup assoc-empty? [ drop { } { } ] [ >alist flip first2 ] if ;

: zip-with-as ( ... seq quot: ( ... key -- ... value ) exemplar -- ... assoc )
    [ [ guard ] curry ] dip map>assoc ; inline

: zip-with ( ... seq quot: ( ... key -- ... value ) -- ... alist )
    { } zip-with-as ; inline

: collect-by! ( ... assoc seq quot: ( ... obj -- ... key ) -- ... assoc )
    [ guard ] curry rot [
        [ push-at ] curry compose each
    ] keep ; inline

: collect-by ( ... seq quot: ( ... obj -- ... key ) -- ... assoc )
    [ H{ } clone ] 2dip collect-by! ; inline

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

TUPLE: enumerated { seq read-only } ;

C: <enumerated> enumerated

M: enumerated at*
    seq>> 2dup bounds-check?
    [ nth-unsafe t ] [ 2drop f f ] if ; inline

M: enumerated set-at seq>> set-nth ; inline

M: enumerated delete-at seq>> remove-nth! drop ; inline

M: enumerated >alist ; inline

M: enumerated keys seq>> length <iota> >array ; inline

M: enumerated values seq>> >array ; inline

M: enumerated unzip seq>> [ length <iota> ] keep [ >array ] bi@ ;

M: enumerated assoc-size seq>> length ; inline

M: enumerated clear-assoc seq>> delete-all ; inline

INSTANCE: enumerated assoc

M: enumerated length seq>> length ; inline

M: enumerated nth-unsafe dupd seq>> nth-unsafe 2array ; inline

INSTANCE: enumerated immutable-sequence

: any-key? ( ... assoc quot: ( ... key -- ... ? ) -- ... ? )
    [ drop ] prepose assoc-find 2nip ; inline

: any-value? ( ... assoc quot: ( ... value -- ... ? ) -- ... ? )
    [ nip ] prepose assoc-find 2nip ; inline

: all-keys? ( ... assoc quot: ( ... key -- ... ? ) -- ... ? )
    [ not ] compose any-key? not ; inline

: all-values? ( ... assoc quot: ( ... value -- ... ? ) -- ... ? )
    [ not ] compose any-value? not ; inline

: assoc-reduce ( ... assoc identity quot: ( ... prev key value -- next ) -- ... result )
    [ >alist ] 2dip [ first2 ] prepose reduce ; inline

: reduce-keys ( ... assoc identity quot: ( ... prev elt -- ... next ) -- ... result )
    [ drop ] prepose assoc-reduce ; inline

: reduce-values ( ... assoc identity quot: ( ... prev elt -- ... next ) -- ... result )
    [ nip ] prepose assoc-reduce ; inline

: sum-keys ( assoc -- n ) 0 [ + ] reduce-keys ; inline

: sum-values ( assoc -- n ) 0 [ + ] reduce-values ; inline

: map-keys ( assoc quot: ( key -- key' ) -- assoc )
    '[ _ dip ] assoc-map ; inline

: map-values ( assoc quot: ( value -- value' ) -- assoc )
    '[ swap _ dip swap ] assoc-map ; inline

: filter-keys ( assoc quot: ( key -- ? ) -- assoc' )
    '[ drop @ ] assoc-filter ; inline

: filter-values ( assoc quot: ( value -- ? ) -- assoc' )
    '[ nip @ ] assoc-filter ; inline

: reject-keys ( assoc quot: ( key -- ? ) -- assoc' )
    '[ drop @ ] assoc-reject ; inline

: reject-values ( assoc quot: ( value -- ? ) -- assoc' )
    '[ nip @ ] assoc-reject ; inline
