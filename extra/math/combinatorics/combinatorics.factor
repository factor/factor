USING: kernel math math.ranges math.vectors
sequences sorting mirrors assocs ;
IN: math.combinatorics

: possible? 0 rot between? ; inline

: nPk ( n k -- n!/k! )
    2dup possible? [ [a,b) product ] [ 2drop 0 ] if ;

: factorial ( n -- n! ) 1 nPk ;

: (nCk) ( n k -- nCk )
    [ nPk ] 2keep - factorial / ;

: twiddle 2dup - dupd < [ dupd - ] when ; inline

: nCk ( n k -- nCk )
    2dup possible? [ twiddle (nCk) ] [ 2drop 0 ] if ;

: inverse-permutation ( seq -- seq )
    <enum> >alist sort-values keys ;
