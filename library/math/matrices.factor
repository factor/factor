! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: math
USING: generic kernel sequences vectors ;

! Vectors
: zero-vector ( n -- vector ) 0 <repeated> >vector ;

: vneg ( v -- v ) [ neg ] map ;

: n*v ( n v -- v ) [ * ] map-with ;
: v*n ( v n -- v ) swap n*v ;
: n/v ( n v -- v ) [ / ] map-with ;
: v/n ( v n -- v ) swap [ swap / ] map-with ;

: v+   ( v v -- v ) [ + ]   2map ;
: v-   ( v v -- v ) [ - ]   2map ;
: v*   ( v v -- v ) [ * ]   2map ;
: v/   ( v v -- v ) [ / ]   2map ;
: vmax ( v v -- v ) [ max ] 2map ;
: vmin ( v v -- v ) [ min ] 2map ;
: vand ( v v -- v ) [ and ] 2map ;
: vor  ( v v -- v ) [ or ]  2map ;
: v<   ( v v -- v ) [ < ]   2map ;
: v<=  ( v v -- v ) [ <= ]  2map ;
: v>   ( v v -- v ) [ > ]   2map ;
: v>=  ( v v -- v ) [ >= ]  2map ;

: vbetween? ( v from to -- v ) >r over >r v>= r> r> v<= vand ;

: sum ( v -- n ) 0 [ + ] reduce ;
: product ( v -- n ) 1 [ * ] reduce ;

: set-axis ( x y axis -- v )
    2dup v* >r >r drop dup r> v* v- r> v+ ;

: v. ( v v -- x ) 0 -rot [ * + ] 2each ;
: c. ( v v -- x ) 0 -rot [ conjugate * + ] 2each ;

: norm-sq ( v -- n ) 0 [ absq + ] reduce ;

: proj ( u v -- w )
    #! Orthogonal projection of u onto v.
    [ [ v. ] keep norm-sq v/n ] keep n*v ;

: cross-trace ( v1 v2 i1 i2 -- v1 v2 n )
    pick nth >r pick nth r> * ;

: cross-minor ( v1 v2 i1 i2 -- n )
    [ cross-trace -rot ] 2keep swap cross-trace 2nip - ;

: cross ( { x1 y1 z1 } { x2 y2 z2 } -- { z1 z2 z3 } )
    #! Cross product of two 3-dimensional vectors.
    [ 1 2 cross-minor ] 2keep
    [ 2 0 cross-minor ] 2keep
    0 1 cross-minor 3vector ;

! Matrices

! A diagonal of a matrix stored as a sequence of rows.
TUPLE: diagonal index ;

C: diagonal ( seq -- diagonal ) [ set-delegate ] keep ;

: diagonal@ ( n diag -- n vec ) dupd delegate nth ;

M: diagonal nth ( n diag -- elt ) diagonal@ nth ;

M: diagonal set-nth ( elt n diag -- ) diagonal@ set-nth ;

: zero-matrix ( m n -- matrix )
    swap [ drop zero-vector ] map-with ;

: identity-matrix ( n -- matrix )
    #! Make a nxn identity matrix.
    dup zero-matrix dup <diagonal> [ drop 1 ] nmap ;

! Matrix operations
: mneg ( m -- m ) [ vneg ] map ;

: n*m ( n m -- m ) [ n*v ] map-with ;
: m*n ( m n -- m ) swap n*m ;
: n/m ( n m -- m ) [ n/v ] map-with ;
: m/n ( m n -- m ) swap [ swap v/n ] map-with ;

: m+   ( m m -- m ) [ v+ ]   2map ;
: m-   ( m m -- m ) [ v- ]   2map ;
: m*   ( m m -- m ) [ v* ]   2map ;
: m/   ( m m -- m ) [ v/ ]   2map ;
: mmax ( m m -- m ) [ vmax ] 2map ;
: mmin ( m m -- m ) [ vmin ] 2map ;
: mand ( m m -- m ) [ vand ] 2map ;
: mor  ( m m -- m ) [ vor ]  2map ;
: m<   ( m m -- m ) [ v< ]   2map ;
: m<=  ( m m -- m ) [ v<= ]  2map ;
: m>   ( m m -- m ) [ v> ]   2map ;
: m>=  ( m m -- m ) [ v>= ]  2map ;

: v.m ( v m -- v ) flip [ v. ] map-with ;
: m.v ( m v -- v ) swap [ v. ] map-with ;
: m.  ( m m -- m ) flip swap [ m.v ] map-with ;

: trace ( matrix -- tr ) <diagonal> product ;
