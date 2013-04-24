! Copyright (C) 2013 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays sequences sequences.deep sequences.extras 
        math math.functions math.vectors math.matrices fry grouping 
        sequences.private accessors combinators.short-circuit ;
IN: math.matrices.laplace

TUPLE: missing seq i ;
C: <missing> missing
M: missing nth-unsafe
    [ i>> dupd >= [ 1 + ] when ] [ seq>> nth-unsafe ] bi ;
M: missing length seq>> length 1 - ;
INSTANCE: missing immutable-sequence

: ij-to-n ( size row col -- n )
    [ * ] dip + ;   

: n-to-ij ( size n -- row col )
    swap /mod ;

<PRIVATE

: (minor') ( row col matrix1 -- matrix2 )
    [ remove-nth ] with map remove-nth ; 

: (minor) ( row col matrix1 -- matrix2 )
    [ swap <missing> ] with map swap <missing> ;        

: minor ( matrix1 row col -- matrix2 )
    rot (minor) ;

: nth-minor ( matrix1 n -- matrix2 )
    [ dup length ] dip  
    n-to-ij minor ;

: matrix-size-one? ( matrix -- ? )
    { [ length 1 = ] [ first length 1 = ] } 1&& ;
  
: unbox-if-size-one ( matrix -- n )
    dup matrix-size-one?   
    [ first first ] when ;                

: minors ( matrix -- seq )
    dup length iota   
    [ nth-minor unbox-if-size-one ] with map ; 

: coeffs ( matrix -- seq )
    first [ odd? [ neg ] when ] map-index ;

: coeffs-minors ( matrix -- coeffs minors )
      [ coeffs ] [ minors ] bi ;

: last-laplace-level? ( minors -- ? )
    first number? ;   

: laplace ( coeffs minors -- n )
    dup last-laplace-level? [
        [ coeffs-minors laplace ] map
    ] unless v* sum ;

PRIVATE>

: det ( matrix -- n )
    coeffs-minors
    laplace ;

