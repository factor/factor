! Copyright (c) 2007, 2008 Slava Pestov, Doug Coleman, Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel math math.order math.ranges mirrors
namespaces sequences sorting fry ;
IN: math.combinatorics

<PRIVATE

: possible? ( n m -- ? )
    0 rot between? ; inline

: twiddle ( n k -- n k )
    2dup - dupd > [ dupd - ] when ; inline

! See this article for explanation of the factoradic-based permutation methodology:
! http://msdn2.microsoft.com/en-us/library/aa302371.aspx

: factoradic ( n -- factoradic )
    0 [ over 0 > ] [ 1+ [ /mod ] keep swap ] produce reverse 2nip ;

: (>permutation) ( seq n -- seq )
    [ '[ _ dupd >= [ 1+ ] when ] map ] keep prefix ;

: >permutation ( factoradic -- permutation )
    reverse 1 cut [ (>permutation) ] each ;

: permutation-indices ( n seq -- permutation )
    length [ factoradic ] dip 0 pad-head >permutation ;

PRIVATE>

: factorial ( n -- n! )
    1 [ 1+ * ] reduce ;

: nPk ( n k -- nPk )
    2dup possible? [ dupd - [a,b) product ] [ 2drop 0 ] if ;

: nCk ( n k -- nCk )
    twiddle [ nPk ] keep factorial / ;

: permutation ( n seq -- seq )
    [ permutation-indices ] keep nths ;

: all-permutations ( seq -- seq )
    [ length factorial ] keep '[ _ permutation ] map ;

: each-permutation ( seq quot -- )
    [ [ length factorial ] keep ] dip
    '[ _ permutation @ ] each ; inline

: reduce-permutations ( seq initial quot -- result )
    swapd each-permutation ; inline

: inverse-permutation ( seq -- permutation )
    <enum> >alist sort-values keys ;
