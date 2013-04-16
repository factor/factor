! Copyright (C) 2013 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays sequences sequences.deep sequences.extras 
        math math.functions math.vectors math.matrices fry grouping ;
IN: determinant

: ij-to-n ( size row col -- n )
    [ * ] dip   ! ( size*row col ) 
    + ;  ! ( size*row+col ) 

: n-to-ij ( size n -- row col )
    swap /mod ;

: row-of-n ( size n -- row )
    n-to-ij  ! ( row col )
    drop ;  ! ( row ) 

: col-of-n ( size n -- col )
    n-to-ij  ! ( row col )
    nip ;  ! ( col ) 

: in-row? ( size n row -- ? )
    [ row-of-n ] dip  ! ( row row ) 
    = ;  ! ( ? ) 

: in-col? ( size n col -- ? )
    [ col-of-n ] dip  ! ( col col ) 
    = ;  ! ( ? ) 

: pickswap ( x y z -- x y x z )
    pick swap ;

: same-row? ( size n m -- ? )
    pickswap  ! ( size n size m )
    row-of-n  ! ( size n row-of-m )
    in-row? ;  ! ( ? ) 

: same-col? ( size n m -- ? )
    pickswap  ! ( size n size m )
    col-of-n  ! ( size n col-of-m )
    in-col? ;  ! ( ? ) 

: different-row-different-col? ( size n m -- ? )
      [ same-row? not ] [ same-col? not ] 3bi and ;

: flat-matrix-size ( matrix -- size )
    length sqrt >integer ;  ! ( size )

: flat-to-matrix ( seq -- matrix )
    dup flat-matrix-size  
    <groups> ;   

! filter-index, that doesn't put elt on the stack  
: filter-index' ( ... seq quot: ( ... i -- ... ? ) -- ... seq' )
    '[ [ nip @ ] filter-index ] call ; inline
 
! Flatten a 2d matrix.
! Apply [ quot ] filter-index'.
! Unflatten result. 
: matrix-filter-index ( matrix1 quot -- matrix2 )
      [ concat ] dip filter-index' flat-to-matrix ; inline

: swaprot ( x y z -- z x y )
    swap rot ;

: minor ( matrix1 n -- matrix2 )
    over length swaprot  ! ( size n matrix1 )
    [ different-row-different-col? ]    
    with with matrix-filter-index ;  

: matrix-size-one? ( matrix -- ? )
    concat length 1 = ;
  
: unbox-if-size-one ( matrix -- n )
    dup matrix-size-one?   
    [ first first ] when ;                

: minors ( matrix -- seq )
    dup length iota   
    [ minor unbox-if-size-one ] with map ; 

: coeffs ( matrix -- seq )
    first -1 swap  
    [ ^ * ] with map-index ;

: coeffs-minors ( matrix -- coeffs minors )
      [ coeffs ] [ minors ] bi ;

: last-laplace-level? ( minors -- ? )
    first number? ;   

: laplace ( coeffs minors -- n )
    dup last-laplace-level? [
        [ coeffs-minors laplace ] map
    ] unless v* sum ;

: det ( matrix -- n )
    coeffs-minors
    laplace ;

