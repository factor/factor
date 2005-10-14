! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences-internals
USING: arrays generic kernel kernel-internals math vectors ;

: (map) ( quot seq i -- quot seq value )
    pick pick >r >r swap nth-unsafe swap call r> r> rot ; inline

: (2each) ( quot seq seq i -- quot seq seq i )
    [ 2nth-unsafe rot dup slip ] 3keep ; inline

: (2map) ( quot seq seq i -- quot seq seq value )
    pick pick >r >r 2nth-unsafe rot dup slip
    swap r> swap r> swap ; inline

: (monotonic) ( quot seq i -- ? )
    2dup 1+ swap nth-unsafe >r swap nth-unsafe r> rot call ;
    inline

IN: sequences

G: each ( seq quot -- | quot: elt -- )
    [ over ] standard-combination ; inline

M: object each ( seq quot -- )
    swap dup length [
        [ swap nth-unsafe swap call ] 3keep
    ] repeat 2drop ;

: each-with ( obj seq quot -- | quot: obj elt -- )
    swap [ with ] each 2drop ; inline

: reduce ( seq identity quot -- value | quot: x y -- z )
    swapd each ; inline

G: find ( seq quot -- i elt | quot: elt -- ? )
    [ over ] standard-combination ; inline

: find-with ( obj seq quot -- i elt | quot: elt -- ? )
    swap [ with rot ] find 2swap 2drop ; inline

: collect ( n generator -- vector | quot: n -- value )
    #! Primitive mapping out of an integer sequence into an
    #! array. Used by map and 2map. Don't call, use map
    #! instead.
    >r [ <array> ] keep r> swap [
        [ rot >r [ swap call ] keep r> set-array-nth ] 3keep
    ] repeat drop ; inline

G: map [ over ] standard-combination ; inline

M: object map ( seq quot -- seq )
    swap [ dup length [ (map) ] collect ] keep like 2nip ;

: map-with ( obj list quot -- list | quot: obj elt -- elt )
    swap [ with rot ] map 2nip ; inline

: accumulate ( list identity quot -- values | quot: x y -- z )
    rot [ pick >r swap call r> ] map-with nip ; inline

: inject ( seq quot -- | quot: elt -- elt )
    over length
    [ [ swap change-nth-unsafe ] 3keep ] repeat 2drop ;
    inline

: inject-with ( obj seq quot -- | quot: obj elt -- elt )
    swap [ with rot ] inject 2drop ; inline

: min-length ( seq seq -- n )
    [ length ] 2apply min ; flushable

: 2each ( seq seq quot -- )
    #! Don't use with lists.
    -rot 2dup min-length [ (2each) ] repeat 3drop ; inline

: 2reduce ( seq seq identity quot -- value | quot: e x y -- z )
    #! Don't use with lists.
    >r -rot r> 2each ; inline

: 2map ( seq seq quot -- seq )
    #! Don't use with lists.
    -rot
    [ 2dup min-length [ (2map) ] collect ] keep like
    >r 3drop r> ; inline

: if-bounds ( i seq quot -- )
    >r pick pick bounds-check? r> [ 3drop -1 f ] if ; inline

: find* ( i seq quot -- i elt )
    [
        3dup >r >r >r >r nth-unsafe r> call [
            r> dup r> nth-unsafe r> drop
        ] [
            r> 1+ r> r> find*
        ] if
    ] if-bounds ; inline

: find-with* ( obj i seq quot -- i elt | quot: elt -- ? )
    -rot [ with rot ] find* 2swap 2drop ; inline

M: object find ( seq quot -- i elt )
    0 -rot find* ;

: find-last* ( i seq quot -- i elt )
    [
        3dup >r >r >r >r nth-unsafe r> call [
            r> dup r> nth-unsafe r> drop
        ] [
            r> 1- r> r> find-last*
        ] if
    ] if-bounds ; inline

: find-last-with* ( obj i seq quot -- i elt | quot: elt -- ? )
    -rot [ with rot ] find-last* 2swap 2drop ; inline

: find-last ( seq quot -- i elt )
    >r [ length 1- ] keep r> find-last* ; inline

: contains? ( seq quot -- ? )
    find drop -1 > ; inline

: contains-with? ( obj seq quot -- ? )
    find-with drop -1 > ; inline

: all? ( seq quot -- ? )
    #! ForAll(P in X) <==> !Exists(!P in X)
    swap [ swap call not ] contains-with? not ; inline

: all-with? ( obj seq quot -- ? | quot: elt -- ? )
    swap [ with rot ] all? 2nip ; inline

: subset ( seq quot -- seq | quot: elt -- ? )
    #! all elements for which the quotation returned a value
    #! other than f are collected in a new list.
    swap [
        dup length <vector> -rot [
            rot >r 2dup >r >r swap call [
                r> r> r> [ push ] keep swap
            ] [
                r> r> drop r> swap
            ] if
        ] each drop
    ] keep like ; inline

: subset-with ( obj seq quot -- seq | quot: obj elt -- ? )
    swap [ with rot ] subset 2nip ; inline

: monotonic? ( seq quot -- ? | quot: elt elt -- ? )
    #! Eg, { 1 2 3 4 } [ < ] monotonic? ==> t
    #!     { 1 3 2 4 } [ < ] monotonic? ==> f
    #! Don't use with lists.
    swap dup length 1- [
        pick pick >r >r (monotonic) r> r> rot
    ] all? 2nip ; inline

: cache-nth ( i seq quot -- elt | quot: i -- elt )
    pick pick ?nth dup [
        >r 3drop r>
    ] [
        drop swap >r over >r call dup r> r> set-nth
    ] if ; inline
