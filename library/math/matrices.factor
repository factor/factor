! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: matrices
USING: errors generic kernel lists math namespaces sequences
vectors ;

! Vector operations
: n*v ( n vec -- vec ) [ * ] map-with ;
: v*n ( vec n -- vec ) swap n*v ;
: n/v ( n vec -- vec ) [ / ] map-with ;
: v/n ( vec n -- vec ) swap [ swap / ] map-with ;

: v+ ( v v -- v ) [ + ] 2map ;
: v- ( v v -- v ) [ - ] 2map ;
: v* ( v v -- v ) [ * ] 2map ;
: v/ ( v v -- v ) [ / ] 2map ;
: v** ( v v -- v ) [ conjugate * ] 2map ;
: vmax ( v v -- v ) [ max ] 2map ;
: vmin ( v v -- v ) [ min ] 2map ;
: vneg ( v -- v ) [ neg ] map ;

: sum ( v -- n ) 0 [ + ] reduce ;
: product 1 [ * ] reduce ;

: set-axis ( x y axis -- v )
    2dup v* >r >r drop dup r> v* v- r> v+ ;

! Later, this will fixed when 2each works properly
! : v. ( v v -- x ) 0 swap [ conjugate * + ] 2each ;
: v. ( v v -- x ) v** sum ;

: norm-sq ( v -- n ) 0 [ absq + ] reduce ;
: norm ( v -- n ) norm-sq sqrt ;

: proj ( u v -- w )
    #! Orthogonal projection of u onto v.
    [ [ v. ] keep norm-sq v/n ] keep n*v ;

: cross-trace ( v1 v2 i1 i2 -- v1 v2 n )
    pick nth >r pick nth r> * ;

: cross-minor ( v1 v2 i1 i2 -- n )
    [ cross-trace -rot ] 2keep swap cross-trace 2nip - ;

: cross ( { x1 y1 z1 } { x2 y2 z2 } -- { z1 z2 z3 } )
    #! Cross product of two 3-dimensional vectors.
    3 <vector>
    [ >r 2dup 1 2 cross-minor 0 r> set-nth ] keep
    [ >r 2dup 2 0 cross-minor 1 r> set-nth ] keep
    [ >r 2dup 0 1 cross-minor 2 r> set-nth ] keep
    2nip ;

! Matrices
! The major dimension is the number of elements per row.
TUPLE: matrix rows cols sequence ;

: >matrix<
    [ matrix-rows ] keep
    [ matrix-cols ] keep
    matrix-sequence ;

M: matrix clone ( matrix -- matrix )
    clone-tuple
    dup matrix-sequence clone over set-matrix-sequence ;

: matrix@ ( row col matrix -- n ) matrix-cols rot * + ;

: matrix-get ( row col matrix -- elt )
    [ matrix@ ] keep matrix-sequence nth ;

: matrix-set ( elt row col matrix -- )
    [ matrix@ ] keep matrix-sequence set-nth ;

: <zero-matrix> ( rows cols -- matrix )
    2dup * zero-vector <matrix> ;

: <row-matrix> ( vector -- matrix )
    #! Turn a vector into a matrix of one row.
    [ 1 swap length ] keep <matrix> ;

: <col-matrix> ( vector -- matrix )
    #! Turn a vector into a matrix of one column.
    [ length 1 ] keep <matrix> ;

: make-matrix ( rows cols quot -- matrix | quot: i j -- elt )
    -rot [
        [ [ [ rot call , ] 3keep ] 2repeat ] make-vector nip
    ] 2keep rot <matrix> ; inline

: <identity-matrix> ( n -- matrix )
    #! Make a nxn identity matrix.
    dup [ = 1 0 ? ] make-matrix ;

: transpose ( matrix -- matrix )
    dup matrix-cols over matrix-rows [
        swap pick matrix-get
    ] make-matrix nip ;

! Sequence of elements in a row of a matrix.
TUPLE: row index matrix ;
: >row< dup row-index swap row-matrix ;
M: row length row-matrix matrix-cols ;
M: row nth ( n row -- n ) >row< swapd matrix-get ;
M: row thaw >vector ;

! Sequence of elements in a column of a matrix.
TUPLE: col index matrix ;
: >col< dup col-index swap col-matrix ;
M: col length col-matrix matrix-rows ;
M: col nth ( n column -- n ) >col< matrix-get ;
M: col thaw >vector ;

! Sequence of elements on a diagonal. Positive indices are above
! and negative indices are below the main diagonal. Only for
! square matrices.
TUPLE: diagonal index matrix ;
: >diagonal< dup diagonal-index swap diagonal-matrix ;
M: diagonal length ( daig -- n )
    >diagonal< matrix-rows swap abs - ;
M: diagonal nth ( n diag -- n )
    >diagonal< >r [ neg 0 max over + ] keep 0 max rot + r>
    matrix-get ;

: trace ( matrix -- tr )
    #! Product of diagonal elements.
    0 swap <diagonal> product ;

: +check ( matrix matrix -- )
    #! Check if the two matrices have dimensions compatible
    #! for being added or subtracted.
    over matrix-rows over matrix-rows = >r
    swap matrix-cols swap matrix-cols = r> and [
        "Matrix dimensions do not equal" throw
    ] unless ;

: element-wise ( m m -- rows cols v v )
    2dup +check >r >matrix< r> matrix-sequence ;

! Matrix operations
: m+ ( m m -- m ) element-wise v+ <matrix> ;
: m- ( m m -- m ) element-wise v- <matrix> ;

: m* ( m m -- m )
    #! Multiply two matrices element-wise. This is NOT matrix
    #! multiplication in the usual mathematical sense. For that,
    #! see the m. word.
    element-wise v* <matrix> ;

: *check ( matrix matrix -- )
    swap matrix-cols swap matrix-rows = [
        "Matrix dimensions inappropriate for composition" throw
    ] unless ;

: *dimensions ( m m -- rows cols )
    swap matrix-rows swap matrix-cols ;

: m. ( m1 m2 -- m )
    #! Composition of two matrices.
    2dup *check 2dup *dimensions [
        ( m1 m2 row col -- m1 m2 )
        pick <col> >r pick <row> r> v.
    ] make-matrix 2nip ;

: n*m ( n m -- m )
    #! Multiply a matrix by a scalar.
    >matrix< >r rot r> n*v <matrix> ;

: m.v ( m v -- v )
    #! Multiply a matrix by a column vector.
    <col-matrix> m. matrix-sequence ;

: v.m ( v m -- v )
    #! Multiply a row vector by a matrix.
    >r <row-matrix> r> m. matrix-sequence ;

: row-list ( matrix -- list )
    #! A list of lists, where each sublist is a row of the
    #! matrix.
    dup matrix-rows [ swap <row> >list ] project-with ;
