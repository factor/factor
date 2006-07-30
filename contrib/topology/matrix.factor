! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: matrices
USING: kernel math namespaces parser sequences ;

SYMBOL: matrix

: with-matrix ( matrix quot -- )
    [ swap matrix set call matrix get ] with-scope ; inline

: nth-row ( row# -- seq ) matrix get nth ;

: nth-col ( col# ignore-rows -- seq )
    matrix get swap tail-slice [ nth ] map-with ;

: change-row ( row# quot -- | quot: seq -- seq )
    matrix get -rot change-nth ; inline

: exchange-rows ( row# row# -- ) matrix get exchange ;

: rows ( -- n ) matrix get length ;

: cols ( -- n ) 0 nth-row length ;

: first-col ( row# -- n )
    #! First non-zero column
    0 swap nth-row [ zero? not ] skip ;

: clear-scale ( col# pivot-row i-row -- n )
    >r over r> nth dup zero? [
        3drop 0
    ] [
        >r nth dup zero? [
            r> 2drop 0
        ] [
            r> swap / neg
        ] if
    ] if ;

: (clear-col) ( col# pivot-row i -- )
    [ [ clear-scale ] 2keep >r n*v r> v+ ] change-row ;

: (each-row) ( row# -- slice )
    rows dup <slice> ;

: each-row ( row# quot -- )
    >r (each-row) r> each ; inline

: clear-col ( col# row# -- )
    [ nth-row ] keep 1+
    [ >r 2dup r> (clear-col) ] each-row
    2drop ;

: do-row ( exchange-with row# -- )
    [ exchange-rows ] keep
    [ first-col ] keep
    clear-col ;

: find-row ( row# quot -- i elt )
    >r (each-row) r> find ; inline

: pivot-row ( col# row# -- n )
    [ dupd nth-row nth zero? not ] find-row 2nip ;

: (row-reduce) ( -- )
    0 cols rows min [
        over pivot-row dup
        [ over do-row 1+ ] [ drop ] if
    ] each drop ;

: row-reduce ( matrix -- matrix' )
    [ (row-reduce) ] with-matrix ;

: null/rank ( matrix -- null rank )
    row-reduce [ [ [ zero? ] all? ] subset ] keep
    [ length ] 2apply over - ;
