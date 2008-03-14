! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel sequences math math.functions
math.vectors combinators.cleave ;
IN: math.matrices

! Matrices
: zero-matrix ( m n -- matrix )
    [ nip 0 <array> ] curry map ;

: identity-matrix ( n -- matrix )
    #! Make a nxn identity matrix.
    dup [ [ = 1 0 ? ] with map ] curry map ;

! Matrix operations
: mneg ( m -- m ) [ vneg ] map ;

: n*m ( n m -- m ) [ n*v ] with map ;
: m*n ( m n -- m ) [ v*n ] curry map ;
: n/m ( n m -- m ) [ n/v ] with map ;
: m/n ( m n -- m ) [ v/n ] curry map ;

: m+   ( m m -- m ) [ v+ ] 2map ;
: m-   ( m m -- m ) [ v- ] 2map ;
: m*   ( m m -- m ) [ v* ] 2map ;
: m/   ( m m -- m ) [ v/ ] 2map ;

: v.m ( v m -- v ) flip [ v. ] with map ;
: m.v ( m v -- v ) [ v. ] curry map ;
: m.  ( m m -- m ) flip [ swap m.v ] curry map ;

: mmin ( m -- n ) >r 1/0. r> [ [ min ] each ] each ;
: mmax ( m -- n ) >r -1/0. r> [ [ max ] each ] each ;
: mnorm ( m -- n ) dup mmax abs m/n ;

<PRIVATE

: x first ; inline
: y second ; inline
: z third ; inline

: i [ [ y ] [ z ] bi* * ] [ [ z ] [ y ] bi* * ] 2bi - ;
: j [ [ z ] [ x ] bi* * ] [ [ x ] [ z ] bi* * ] 2bi - ;
: k [ [ y ] [ x ] bi* * ] [ [ x ] [ y ] bi* * ] 2bi - ;

PRIVATE>

: cross ( vec1 vec2 -- vec3 ) [ i ] [ j ] [ k ] 2tri 3array ;

: proj ( v u -- w )
    [ [ v. ] [ norm-sq ] bi / ] keep n*v ;

: (gram-schmidt) ( v seq -- newseq )
    [ dupd proj v- ] each ;

: gram-schmidt ( seq -- orthogonal )
    V{ } clone [ over (gram-schmidt) over push ] reduce ;

: norm-gram-schmidt ( seq -- orthonormal )
    gram-schmidt [ normalize ] map ;
