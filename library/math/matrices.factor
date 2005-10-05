! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: math
USING: arrays generic kernel sequences ;

! Vectors
: vneg ( v -- v ) [ neg ] map ;

: n*v ( n v -- v ) [ * ] map-with ;
: v*n ( v n -- v ) swap n*v ;
: n/v ( n v -- v ) [ / ] map-with ;
: v/n ( v n -- v ) swap [ swap / ] map-with ;

: v+   ( v v -- v ) [ + ] 2map ;
: v-   ( v v -- v ) [ - ] 2map ;
: v*   ( v v -- v ) [ * ] 2map ;
: v/   ( v v -- v ) [ / ] 2map ;
: vmax ( v v -- v ) [ max ] 2map ;
: vmin ( v v -- v ) [ min ] 2map ;

: sum ( v -- n ) 0 [ + ] reduce ;
: product ( v -- n ) 1 [ * ] reduce ;

: set-axis ( x y axis -- v )
    2dup v* >r >r drop dup r> v* v- r> v+ ;

: v. ( v v -- x )
    #! Real inner product.
    0 [ * + ] 2reduce ;

: c. ( v v -- x )
    #! Complex inner product.
    0 [ ** + ] 2reduce ;

: norm-sq ( v -- n ) 0 [ absq + ] reduce ;

: norm ( vec -- n ) norm-sq sqrt ;

: normalize ( vec -- vec ) dup norm v/n ;

: proj ( u v -- w )
    #! Orthogonal projection of u onto v.
    [ [ v. ] keep norm-sq v/n ] keep n*v ;

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
