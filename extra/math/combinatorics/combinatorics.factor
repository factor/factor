! Copyright (c) 2007, 2008 Slava Pestov, Doug Coleman, Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel math math.ranges mirrors namespaces sequences sorting ;
IN: math.combinatorics

<PRIVATE

: possible? ( n m -- ? )
    0 rot between? ; inline

: twiddle ( n k -- n k )
    2dup - dupd > [ dupd - ] when ; inline

! See this article for explanation of the factoradic-based permutation methodology:
!     http://msdn2.microsoft.com/en-us/library/aa302371.aspx

: factoradic ( n -- factoradic )
    0 [ over 0 > ] [ 1+ [ /mod ] keep swap ] [ ] unfold reverse 2nip ;

: (>permutation) ( seq n -- seq )
    [ [ dupd >= [ 1+ ] when ] curry map ] keep add* ;

: >permutation ( factoradic -- permutation )
    reverse 1 cut [ (>permutation) ] each ;

: permutation-indices ( n seq -- permutation )
    length [ factoradic ] dip 0 pad-left >permutation ;

: reorder ( seq indices -- seq )
    [ [ over nth , ] each drop ] { } make ;

PRIVATE>

: factorial ( n -- n! )
    1 [ 1+ * ] reduce ;

: nPk ( n k -- nPk )
    2dup possible? [ dupd - [a,b) product ] [ 2drop 0 ] if ;

: nCk ( n k -- nCk )
    twiddle [ nPk ] keep factorial / ;

: permutation ( n seq -- seq )
    tuck permutation-indices reorder ;

: all-permutations ( seq -- seq )
    [
        [ length factorial ] keep [ permutation , ] curry each
    ] { } make ;

: inverse-permutation ( seq -- permutation )
    <enum> >alist sort-values keys ;

