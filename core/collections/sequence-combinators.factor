! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: sequences-internals
USING: arrays generic kernel kernel-internals math sequences ;

: (collect) ( n quot accum -- )
    >r over slip r> set-nth-unsafe ; inline

: collect ( exemplar n quot -- array )
    -rot tuck >r new r>
    [ [ -rot (collect) ] 3keep ] repeat nip ;
    inline

: (each) ( seq quot i -- seq quot i )
    [ rot nth-unsafe swap call ] 3keep ; inline

: (2each) ( quot seq seq i -- quot seq seq i )
    [ 2nth-unsafe rot dup slip ] 3keep ; inline

: (monotonic) ( quot seq i -- ? )
    2dup 1+ swap nth-unsafe >r swap nth-unsafe r> rot call ;
    inline

: find-step [ >r nth-unsafe r> call ] 3keep roll ; inline

: find-fails [ 3drop f f ] if ; inline

: if-bounds+ >r pick pick length < r> find-fails ; inline

: if-bounds- >r pick 0 >= r> find-fails ; inline

: (find) ( n seq quot -- i elt )
    [
        find-step [
            drop dupd nth-unsafe
        ] [
            rot 1+ -rot (find)
        ] if
    ] if-bounds+ ; inline

: (find-last) ( n seq quot -- i elt )
    [
        find-step [
            drop dupd nth-unsafe
        ] [
            rot 1- -rot (find-last)
        ] if
    ] if-bounds- ; inline

: (all?) ( n seq quot -- ? )
    pick pick length < [
        find-step [ rot 1+ -rot (all?) ] [ 3drop f ] if
    ] [ 3drop t ] if ; inline

: change-nth-unsafe ( i seq quot -- )
    [ >r nth-unsafe r> call ] 3keep drop set-nth-unsafe ; inline

IN: sequences

: each ( seq quot -- )
    over length [ (each) ] repeat 2drop ; inline

: each-with ( obj seq quot -- )
    swap [ with ] each 2drop ; inline

: reduce ( seq identity quot -- result )
    swapd each ; inline

: map ( seq quot -- newseq )
    over dup length [ (each) drop rot ] collect 2nip ; inline

: map-with ( obj list quot -- newseq )
    swap [ with rot ] map 2nip ; inline

: accumulate ( seq identity quot -- final newseq )
    rot [ pick >r swap call r> ] map-with ; inline

: change-nth ( i seq quot -- )
    [ >r nth r> call ] 3keep drop set-nth ; inline

: change-each ( seq quot -- )
    over length
    [ [ -rot change-nth-unsafe ] 3keep ] repeat 2drop ;
    inline

: min-length ( seq1 seq2 -- n ) [ length ] 2apply min ; inline

: max-length ( seq1 seq2 -- n ) [ length ] 2apply max ; inline

: 2each ( seq1 seq2 quot -- )
    -rot 2dup min-length [ (2each) ] repeat 3drop ; inline

: 2reverse-each ( seq1 seq2 quot -- )
    >r [ <reversed> ] 2apply r> 2each ; inline

: 2reduce ( seq seq identity quot -- result )
    >r -rot r> 2each ; inline

: 2map ( seq1 seq2 quot -- newseq )
    -rot 2dup dupd min-length
    [ (2each) drop roll ] collect
    >r 3drop r> ; inline

: find* ( n seq quot -- i elt )
    [ (find) ] if-bounds- ; inline

: find-with* ( obj n seq quot -- i elt )
    -rot [ with rot ] find* 2swap 2drop ; inline

: find ( seq quot -- i elt )
    0 -rot (find) ; inline

: find-with ( obj seq quot -- i elt )
    swap [ with rot ] find 2swap 2drop ; inline

: find-last* ( n seq quot -- i elt )
    [ (find-last) ] if-bounds+ ; inline

: find-last-with* ( obj n seq quot -- i elt )
    -rot [ with rot ] find-last* 2swap 2drop ; inline

: find-last ( seq quot -- i elt )
    >r [ length 1- ] keep r> (find-last) ; inline

: find-last-with ( obj seq quot -- i elt )
    swap [ with rot ] find-last 2swap 2drop ; inline

: index ( obj seq -- n )
    [ = ] find-with drop ;

: index* ( obj i seq -- n )
    [ = ] find-with* drop ;

: last-index ( obj seq -- n )
    [ = ] find-last-with drop ;

: last-index* ( obj i seq -- n )
    [ = ] find-last-with* drop ;

: contains? ( seq quot -- ? )
    find drop >boolean ; inline

: contains-with? ( obj seq quot -- ? )
    find-with drop >boolean ; inline

: member? ( obj seq -- ? )
    [ = ] contains-with? ;

: memq? ( obj seq -- ? )
    [ eq? ] contains-with? ;

: all? ( seq quot -- ? )
    0 -rot (all?) ; inline

: all-with? ( obj seq quot -- ? )
    swap [ with rot ] all? 2nip ; inline

: push-if ( elt quot accum -- )
    >r keep r> rot [ push ] [ 2drop ] if  ; inline

: subset ( seq quot -- subseq )
    over >r over length pick new-resizable rot
    [ -rot [ push-if ] 2keep ] each
    nip r> like ; inline

: subset-with ( obj seq quot -- subseq )
    swap [ with rot ] subset 2nip ; inline

: remove ( obj seq -- newseq )
    [ = not ] subset-with ;

: monotonic? ( seq quot -- ? )
    swap dup length 1- [
        [ (monotonic) ] 3keep drop rot
    ] all? 2nip ; inline

: (interleave) ( between quot elt first? -- )
    [ rot drop ] [ 2slip ] if swap call ; inline

: interleave ( seq between quot -- )
    rot dup length
    [ 2swap [ 2swap zero? (interleave) ] 2keep ] 2each
    2drop ; inline

: cache-nth ( i seq quot -- elt )
    pick pick ?nth dup [
        >r 3drop r>
    ] [
        drop swap >r over >r call dup r> r> set-nth
    ] if ; inline

: (mismatch) ( seq1 seq2 n -- i )
    [ >r 2dup r> 2nth-unsafe = not ] find drop 2nip ; inline

: mismatch ( seq1 seq2 -- i )
    2dup min-length (mismatch) ;

: sequence= ( seq1 seq2 -- ? )
    2dup [ length ] 2apply tuck number=
    [ (mismatch) not ] [ 3drop f ] if ; inline
