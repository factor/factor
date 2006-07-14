! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: topology
USING: arrays hashtables hashtables io kernel math math
namespaces parser prettyprint sequences words ;

: SYMBOLS:
    string-mode on
    [ string-mode off [ create-in define-symbol ] each ] f ;
    parsing

: canonicalize
    [ nip zero? not ] hash-subset ;

: (l+) ( x -- )
    [ swap +@ ] hash-each ;

: l+ ( x y -- x+y )
    [ (l+) (l+) ] make-hash canonicalize ;

: l* ( vec n -- vec )
    dup zero? [
        2drop H{ }
    ] [
        swap
        hash>alist [ first2 rot * 2array ] map-with alist>hash
    ] if ;

: num-l. ( n -- str )
    {
        { [ dup 1 = ] [ drop " + " ] }
        { [ dup -1 = ] [ drop " - " ] }
        { [ t ] [ number>string " + " swap append ] }
    } cond ;

: (l.) ( assoc -- )
    dup empty? [
        drop 0 .
    ] [
        [
            first2 num-l.
            swap [ unparse ] map "." join
            append
        ] map concat " + " ?head drop print
    ] if ;

: l. ( vec -- ) hash>alist (l.) ;

: linear-op ( vec quot -- vec )
    [
        swap [
            >r swap call r> l* (l+)
        ] hash-each-with
    ] make-hash canonicalize ; inline

: -1^ odd? -1 1 ? ;

: (op-matrix) ( range quot basis-elt -- row )
    swap call swap [ swap hash [ 0 ] unless* ] map-with ; inline

: op-matrix ( domain range quot -- matrix )
    rot [
        ( domain quot basis-elt )
        >r 2dup r> (op-matrix)
    ] map 2nip ; inline

: rot-seq 1 swap cut swap append ;

: (H) ( sim -- ) flip first2 rot-seq v- ;

: -rot-seq 1 swap cut* swap append ;

: (H*) ( sim -- ) flip first2 -rot-seq v- ;

: -rot-seq 1 swap cut* swap append ;
