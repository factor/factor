! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.vectors math.matrices namespaces
sequences ;
IN: math.matrices.elimination

SYMBOL: matrix

: with-matrix ( matrix quot -- )
    [ swap matrix set call matrix get ] with-scope ; inline

: nth-row ( row# -- seq ) matrix get nth ;

: change-row ( row# quot: ( seq -- seq ) -- )
    matrix get swap change-nth ; inline

: exchange-rows ( row# row# -- ) matrix get exchange ;

: rows ( -- n ) matrix get length ;

: cols ( -- n ) 0 nth-row length ;

: skip ( i seq quot -- n )
    over [ find-from drop ] dip length or ; inline

: first-col ( row# -- n )
    #! First non-zero column
    0 swap nth-row [ zero? not ] skip ;

: clear-scale ( col# pivot-row i-row -- n )
    [ over ] dip nth dup zero? [
        3drop 0
    ] [
        [ nth dup zero? ] dip swap [
            2drop 0
        ] [
            swap / neg
        ] if
    ] if ;

: (clear-col) ( col# pivot-row i -- )
    [ [ clear-scale ] 2keep [ n*v ] dip v+ ] change-row ;

: rows-from ( row# -- slice )
    rows dup <slice> ;

: clear-col ( col# row# rows -- )
    [ nth-row ] dip [ [ 2dup ] dip (clear-col) ] each 2drop ;

: do-row ( exchange-with row# -- )
    [ exchange-rows ] keep
    [ first-col ] keep
    dup 1+ rows-from clear-col ;

: find-row ( row# quot -- i elt )
    [ rows-from ] dip find ; inline

: pivot-row ( col# row# -- n )
    [ dupd nth-row nth zero? not ] find-row 2nip ;

: (echelon) ( col# row# -- )
    over cols < over rows < and [
        2dup pivot-row [ over do-row 1+ ] when*
        [ 1+ ] dip (echelon)
    ] [
        2drop
    ] if ;

: echelon ( matrix -- matrix' )
    [ 0 0 (echelon) ] with-matrix ;

: nonzero-rows ( matrix -- matrix' )
    [ [ zero? ] all? not ] filter ;

: null/rank ( matrix -- null rank )
    echelon dup length swap nonzero-rows length [ - ] keep ;

: leading ( seq -- n elt ) [ zero? not ] find ;

: reduced ( matrix' -- matrix'' )
    [
        rows <reversed> [
            dup nth-row leading drop
            dup [ swap dup clear-col ] [ 2drop ] if
        ] each
    ] with-matrix ;

: basis-vector ( row col# -- )
    [ clone ] dip
    [ swap nth neg recip ] 2keep
    [ 0 spin set-nth ] 2keep
    [ n*v ] dip
    matrix get set-nth ;

: nullspace ( matrix -- seq )
    echelon reduced dup empty? [
        dup first length identity-matrix [
            [
                dup leading drop
                dup [ basis-vector ] [ 2drop ] if
            ] each
        ] with-matrix flip nonzero-rows
    ] unless ;

: 1-pivots ( matrix -- matrix )
    [ dup leading nip [ recip v*n ] when* ] map ;

: solution ( matrix -- matrix )
    echelon nonzero-rows reduced 1-pivots ;

: inverse ( matrix -- matrix ) ! Assumes an invertible matrix
    dup length
    [ identity-matrix [ append ] 2map solution ] keep
    [ tail ] curry map ;
