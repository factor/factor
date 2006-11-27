! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: sequences-internals
USING: arrays generic kernel kernel-internals math sequences
vectors ;

: collect ( n quot -- array )
    >r [ f <array> ] keep r> swap [
        [ rot >r [ swap call ] keep r> set-array-nth ] 3keep
    ] repeat drop ; inline

: (map) ( seq quot i -- quot seq value )
    -rot [ >r nth-unsafe r> call ] 2keep rot ; inline

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

: map>array ( seq quot -- array )
    over length [ (map) ] collect 2nip ; inline

IN: sequences

: each ( seq quot -- )
    swap dup length [
        [ swap nth-unsafe swap call ] 3keep
    ] repeat 2drop ; inline

: each-with ( obj seq quot -- )
    swap [ with ] each 2drop ; inline

: reduce ( seq identity quot -- result )
    swapd each ; inline

: map ( seq quot -- newseq ) over >r map>array r> like ; inline

: map-with ( obj list quot -- newseq )
    swap [ with rot ] map 2nip ; inline

: accumulate ( seq identity quot -- final newseq )
    rot [ pick >r swap call r> ] map-with ; inline

: change-nth ( i seq quot -- )
    -rot [ nth swap call ] 2keep set-nth ; inline

: inject ( seq quot -- )
    over length
    [ [ -rot change-nth ] 3keep ] repeat 2drop ;
    inline

: inject-with ( obj seq quot -- )
    swap [ with rot ] inject 2drop ; inline

: min-length ( seq1 seq2 -- n )
    [ length ] 2apply min ;

: max-length ( seq1 seq2 -- n )
    [ length ] 2apply max ;

: 2each ( seq1 seq2 quot -- )
    -rot 2dup min-length [ (2each) ] repeat 3drop ; inline

: 2reduce ( seq seq identity quot -- result )
    >r -rot r> 2each ; inline

: 2map ( seq1 seq2 quot -- newseq )
    -rot
    [ 2dup min-length [ (2map) ] collect ] keep like
    >r 3drop r> ; inline

: if-bounds ( i seq quot -- )
    >r pick pick bounds-check? r> [ 3drop -1 f ] if ; inline

: find* ( n seq quot -- i elt )
    [
        3dup >r >r >r >r nth-unsafe r> call [
            r> dup r> nth-unsafe r> drop
        ] [
            r> 1+ r> r> find*
        ] if
    ] if-bounds ; inline

: find-with* ( obj n seq quot -- i elt )
    -rot [ with rot ] find* 2swap 2drop ; inline

: find ( seq quot -- i elt )
    0 -rot find* ; inline

: find-with ( obj seq quot -- i elt )
    swap [ with rot ] find 2swap 2drop ; inline

: find-last* ( n seq quot -- i elt )
    [
        3dup >r >r >r >r nth-unsafe r> call [
            r> dup r> nth-unsafe r> drop
        ] [
            r> 1- r> r> find-last*
        ] if
    ] if-bounds ; inline

: find-last-with* ( obj n seq quot -- i elt )
    -rot [ with rot ] find-last* 2swap 2drop ; inline

: find-last ( seq quot -- i elt )
    >r [ length 1- ] keep r> find-last* ; inline

: find-last-with ( obj seq quot -- i elt )
    swap [ with rot ] find-last 2swap 2drop ; inline

: contains? ( seq quot -- ? )
    find drop -1 > ; inline

: contains-with? ( obj seq quot -- ? )
    find-with drop -1 > ; inline

: all? ( seq quot -- ? )
    swap [ swap call not ] contains-with? not ; inline

: all-with? ( obj seq quot -- ? )
    swap [ with rot ] all? 2nip ; inline

: subset* ( flags seq -- subseq )
    [
        dup length <vector>
        [ swap [ over push ] [ drop ] if ] 2reduce
    ] keep like ; inline

: subset ( seq quot -- subseq )
    over >r map>array r> subset* ; inline

: subset-with ( obj seq quot -- subseq )
    swap [ with rot ] subset 2nip ; inline

: monotonic? ( seq quot -- ? )
    swap dup length 1- [
        pick pick >r >r (monotonic) r> r> rot
    ] all? 2nip ; inline

: interleave ( seq quot between -- )
    rot dup length (interleave) [
        [ -rot [ -rot 2slip call ] 2keep ]
        [ -rot [ drop call ] 2keep ]
        if
    ] 2each 2drop ; inline

: cache-nth ( i seq quot -- elt )
    pick pick ?nth dup [
        >r 3drop r>
    ] [
        drop swap >r over >r call dup r> r> set-nth
    ] if ; inline

: copy-into-check ( n dest src -- n dest src )
    pick over length + pick 2dup length >
    [ set-length ] [ 2drop ] if ; inline

: copy-into ( n dest src -- )
    copy-into-check dup length
    [ >r pick r> + pick set-nth-unsafe ] 2each 2drop ;
    inline

: >sequence ( seq pred quot -- newseq )
    pick rot call [
        drop clone
    ] [
        over >r >r length r> call 0 over r> copy-into
    ] if ; inline
