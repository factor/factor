! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: homology
USING: kernel sequences arrays math words namespaces
hashtables prettyprint io ;

! Utilities
: S{ [ [ dup ] map>hash ] [ ] ; parsing

: (lengthen) ( seq n -- seq )
    over length - f <array> append ;

: lengthen ( sim sim -- sim sim )
    2dup max-length tuck (lengthen) >r (lengthen) r> ;

: unswons* 1 over tail swap first ;

: swons* 1array swap append ;

: rot-seq ( seq -- seq ) unswons* add ;

: <point> ( -- sim ) gensym 1array ;

: (C) ( point sim -- sim )
    [ [ append natural-sort ] map-with ] map-with ;

: (\/) ( sim sim -- sim ) lengthen [ append natural-sort ] 2map ;

: <range> ( from to -- seq ) dup <slice> ;

! Simplicial complexes
SYMBOL: basepoint

: {*} ( -- sim )
    #! Initial object in category
    { { { basepoint } } } ;

: \/ ( sim sim -- sim )
    #! Glue two complexes at base point
    (\/) [ prune ] map ;

: +point ( sim -- sim )
    #! Adjoint an isolated point
    unswons* <point> add swons* ;

: C ( sim -- sim )
    #! Cone on a space
    <point> over first over add >r swap (C) r> swons* ;

: S ( sim -- sim )
    #! Suspension
    [
        <point> <point> 2dup 2array >r
        pick (C) >r swap (C) r> (\/) r> swons*
    ] keep (\/) ;

: S^0 ( -- sim )
    #! Degenerate sphere -- two points
    {*} +point ;

: S^ ( n -- sim )
    #! Sphere
    S^0 swap [ S ] times ;

: D^ ( n -- sim )
    #! Disc
    1- S^ C ;

! Mod 2 matrix algebra
: remove-1 ( n seq -- seq )
    >r { } swap dup 1+ r> replace-slice ;

: symmetric-diff ( hash hash -- hash )
    clone swap [
        drop dup pick hash [
            over remove-hash
        ] [
            dup pick set-hash
        ] if
    ] hash-each ;

SYMBOL: row-basis
SYMBOL: matrix
SYMBOL: current-row

: rows ( -- n ) matrix get length ;

: exchange-rows ( m n -- )
    2dup = [ 2drop ] [ matrix get exchange ] if ;

: row ( n -- row ) matrix get nth ;

: set-row ( row n -- ) matrix get set-nth ;

: add-row ( src# dst# -- )
    [ [ row ] 2apply symmetric-diff ] keep set-row ;

: pivot-row ( basis-elt -- n )
    current-row get rows <range>
    [ row hash-member? ] find-with nip ;

: kill-column ( basis-elt pivot -- )
    dup 1+ rows <range> [
        pick over row hash-member? [ dupd add-row ] [ drop ] if
    ] each 2drop ;

: with-matrix ( matrix basis quot -- matrix )
    [
        >r row-basis set matrix set r> call matrix get
    ] with-scope ; inline

: (row-reduce)
    0 current-row set
    row-basis get [
        dup pivot-row dup [
            current-row get exchange-rows
            current-row get kill-column
            current-row inc
        ] [
            2drop
        ] if
    ] each ;

: ker/im ( -- ker im )
    matrix get [ hash-empty? ] subset length
    row-basis get [
        matrix get [ hash-member? ] contains-with?
    ] subset length ;

: row-reduce ( matrix basis -- rowsp colsp matrix )
    [ (row-reduce) ker/im ] with-matrix ;

! Mod 2 homology
: (boundary) ( seq -- chain )
    dup length 1 <= [
        H{ }
    ] [
        dup length [ over remove-1 dup ] map>hash
    ] if nip ;

: boundary ( chain -- chain )
    H{ } swap [ drop (boundary) symmetric-diff ] hash-each ;

: homology ( sim -- seq )
    dup [ [ (boundary) ] map ] map rot-seq
    [ row-reduce drop 2array ] 2map ;

: print-matrix ( matrix basis -- )
    swap [
        swap [
            ( row basis-elt )
            swap hash-member? 1 0 ? pprint bl
        ] each-with terpri
    ] each-with ;

2 S^ [ [ [ (boundary) ] map ] map unswons* drop ] keep
[ [ row-reduce 2nip ] 2map ] keep
[ print-matrix terpri ] 2each
