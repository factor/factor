! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: math
USING: arrays generic kernel sequences ;

! Matrices
: zero-matrix ( m n -- matrix )
    swap [ drop zero-array ] map-with ;

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
