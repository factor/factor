! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: matrices
USING: kernel math namespaces parser sequences ;

SYMBOL: matrix

: with-matrix ( matrix quot -- )
    [ swap matrix set call matrix get ] with-scope ; inline

: nth-row ( row# -- seq ) matrix get nth ;

: change-row ( row# quot -- | quot: seq -- seq )
    matrix get swap change-nth ; inline

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

: rows-from ( row# -- slice )
    rows dup <slice> ;

: clear-col ( col# row# rows -- )
    >r nth-row r> [ >r 2dup r> (clear-col) ] each 2drop ;

: do-row ( exchange-with row# -- )
    [ exchange-rows ] keep
    [ first-col ] keep
    dup 1+ rows-from clear-col ;

: find-row ( row# quot -- i elt )
    >r rows-from r> find ; inline

: pivot-row ( col# row# -- n )
    [ dupd nth-row nth zero? not ] find-row 2nip ;

: (echelon) ( col# row# -- )
    over cols < over rows < and [
        2dup pivot-row [ over do-row 1+ ] when*
        >r 1+ r> (echelon)
    ] [
        2drop
    ] if ;

: echelon ( matrix -- matrix' )
    [ 0 0 (echelon) ] with-matrix ;

: nonzero-rows [ [ zero? ] all? not ] subset ;

: null/rank ( matrix -- null rank )
    echelon dup length swap nonzero-rows length [ - ] keep ;

: leading ( seq -- n ) [ zero? not ] find drop ;

: reduced ( matrix' -- matrix'' )
    [
        rows <reversed> [
            dup nth-row leading
            dup 0 >= [ swap dup clear-col ] [ 2drop ] if
        ] each
    ] with-matrix ;

: basis-vector ( row col# -- )
    >r clone r>
    [ swap nth neg recip ] 2keep
    [ 0 swap rot set-nth ] 2keep
    >r n*v r>
    matrix get set-nth ;

: nullspace ( matrix -- seq )
    echelon reduced dup empty? [
        dup first length identity-matrix [
            [
                dup leading
                dup 0 >= [ basis-vector ] [ 2drop ] if
            ] each
        ] with-matrix flip nonzero-rows
    ] unless ;

: proj ( v u -- w )
    [ [ v. ] keep norm-sq / ] keep n*v ;

: (gram-schmidt) ( v seq -- newseq )
    dupd [ proj v- ] each-with ;

: gram-schmidt ( seq -- orthogonal )
    V{ } clone [ over (gram-schmidt) over push ] reduce ;

: norm-gram-schmidt ( seq -- orthonormal )
    gram-schmidt [ normalize ] map ;
