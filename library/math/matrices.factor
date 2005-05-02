! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: matrices
USING: errors generic kernel lists math namespaces prettyprint
sequences stdio test vectors ;

! The major dimension is the number of elements per row.
TUPLE: matrix rows cols sequence ;

! Vector and matrix protocol.
GENERIC: v+
GENERIC: v-
GENERIC: v* ( element-wise multiplication )
GENERIC: v. ( interior multiplication )

: v*n ( vec n -- vec ) swap [ * ] seq-map-with ;

! On numbers, these operations do the obvious thing
M: number v+ ( n n -- n ) + ;
M: number v- ( n n -- n ) - ;
M: number v* ( n n -- n ) * ;

M: number v. ( n n -- n )
    over vector? [ v*n ] [ * ] ifte ;

! Vector operations
DEFER: <row-vector>
DEFER: <col-vector>

M: object v+ ( v v -- v ) [ v+ ] seq-2map ;
M: object v- ( v v -- v ) [ v- ] seq-2map ;
M: object v* ( v v -- v ) [ v* ] seq-2map ;

! Later, this will fixed when seq-2each works properly
! M: object v. ( v v -- x ) 0 swap [ * + ] seq-2each ;
: +/ ( seq -- n ) 0 swap [ + ] seq-each ;

GENERIC: vv. ( obj v -- v )
M: number vv. ( v n -- v ) v*n ;
M: matrix vv. ( v m -- v )
    swap <col-vector> v. matrix-sequence ;
M: object vv. v* +/ ;
M: object v. ( v v -- x ) swap vv. ;

! Matrices
M: matrix clone ( matrix -- matrix )
    clone-tuple
    dup matrix-sequence clone over set-matrix-sequence ;

: matrix@ ( row col matrix -- n ) matrix-rows * + ;

: matrix-get ( row col matrix -- elt )
    [ matrix@ ] keep matrix-sequence nth ;

: matrix-set ( elt row col matrix -- )
    [ matrix@ ] keep matrix-sequence set-nth ;

: <zero-matrix> ( rows cols -- matrix )
    2dup * zero-vector <matrix> ;

: <row-vector> ( vector -- matrix )
    #! Turn a vector into a matrix of one row.
    [ 1 swap length ] keep <matrix> ;

: <col-vector> ( vector -- matrix )
    #! Turn a vector into a matrix of one column.
    [ length 1 ] keep <matrix> ;

: 2repeat ( i j quot -- | quot: i j -- i j )
    rot [
        rot [ [ rot dup slip -rot ] repeat ] keep -rot
    ] repeat 2drop ; inline

SYMBOL: matrix-maker

: make-matrix ( rows cols quot -- matrix )
    [
        matrix-maker set
        2dup <zero-matrix> matrix set
        [
            [
                [
                    swap matrix-maker get call
                ] 2keep matrix get matrix-set
            ] 2keep
        ] 2repeat
        matrix get
    ] with-scope ;

: <identity-matrix> ( n -- matrix )
    #! Make a nxn identity matrix.
    dup [ = 1 0 ? ] make-matrix ;

: transpose ( matrix -- matrix )
    dup matrix-cols over matrix-rows [
        pick matrix-get
    ] make-matrix nip ;

! Sequence of elements in a row of a matrix.
TUPLE: row index matrix ;
: >row< dup row-index swap row-matrix ;
M: row length row-matrix matrix-cols ;
M: row nth ( n row -- ) >row< swapd matrix-get ;
M: row thaw >vector ;

! A sequence of rows.
TUPLE: row-seq matrix ;
M: row-seq length row-seq-matrix matrix-rows ;
M: row-seq nth row-seq-matrix <row> ;

! Sequence of elements in a column of a matrix.
TUPLE: col index matrix ;
: >col< dup col-index swap col-matrix ;
M: col length col-matrix matrix-rows ;
M: col nth ( n column -- ) >col< swapd matrix-get ;
M: col thaw >vector ;

! A sequence of columns.
TUPLE: col-seq matrix ;
M: col-seq length col-seq-matrix matrix-cols ;
M: col-seq nth col-seq-matrix <col> ;

: +check ( matrix matrix -- matrix matrix )
    #! Check if the two matrices have dimensions compatible
    #! for being added or subtracted.
    over matrix-rows over matrix-rows = >r
    over matrix-cols over matrix-cols = r> and [
        "Matrix dimensions do not match" throw
    ] unless ;

: +dimensions ( matrix -- rows cols )
    dup matrix-rows swap matrix-cols ;

: matrix+/-
    +check
    >r dup +dimensions rot r>
    swap matrix-sequence swap matrix-sequence ;

M: matrix v+ ( m m -- m ) matrix+/- v+ <matrix> ;
M: matrix v- ( m m -- m ) matrix+/- v- <matrix> ;
M: matrix v* ( m m -- m ) matrix+/- v* <matrix> ;

: *check ( matrix matrix -- matrix matrix )
    over matrix-rows over matrix-cols = >r
    over matrix-cols over matrix-rows = r> and [
        "Matrix dimensions inappropriate for composition" throw
    ] unless ;

: *dimensions ( m m -- rows cols )
    swap matrix-rows swap matrix-cols ;

M: matrix v. ( m1 m2 -- m )
    2dup *dimensions [
        ( m1 m2 row col )
        >r >r 2dup r> rot <row> r> rot <col> v.
    ] make-matrix 2nip ;

! Reading and writing matrices

: M[ f ; parsing

: ]M
    reverse
    [ dup length swap car length ] keep
    concat >vector <matrix> swons ; parsing

: row-list ( matrix -- list )
    #! A list of lists, where each sublist is a row of the
    #! matrix.
    [ <row-seq> [ >list , ] seq-each ] make-list ;

: matrix-rows. ( indent list -- indent )
    uncons >r [ one-line on prettyprint* ] with-scope r>
    [ over ?prettyprint-newline matrix-rows. ] when* ;

M: matrix prettyprint* ( indent obj -- indent )
    \ M[ word. >r <prettyprint r>
    row-list matrix-rows.
    bl \ ]M word. prettyprint> ;
