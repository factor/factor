! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: math-contrib
USING: arrays generic kernel sequences math ;

! Matrices
: zero-matrix ( m n -- matrix )
    swap [ drop 0 <array> ] map-with ;

: identity-matrix ( n -- matrix )
    #! Make a nxn identity matrix.
    dup [ swap [ = 1 0 ? ] map-with ] map-with ;

! Matrix operations
: mneg ( m -- m ) [ vneg ] map ;

: n*m ( n m -- m ) [ n*v ] map-with ;
: m*n ( m n -- m ) swap n*m ;
: n/m ( n m -- m ) [ n/v ] map-with ;
: m/n ( m n -- m ) swap [ swap v/n ] map-with ;

: m+   ( m m -- m ) [ v+ ] 2map ;
: m-   ( m m -- m ) [ v- ] 2map ;
: m*   ( m m -- m ) [ v* ] 2map ;
: m/   ( m m -- m ) [ v/ ] 2map ;

: v.m ( v m -- v ) flip [ v. ] map-with ;
: m.v ( m v -- v ) swap [ v. ] map-with ;
: m.  ( m m -- m ) flip swap [ m.v ] map-with ;

: mmin ( m -- n ) >r 1/0. r> [ [ min ] each ] each ;
: mmax ( m -- n ) >r -1/0. r> [ [ max ] each ] each ;
: mnorm ( m -- n ) dup mmax abs m/n ;
: m-almost= ( m n -- ? )
    t -rot [ [ almost= and ] 2each ] 2each ;

