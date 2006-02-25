! Copyright (C) 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: sequences-internals
USING: arrays generic kernel kernel-internals math sequences
vectors ;

: collect ( n generator -- array | quot: n -- value )
    >r [ f <array> ] keep r> swap [
        [ rot >r [ swap call ] keep r> set-array-nth ] 3keep
    ] repeat drop ; inline

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

: (interleave) ( n -- array )
    dup zero? [
        drop { }
    ] [
        t <array> f 0 pick set-nth-unsafe
    ] if ;

: select ( seq quot quot -- seq )
    pick >r >r V{ } clone rot [
        -rot [
            >r over >r call [ r> r> push ] [ r> r> 2drop ] if
        ] 2keep
    ] r> call r> like nip ; inline

IN: sequences

G: each ( seq quot -- | quot: elt -- )
    1 standard-combination ; inline

M: object each ( seq quot -- )
    swap dup length [
        [ swap nth-unsafe swap call ] 3keep
    ] repeat 2drop ;

: each-with ( obj seq quot -- | quot: obj elt -- )
    swap [ with ] each 2drop ; inline

: reduce ( seq identity quot -- value | quot: x y -- z )
    swapd each ; inline

G: find ( seq quot -- i elt | quot: elt -- ? )
    1 standard-combination ; inline

: find-with ( obj seq quot -- i elt | quot: elt -- ? )
    swap [ with rot ] find 2swap 2drop ; inline

G: map 1 standard-combination ; inline

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

: max-length ( seq seq -- n )
    [ length ] 2apply max ; flushable

: 2each ( seq seq quot -- )
    #! Don't use with lists.
    -rot 2dup min-length [ (2each) ] repeat 3drop ; inline

: 2reduce ( seq seq identity quot -- value | quot: e x y -- z )
    >r -rot r> 2each ; inline

: 2map ( seq seq quot -- seq )
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

: find-last-with ( obj seq quot -- i elt | quot: elt -- ? )
    swap [ with rot ] find-last 2swap 2drop ; inline

: contains? ( seq quot -- ? )
    find drop -1 > ; inline

: contains-with? ( obj seq quot -- ? )
    find-with drop -1 > ; inline

: all? ( seq quot -- ? )
    swap [ swap call not ] contains-with? not ; inline

: all-with? ( obj seq quot -- ? | quot: elt -- ? )
    swap [ with rot ] all? 2nip ; inline

: subset ( seq quot -- seq | quot: elt -- ? )
    [ each ] select ; inline

: subset-with ( obj seq quot -- seq | quot: obj elt -- ? )
    swap [ with rot ] subset 2nip ; inline

: monotonic? ( seq quot -- ? | quot: elt elt -- ? )
    swap dup length 1- [
        pick pick >r >r (monotonic) r> r> rot
    ] all? 2nip ; inline

: interleave ( seq quot between -- )
    rot dup length (interleave) [
        [ -rot [ -rot 2slip call ] 2keep ]
        [ -rot [ drop call ] 2keep ]
        if
    ] 2each 2drop ; inline

: cache-nth ( i seq quot -- elt | quot: i -- elt )
    pick pick ?nth dup [
        >r 3drop r>
    ] [
        drop swap >r over >r call dup r> r> set-nth
    ] if ; inline
