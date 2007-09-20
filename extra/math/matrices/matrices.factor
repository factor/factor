! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel sequences math math.functions
math.vectors ;
IN: math.matrices

! Matrices
: zero-matrix ( m n -- matrix )
    [ nip 0 <array> ] curry map ;

: identity-matrix ( n -- matrix )
    #! Make a nxn identity matrix.
    dup [ [ = 1 0 ? ] curry* map ] curry map ;

! Matrix operations
: mneg ( m -- m ) [ vneg ] map ;

: n*m ( n m -- m ) [ n*v ] curry* map ;
: m*n ( m n -- m ) [ v*n ] curry map ;
: n/m ( n m -- m ) [ n/v ] curry* map ;
: m/n ( m n -- m ) [ v/n ] curry map ;

: m+   ( m m -- m ) [ v+ ] 2map ;
: m-   ( m m -- m ) [ v- ] 2map ;
: m*   ( m m -- m ) [ v* ] 2map ;
: m/   ( m m -- m ) [ v/ ] 2map ;

: v.m ( v m -- v ) flip [ v. ] curry* map ;
: m.v ( m v -- v ) [ v. ] curry map ;
: m.  ( m m -- m ) flip [ swap m.v ] curry map ;

: mmin ( m -- n ) >r 1/0. r> [ [ min ] each ] each ;
: mmax ( m -- n ) >r -1/0. r> [ [ max ] each ] each ;
: mnorm ( m -- n ) dup mmax abs m/n ;

: cross-i ( vec1 vec2 -- i )
    over third over second * >r
    swap second swap third * r> - ;

: cross-j ( vec1 vec2 -- j )
    over first over third * >r
    swap third swap first * r> - ;

: cross-k ( vec1 vec2 -- k )
    over first over second * >r
    swap second swap first * r> - ;

: cross ( vec1 vec2 -- vec3 )
    [ cross-i ] 2keep [ cross-j ] 2keep cross-k 3array ;

: proj ( v u -- w )
    [ [ v. ] keep norm-sq / ] keep n*v ;

: (gram-schmidt) ( v seq -- newseq )
    [ dupd proj v- ] each ;

: gram-schmidt ( seq -- orthogonal )
    V{ } clone [ over (gram-schmidt) over push ] reduce ;

: norm-gram-schmidt ( seq -- orthonormal )
    gram-schmidt [ normalize ] map ;
